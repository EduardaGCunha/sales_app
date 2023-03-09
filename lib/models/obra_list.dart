// ignore_for_file: avoid_classes_with_only_static_members, non_constant_identifier_names, avoid_print

import 'dart:collection';
import 'dart:convert';
import 'dart:math';


import '../utils/connectivity.dart';
import '../utils/sync.dart';
import 'obra.dart';
import '../utils/db.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class ObraList with ChangeNotifier {
  bool hasInternet = false; 
  List<Obra> _items = [];
  List<Obra> firebaseItems = [];
  Map<String, Obra> sqlLookup = {};
  Map<String, Obra> firebaseLookup = {};
  Map<String, Obra> matchLookup = {};

  List<Obra> get items => [..._items];

  // List<Obra> get andamentoItems => _items.where((prod) => prod.isComplete).toList();


  // int get itemsCount {
  //   return _items.length;
  // }

  bool getSpecificObra(String id){
    if(_items.isEmpty){
      return false;
    }
    return _items.where((p) => p.id == id).toList().isEmpty ? true : false;
  }


  onLoad() async {
    hasInternet = await hasInternetConnection();
  }

  Future<void> loadProducts() async {
    await onLoad();
    _items.clear();
    List<Obra> obras = [];
    List data = await DB.getInfoFromDb('obras');
    if(data.isNotEmpty){
      obras = data.map((e) => Obra.fromSQLMap(e)).toList();
      for(var obra in obras){
        _items.add(obra);
      }
    }
    sqlLookup = {for (final obra in _items) obra.id: obra};
    notifyListeners();
  }

  Future<void> addToFirebase(dynamic element, bool isUpdate, {dynamic parent}) async {
    try {
        final response = await http.post(
            Uri.parse('${Constants.OBRA_URL}.json'),
            body: jsonEncode(
              {
                "enterprise": element.enterprise,
                "responsible": element.responsible,
                "owner": element.owner,
                "address": element.address,
                "image": element.image,
                "products": element.products,
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
              "tableName": 'obras',
              "crud": 'add',
              "createTime": DateTime.now().toIso8601String(),
            },
          ),
        );

      if(isUpdate){
        return;
      }
      element.firebaseId = id;
      DB.updateInfo('obras', element.id, element.toMapSQL());
      DB.deleteInfo('sync', element.id, crud: 'add');
    } catch (e) {
      print('Error adding obra to Firebase: $e');
      rethrow;
    }
  }

  Future<void> syncData(List<Map<String, dynamic>> fireSync, List<Map<String, dynamic>> sqlSync) async {
    await loadProducts(); //loads things from SQL
    List<Obra> loadedObras = _items;
    
    //getting stuff from firebase
    final response = await http.get(Uri.parse('${Constants.OBRA_URL}.json'),);
    if (response.body != 'null'){
      Map<String, dynamic> data = jsonDecode(response.body);
      firebaseItems = data.entries.map((entry) => Obra(
        id: entry.key,
        firebaseId: entry.key,
        lastUpdated: DateTime.parse(entry.value['lastUpdated']),
        data: DateTime.parse(entry.value['data']),
        enterprise: entry.value['enterprise'],
        products: entry.value['products'] as List<String>,
        image: entry.value['image'] as List<String>,
        address: entry.value['address'],
        owner: entry.value['owner'],
        responsible: entry.value['responsible'],
      )).toList();
      
    }

    if(firebaseItems.isEmpty && loadedObras.isEmpty){
      return;
    }

    firebaseLookup = {for (final obra in firebaseItems) obra.id: obra};
    matchLookup = {for (final obra in _items) obra.firebaseId: obra};

    String baseUrl = 'Constants.OBRA_URL';
    await SyncDB().commonSyncData(fireSync, sqlSync, firebaseLookup, matchLookup, sqlLookup, addToFirebase, 'obras', baseUrl);
  }

  Future<void> saveProduct(Map<String, Object> data) async {
    await onLoad();

    bool hasId = data['id'] != null;
    bool hasFID = data['firebaseId'] != null;

    final product = Obra(
      id: hasId ? data['id'] as String : Random().nextDouble().toString(),
      firebaseId: hasFID? data['firebaseId'] as String : '',
      enterprise: data['enterprise'] as String,
      image: [''],
      products: data['products'] == null? [''] : data['products'] as List<String>,
      lastUpdated: DateTime.now(),
      data: DateTime.now(),
      responsible: data['responsible'] as String,
      address: data['address'] as String,
      owner: data['owner'] as String,
    );

    if (hasId) {
      return updateElement(product);
    } else {
      return await addObra(product);
    }
  }

  Future<void> addObra(Obra product) async {
    _items.add(product);
    addAdditionInfo(product);
    notifyListeners();
  }

  Future<void> addAdditionInfo(Obra element) async {
    String id;
    if(hasInternet == true){
      final response = await http.post(
        Uri.parse('${Constants.OBRA_URL}.json'),
        body: jsonEncode(
          {
              "enterprise": element.enterprise,
              "responsible": element.responsible,
              "owner": element.owner,
              "address": element.address,
              "image": element.image,
              "products": element.products,
              "data": element.data.toIso8601String(),
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
            "tableName": 'obras',
            "crud": 'add',
            "createTime": DateTime.now().toIso8601String(),
          },
        ),
      );
    }else{
      id = Random().nextDouble().toString();
      Map <String, dynamic> syncInfo = {
        'id': id,
        'tableName': 'obras',
        'crud': 'add',
      };
      await DB.insert('sync', syncInfo);
    }

    element.id = id;
    await DB.insert('obras', element.toMapSQL());
    
  }

  Future<void> updateElement(Obra product) async {
    int index = _items.indexWhere((p) => p.id == product.id);
    _items[index] = product;
    addUpdateInfo(product);
    notifyListeners();
  }

  Future<void> addUpdateInfo(Obra element) async {
    int index = _items.indexWhere((p) => p.id == element.id);
    String id;
    
    if(hasInternet){
      if (index >= 0) {
        await http.patch(
          Uri.parse('${Constants.OBRA_URL}/${element.id}.json'),
          body: jsonEncode(
            {
                "enterprise": element.enterprise,
                "responsible": element.responsible,
                "owner": element.owner,
                "address": element.address,
                "image": element.image,
                "products": element.products,
                "lastUpdated": element.lastUpdated.toIso8601String(),
            },
          ),
        );
        await http.post(
          Uri.parse('${Constants.SYNC_URL}.json'),
          body: jsonEncode(
            {
              "classId": element.id,
              "tableName": 'obras',
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
        'tableName': 'obras',
        'crud': 'update'
      };
      await DB.insert('sync', syncInfo);
    }
    element.lastUpdated = DateTime.now();
    await DB.updateInfo('obras', element.id, element.toMapSQL());
  }

  Future<void> removeObra(Obra obra) async {
    _items.remove(obra);
    addRemovalInfo(obra);
    notifyListeners();
  }

  Future<void> addRemovalInfo(Obra product) async {
    List<Map<String, dynamic>> fireSync = [];
    if(hasInternet == true){
      product.toggleDeletion();
      await http.post(
        Uri.parse('${Constants.SYNC_URL}.json'),
        body: jsonEncode(
          {
            "classId": product.id,
            "tableName": 'obras',
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
        'tableName': 'obras',
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
    await DB.deleteInfo("obras", product.id);
  }
}  