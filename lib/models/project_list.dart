// ignore_for_file: avoid_classes_with_only_static_members, non_constant_identifier_names, avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:math';


import 'package:firebase_storage/firebase_storage.dart';

import '../utils/bool.dart';
import '../utils/connectivity.dart';
import '../utils/sync.dart';
import '../utils/db.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';
import 'project.dart';

class ProjectList with ChangeNotifier {
  bool hasInternet = false; 
  List<Project> _items = [];
  List<Project> firebaseItems = [];
  Map<String, Project> sqlLookup = {};
  Map<String, Project> firebaseLookup = {};
  Map<String, Project> matchLookup = {};

  List<Project> get items => [..._items];

  // List<Obra> get andamentoItems => _items.where((prod) => prod.isComplete).toList();


  // int get itemsCount {
  //   return _items.length;
  // }

  List<Project> getSpecificProject(matchId){
    return _items.where((p) => p.id == matchId).toList();
  }

  bool getSpecificProjectBool(String id){
    if(_items.isEmpty){
      return false;
    }
    return _items.where((p) => p.id == id).toList().isEmpty ? true : false;
  }


  onLoad() async {
    hasInternet = await hasInternetConnection();
  }

  Future<void> loadProjects() async {
    await onLoad();
    _items.clear();
    List<Project> projects = [];
    List data = await DB.getInfoFromDb('projects');
    if(data.isNotEmpty){
      projects = data.map((e) => Project.fromSQLMap(e)).toList();
      for(var project in projects){
        _items.add(project);
      }
    }
    sqlLookup = {for (final project in _items) project.id: project};
    notifyListeners();
  }

  Future<void> addToFirebase(dynamic element, bool isUpdate, {dynamic parent}) async {
    try {
      String matchmakingId = element.matchmakingId;
     
      dynamic father = parent[element.matchmakingId];
      if(father != null){
        matchmakingId = father.firebaseId;
      }
      final response = await http.post(
        Uri.parse('${Constants.PROJECT_URL}.json'),
        body: jsonEncode(
          {
            "firebaseId": element.firebaseId,
            "engineer": element.engineer,
            "begDate": element.begDate.toIso8601String(),
            "endDate": element.endDate.toIso8601String(),
            "civil": element.civil,
            "eletrical": element.eletrical,
            "matchmakingId": matchmakingId, 
            "financial": element.financial,
            "lastUpdated": element.lastUpdated.toIso8601String(),
          },
        ),
      );
      if (response.statusCode != 200) {
          throw Exception('Failed to add obra to Firebase');
      }
      String id = jsonDecode(response.body)['name'];
      http.post(
        Uri.parse('${Constants.SYNC_URL}.json'),
        body: jsonEncode(
          {
            "classId": id,
            "tableName": 'projects',
            "crud": 'add',
            "createTime": DateTime.now().toIso8601String(),
          },
        ),
      );

      if(isUpdate){
        return;
      }
      element.firebaseId = id;
      DB.updateInfo('projects', element.id, element.toMapSQL());
      DB.deleteInfo('sync', element.id, crud: 'add');
    } catch (e) {
      print('Error adding obra to Firebase: $e');
      rethrow;
    }
  }

  Future<void> syncData(List<Map<String, dynamic>> fireSync, List<Map<String, dynamic>> sqlSync) async {
    await loadProjects(); //loads things from SQL
    List<Project> loadedProjects = _items;
    
    //getting stuff from firebase
    final response = await http.get(Uri.parse('${Constants.PROJECT_URL}.json'),);
    if (response.body != 'null'){
      Map<String, dynamic> data = jsonDecode(response.body);
      firebaseItems = data.entries.map((entry) => Project(
        id: entry.key,
        firebaseId: entry.key,
        engineer: entry.value['engineer'],
        lastUpdated: DateTime.parse(entry.value['lastUpdated']),
        begDate: DateTime.parse(entry.value['begDate']),
        endDate: DateTime.parse(entry.value['endDate']),
        civil: checkBool(entry.value['civil']),
        matchmakingId: entry.value['matchmakingId'],
        eletrical: checkBool(entry.value['eletrical']),
        financial: checkBool(entry.value['financial']),
      )).toList();
      
    }

    if(firebaseItems.isEmpty && loadedProjects.isEmpty){
      return;
    }

    firebaseLookup = {for (final obra in firebaseItems) obra.id: obra};
    matchLookup = {for (final obra in _items) obra.firebaseId: obra};

    String baseUrl = 'Constants.PROJECT_URL';
    await SyncDB().commonSyncData(fireSync, sqlSync, firebaseLookup, matchLookup, sqlLookup, addToFirebase, 'projects', baseUrl);
  }

  Future<void> saveProduct(Map<String, Object> data, File pickedPDF) async {
    await onLoad();

    bool hasId = data['id'] != null;
    bool hasFID = data['firebaseId'] != null;

    final product = Project(
      id: hasId ? data['id'] as String : Random().nextDouble().toString(),
      firebaseId: hasFID? data['firebaseId'] as String : '',
      engineer: data['engineer'] as String,
      lastUpdated: DateTime.now(),
      begDate: data['begDate'] == null ? DateTime.now() : data['begDate'] as DateTime,
      endDate: data['endDate'] == null ? DateTime.now() : data['endDate'] as DateTime,
      eletrical: data['eletrical'] as bool,
      civil: data['civil'] as bool,
      matchmakingId: data['matchmakingId'] as String,
      financial: data['financial'] as bool,
    );

    if (hasId) {
      return updateProject(product);
    } else {
      return await addProject(product, pickedPDF);
    }
  }

