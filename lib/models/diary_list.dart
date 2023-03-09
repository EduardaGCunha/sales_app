// ignore_for_file: avoid_classes_with_only_static_members, non_constant_identifier_names, avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:math';


import 'package:firebase_storage/firebase_storage.dart';

import '../utils/bool.dart';
import '../utils/connectivity.dart';
import '../utils/sync.dart';
import 'diary.dart';
import '../utils/db.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class DiaryList with ChangeNotifier {
  bool hasInternet = false; 
  List<Diary> _items = [];
  List<Diary> firebaseItems = [];
  Map<String, Diary> sqlLookup = {};
  Map<String, Diary> firebaseLookup = {};
  Map<String, Diary> matchLookup = {};

  List<Diary> get items => [..._items];

  // List<Obra> get andamentoItems => _items.where((prod) => prod.isComplete).toList();


  // int get itemsCount {
  //   return _items.length;
  // }

  List<Diary> getSpecificDiary(matchId){
    return _items.where((p) => p.id == matchId).toList();
  }

  bool getSpecificDiaryBool(String id){
    if(_items.isEmpty){
      return false;
    }
    return _items.where((p) => p.id == id).toList().isEmpty ? true : false;
  }

  List<Diary> allMatchingDiaries(matchId){
    return _items.where((prod) => prod.matchmakingId == matchId).toList();
  }



  onLoad() async {
    hasInternet = await hasInternetConnection();
  }

  Future<void> loadDiaries() async {
    await onLoad();
    _items.clear();
    List<Diary> diares = [];
    List data = await DB.getInfoFromDb('diaries');
    if(data.isNotEmpty){
      diares = data.map((e) => Diary.fromSQLMap(e)).toList();
      for(var project in diares){
        _items.add(project);
      }
    }
    sqlLookup = {for (final project in _items) project.id: project};
    notifyListeners();
  }

  Future<String> uploadImageFirebase(Diary element, File image) async{
    final storage = FirebaseStorage.instance;
    final imageRef = storage.ref().child('user_images').child(element.id);
    await imageRef.putFile(image).whenComplete(() {});
    return await imageRef.getDownloadURL();
  }


  Future<void> addToFirebase(dynamic element, bool isUpdate, {dynamic parent}) async {
    try {
      String matchmakingId = element.matchmakingId;
     
      dynamic father = parent[element.matchmakingId];
      if(father != null){
        matchmakingId = father.firebaseId;
      }
      String imageURL = await uploadImageFirebase(element, element.image);
      final response = await http.post(
        Uri.parse('${Constants.DIARY_URL}.json'),
        body: jsonEncode(
          {
            "firebaseId": element.firebaseId,
            "description": element.description,
            "date": element.begDate.toIso8601String(),
            "initiatedServ": element.initiatedServ,
            "finishedServ": element.finishedServ,
            "currentPhase": element.currentPhase,
            "matchmakingId": matchmakingId, 
            "images": imageURL,
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
            "tableName": 'diaries',
            "crud": 'add',
            "createTime": DateTime.now().toIso8601String(),
          },
        ),
      );

      if(isUpdate){
        return;
      }
      element.firebaseId = id;
      DB.updateInfo('diaries', element.id, element.toMapSQL());
      DB.deleteInfo('sync', element.id, crud: 'add');
    } catch (e) {
      print('Error adding obra to Firebase: $e');
      rethrow;
    }
  }

  Future<void> syncData(List<Map<String, dynamic>> fireSync, List<Map<String, dynamic>> sqlSync) async {
    await loadDiaries(); //loads things from SQL
    List<Diary> loadedProjects = _items;
    
    //getting stuff from firebase
    final response = await http.get(Uri.parse('${Constants.DIARY_URL}.json'),);
    if (response.body != 'null'){
      Map<String, dynamic> data = jsonDecode(response.body);
      firebaseItems = data.entries.map((entry) => Diary(
        id: entry.key,
        firebaseId: entry.key,
        description: entry.value['description'],
        initiatedServ: entry.value['initiatedServ'],
        currentPhase: entry.value['currentPhase'],
        finishedServ: entry.value['finishedServ'],
        lastUpdated: DateTime.parse(entry.value['lastUpdated']),
        date: DateTime.parse(entry.value['date']),
        matchmakingId: entry.value['matchmakingId'],
      )).toList();
      
    }

    if(firebaseItems.isEmpty && loadedProjects.isEmpty){
      return;
    }

    firebaseLookup = {for (final obra in firebaseItems) obra.id: obra};
    matchLookup = {for (final obra in _items) obra.firebaseId: obra};

    String baseUrl = 'Constants.DIARY_URL';
    await SyncDB().commonSyncData(fireSync, sqlSync, firebaseLookup, matchLookup, sqlLookup, addToFirebase, 'diaries', baseUrl);
  }

  Future<void> saveDiary(Map<String, Object> data, File pickedPDF) async {
    await onLoad();

    bool hasId = data['id'] != null;
    bool hasFID = data['firebaseId'] != null;

    final element = Diary(
      id: hasId ? data['id'] as String : Random().nextDouble().toString(),
      firebaseId: hasFID? data['firebaseId'] as String : '',
      description: data['description'] as String,
      initiatedServ: data['initiatedServ'] as String,
      currentPhase: data['currentPhase'] as String,
      finishedServ: data['finishedServ'] as String,
      lastUpdated: DateTime.now(),
      date: data['date'] == null ? DateTime.now() : data['date'] as DateTime,
      matchmakingId: data['matchmakingId'] as String,
    );

    if (hasId) {
      return updateProject(element);
    } else {
      return await addDiary(element, pickedPDF);
    }
  }

  Future<void> addDiary(Diary product, File? image) async {
    _items.add(product);
    addAdditionInfo(product, image);
    notifyListeners();
  }

  Future<void> addAdditionInfo(Diary element, File? image) async {
    String id;
    if(hasInternet == true){
      String imageURL = await uploadImageFirebase(element, image!);
      final response = await http.post(
        Uri.parse('${Constants.DIARY_URL}.json'),
        body: jsonEncode(
          {
            "firebaseId": element.firebaseId,
            "description": element.description,
            "date": element.date.toIso8601String(),
            "initiatedServ": element.initiatedServ,
            "finishedServ": element.finishedServ,
            "matchmakingId": element.matchmakingId, 
            "currentPhase": element.currentPhase, 
            "images": imageURL,
            "lastUpdated": element.lastUpdated.toIso8601String(),
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
            "tableName": 'diaries',
            "crud": 'add',
            "createTime": DateTime.now().toIso8601String(),
          },
        ),
      );
    }else{
      id = Random().nextDouble().toString();
      Map <String, dynamic> syncInfo = {
        'id': id,
        'tableName': 'diaries',
        'crud': 'add',
      };
      await DB.insert('sync', syncInfo);
    }

    if(image != null){
      element.images = image;
    }
    element.id = id;
    await DB.insert('diaries', element.toMapSQL());
    
  }

  Future<void> updateProject(Diary product) async {
    int index = _items.indexWhere((p) => p.id == product.id);
    _items[index] = product;
    addUpdateInfo(product);
    notifyListeners();
  }

  Future<void> addUpdateInfo(Diary element) async {
    int index = _items.indexWhere((p) => p.id == element.id);
    String id;
    
    if(hasInternet){
      if (index >= 0) {
        await http.patch(
          Uri.parse('${Constants.DIARY_URL}/${element.id}.json'),
          body: jsonEncode(
            {
              "firebaseId": element.firebaseId,
              "currentPhase": element.currentPhase,
              "description": element.description,
              "date": element.date.toIso8601String(),
              "initiatedServ": element.initiatedServ,
              "finishedServ": element.finishedServ,
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
        'tableName': 'diaries',
        'crud': 'update'
      };
      await DB.insert('sync', syncInfo);
    }
    element.lastUpdated = DateTime.now();
    await DB.updateInfo('diaries', element.id, element.toMapSQL());
  }

  Future<void> removeProject(Diary element) async {
    _items.remove(element);
    addRemovalInfo(element);
    notifyListeners();
  }

  Future<void> addRemovalInfo(Diary product) async {
    List<Map<String, dynamic>> fireSync = [];
    if(hasInternet == true){
      product.toggleDeletion();
      await http.post(
        Uri.parse('${Constants.SYNC_URL}.json'),
        body: jsonEncode(
          {
            "classId": product.id,
            "tableName": 'diaries',
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
        'tableName': 'diaries',
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
    await DB.deleteInfo("diaries", product.id);
  }
}  