  Future<String> uploadPDFFile(File pdfFile, String fileName) async {
  try {
    final Reference storageRef = FirebaseStorage.instance.ref();
    final Reference fileRef = storageRef.child('pdf_files/$fileName.pdf');
    final UploadTask uploadTask = fileRef.putFile(pdfFile);
    final TaskSnapshot downloadUrl = (await uploadTask);
    final String url = (await downloadUrl.ref.getDownloadURL());
    return url;
  } catch (e) {
    print(e);
    rethrow;
  }
}

  Future<void> addProject(Project product, File? pdf) async {
    _items.add(product);
    addAdditionInfo(product, pdf);
    notifyListeners();
  }

  Future<void> addAdditionInfo(Project element, File? pdf) async {
    String id;
    String pdfURL = '';
    if(hasInternet == true){
      if(pdf != null){
        pdfURL = await uploadPDFFile(pdf, element.id);
      }
      final response = await http.post(
        Uri.parse('${Constants.PROJECT_URL}.json'),
        body: jsonEncode(
          {
            "firebaseId": element.firebaseId,
            "engineer": element.engineer,
            "begDate": element.begDate.toIso8601String(),
            "endDate": element.endDate.toIso8601String(),
            "civil": element.civil,
            "matchmakingId": element.matchmakingId,
            "eletrical": element.eletrical,
            "financial": element.financial,
            "lastUpdated": element.lastUpdated.toIso8601String(),
            "pdfURL": pdfURL,
          },
        ),
      );
      id = jsonDecode(response.body)['name'];
      element.firebaseId = id;
      await http.post(
        Uri.parse('${Constants.SYNC_URL}.json'),
        body: jsonEncode(
          {
            "classId": id,
            "tableName": 'projects',
            "crud": 'add',
            "createTime": DateTime.now().toIso8601String(),
          },
        ),
      );
    }else{
      id = Random().nextDouble().toString();
      Map <String, dynamic> syncInfo = {
        'id': id,
        'tableName': 'projects',
        'crud': 'add',
      };
      await DB.insert('sync', syncInfo);
    }

    if(pdf != null){
      element.pdfFile = pdf;
    }

    element.id = id;
    await DB.insert('projects', element.toMapSQL());
    
  }

  Future<void> updateProject(Project product) async {
    int index = _items.indexWhere((p) => p.id == product.id);
    _items[index] = product;
    addUpdateInfo(product);
    notifyListeners();
  }

  Future<void> addUpdateInfo(Project element) async {
    int index = _items.indexWhere((p) => p.id == element.id);
    String id;
    
    if(hasInternet){
      if (index >= 0) {
        await http.patch(
          Uri.parse('${Constants.PROJECT_URL}/${element.id}.json'),
          body: jsonEncode(
            {
              "firebaseId": element.firebaseId,
              "engineer": element.engineer,
              "begDate": element.begDate.toIso8601String(),
              "endDate": element.endDate.toIso8601String(),
              "civil": element.civil,
              "eletrical": element.eletrical,
              "financial": element.financial,
              "lastUpdated": element.lastUpdated.toIso8601String(),
            },
          ),
        );
        await http.post(
          Uri.parse('${Constants.SYNC_URL}.json'),
          body: jsonEncode(
            {
              "classId": element.id,
              "tableName": 'projects',
              "crud": 'update',
              "createTime": DateTime.now().toIso8601String(),
            },
          ),
        );
        _items[index] = element;
      }
    }else{
      id = Random().nextDouble().toString();
      Map <String, dynamic> syncInfo = {
        'id': id,
        'tableName': 'projects',
        'crud': 'update'
      };
      await DB.insert('sync', syncInfo);
    }
    element.lastUpdated = DateTime.now();
    await DB.updateInfo('projects', element.id, element.toMapSQL());
  }

  Future<void> removeProject(Project element) async {
    _items.remove(element);
    addRemovalInfo(element);
    notifyListeners();
  }

  Future<void> addRemovalInfo(Project product) async {
    List<Map<String, dynamic>> fireSync = [];
    if(hasInternet == true){
      product.toggleDeletion();
      await http.post(
        Uri.parse('${Constants.SYNC_URL}.json'),
        body: jsonEncode(
          {
            "classId": product.id,
            "tableName": 'projects',
            "crud": 'delete',
            "createTime": DateTime.now().toIso8601String(),
          },
        ),
      );

      final response = await http.get(Uri.parse('${Constants.SYNC_URL}.json'),);
        if (response.body != 'null'){
        Map<String, dynamic> data = jsonDecode(response.body);
        data.forEach((productId, productData) {
            Map<String, dynamic> itemMap = {
            'id': productId,
            'classId': productData['classId'],
            'tableName': productData['tableName'],
            'crud': productData['crud'],
            'createTime': DateTime.parse(productData['createTime']),
          };
          fireSync.add(itemMap);
        });
      }

      for(var element in fireSync){
        if(element['classId'] == product.id && element['crud'] == 'add'){
           await http.delete(
            Uri.parse('${Constants.SYNC_URL}/${element['id']}.json'),
          );
        }
      }
    }else{
      Map <String, dynamic> syncInfo = {
        'id': product.id,
        'tableName': 'projects',
        'crud': 'delete'
      };
      List data = await DB.getInfoFromDb('sync');
      for(var sync in data){
        if(sync['id'] == product.id && (sync['crud'] == 'add' || sync['crud'] == 'update')){
          DB.deleteInfo('sync', sync['id']);
        }
      }
      await DB.insert('sync', syncInfo);
    }
    await DB.deleteInfo("projects", product.id);
  }
}  