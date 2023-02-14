// ignore_for_file: avoid_classes_with_only_static_members

import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:sales_app/models/product.dart';

import '../utils/connectivity.dart';
import '../utils/db.dart';
// import 'package:control/utils/util.dart';
// import '../validation/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class ProductList with ChangeNotifier {  
  bool hasInternet = false; 
  List<Product> _items = [];
  List<Product> firebaseItems = [];
  List<Product> newProducts = [];
  int countProducts = 0;
  int checkFirebase = 1;
  List<Product> needUpdate = [];

  List<Product> get items => [..._items];

  Future<void> loadProducts() async {
    _items.clear();
    List<Product> products = [];
    List data = await DB.getInfoFromDb('products');
    if(data.isNotEmpty){
      products = data.map((e) => Product.fromSQLMap(e)).toList();
      for(var obra in products){
        _items.add(obra);
      }
    }
    notifyListeners();
  }

  onLoad() async {
    hasInternet = await hasInternetConnection();
  }

  // List<Product> get andamentoItems => _items.where((prod) => prod.isComplete).toList();


  // int get itemsCount {
  //   return _items.length;
  // }

  // bool getSpecificObra(String id){
  //   if(_items.isEmpty){
  //     return false;
  //   }
  //   return _items.where((p) => p.id == id).toList().isEmpty ? true : false;
  // }

  // addToFirebase() async {
  //   final List<Obra> loadedObra = await DB.getObrasFromDB('obras');
  //     checkFirebase = 1;
  //     countObras = 1;
  //     for(var item in loadedObra){
  //       if(item.isDeleted == false && item.needFirebase == true){
  //         item.needFirebase = false;
  //         await DB.updateInfo('obras', item.id, item.toMapSQL());
  //         await addProduct(item);
  //       }
  //     }
  //   countObras = 0;
  // }

  // Future<void> checkData() async {
  //   hasInternet = true;
  //   final List<Obra> loadedObras = await DB.getObrasFromDB('obras');
    
  //   final response = await http.get(Uri.parse('${Constants.PRODUCT_BASE_URL}.json'),);
  //   if (response.body == 'null') return;
  //   Map<String, dynamic> data = jsonDecode(response.body);
  //   data.forEach((productId, productData) {
  //       firebaseItems.add(
  //         Obra(
  //           id: productId,
  //           lastUpdated: DateTime.parse(productData['lastUpdated']),
  //           name: productData['name'],
  //           engineer: productData['engineer'],
  //           address: productData['address'],
  //           owner: productData['owner'],
  //           isDeleted: checkBool(productData['isDeleted']),
  //           needFirebase: checkBool(productData['needFirebase']),
  //         ),
  //       );
  //   });
  

  //   //if there's nothing on each;
  //   if(firebaseItems.isEmpty && loadedObras.isEmpty){
  //     return;
  //   }

  //   //adding if there's nothing on firebase;
  //   if(firebaseItems.isEmpty && loadedObras.isNotEmpty){
  //     countObras = 1;
  //     for(var obra in loadedObras){
  //       await addProduct(obra);
  //     }
  //     countObras = 0;
  //   }

  //   //adding if there's nothing on SQL;
  //   if(loadedObras.isEmpty && firebaseItems.isNotEmpty){
  //     List<Obra> newInsert = firebaseItems.where((element) => !element.isDeleted).toList();
  //     for(var obra in newInsert){
  //       await DB.insert('obras', obra.toMapSQL());
  //     }
  //   }else if(firebaseItems.isEmpty && loadedObras.isNotEmpty){
  //     countObras = 1;
  //     for(var obra in loadedObras){
  //       await addProduct(obra);
  //     }
  //     countObras = 0;
  //   }

  //   //ADDING IF NEEDED
  //   //to firebase
  //   List<Obra> addingStuff = loadedObras.where((element) => element.needFirebase).toList();
  //   for (var element in addingStuff) {
  //     countObras = 1;
  //     await addProduct(element);
  //     countObras = 0;
  //   }

  //   //to SQL
  //   addingStuff = firebaseItems.where((element) => !getSpecificObra(element.id) && !element.isDeleted).toList();
  //   for (var element in addingStuff) {
  //     await DB.insert('obras', element.toMapSQL());
  //   }

  //   //DELETING IF NEEDED
  //   //from firebase
  //   List<Obra> deletingStuff = loadedObras.where((element) => element.isDeleted).toList();
  //   for (var element in deletingStuff) {
  //     await http.patch(Uri.parse('${Constants.PRODUCT_BASE_URL}/${element.id}.json'),body: jsonEncode({"isDeleted": element.isDeleted}),);
  //     await DB.deleteInfo('obras', element.id);
  //   }
    
  //   //from sql
  //   deletingStuff = firebaseItems.where((element) => element.isDeleted && !getSpecificObra(element.id)).toList();
  //   for (var element in deletingStuff) {
  //      await DB.deleteInfo('obras', element.id);
  //   }

  //   //UPDATING IF NEEDED
  //   //updating SQL
  //   List<Obra> needUpdateSQL = loadedObras.where(((element) => element.lastUpdated.isBefore(DateTime.now().subtract(const Duration(days: 14))))).toList();
  //   for(var obra in needUpdateSQL){
  //     Obra matchingObra = firebaseItems.where((element) => element.id == obra.id,).toList().first;
  //     if((matchingObra.lastUpdated).isBefore(obra.lastUpdated)){
  //       await http.patch(Uri.parse('${Constants.PRODUCT_BASE_URL}/${obra.id}.json'),
  //           body: jsonEncode(
  //             { 
  //               "name": obra.name,
  //               "engineer": obra.engineer,
  //               "owner": obra.owner,
  //               "address": obra.address,
  //               "lastUpdated": DateTime.now().toIso8601String(),
  //               "isComplete": obra.isComplete,
  //               "needFirebase": false,
  //             }
  //           ),
  //       );
  //     }else if((matchingObra.lastUpdated).isAfter(obra.lastUpdated)){
  //       await DB.updateInfo('obras', obra.id, matchingObra.toMapSQL());
  //     }
  //   }

  //   //updating Firebase
  //   List<Obra> needUpdateFirebase = firebaseItems.where(((element) => element.lastUpdated.isBefore(DateTime.now().subtract(const Duration(minutes: 10))))).toList();
  //   for(var obra in needUpdateFirebase){
  //     List<Obra> input = loadedObras.where((element) => element.id == obra.id,).toList();
  //     if(input.isEmpty){
  //       return;
  //     }else{
  //       Obra matchingObra = input.first;
  //       if((matchingObra.lastUpdated).isBefore(obra.lastUpdated)){
  //         await DB.updateInfo('obras', matchingObra.id, obra.toMapSQL());
  //       }else if((matchingObra.lastUpdated).isAfter(obra.lastUpdated)){
  //         await http.patch(Uri.parse('${Constants.PRODUCT_BASE_URL}/${obra.id}.json'),
  //           body: jsonEncode(
  //             { 
  //               "name": obra.name,
  //               "engineer": obra.engineer,
  //               "owner": obra.owner,
  //               "address": obra.address,
  //               "lastUpdated": DateTime.now().toIso8601String(),
  //               "isComplete": obra.isComplete,
  //               "needFirebase": false,
  //             }
  //           ),
  //         );
  //       }
  //     }
  //   }
  // }

  Future<void> saveProduct(Map<String, Object> data) async {
    await onLoad();

    bool hasId = data['id'] != null;

    final product = Product(
      id: hasId ? data['id'] as String : Random().nextDouble().toString(),
      name: data['name'] as String,
      lastUpdated: DateTime.now(),
      description: data['description'] as String,
      category: data['category'] as List<String>,
      aplications: data['aplications'] as String,
      characteristics: data['characteristics'] as String,
    );

    if (hasId) {
      if(hasInternet == true && needUpdate.isNotEmpty){
        for(var element in needUpdate){
          await updateProduct(element);
        }
      }
      return updateProduct(product);
    } else {
      return await addProduct(product);
    }
  }

  Future<void> addProduct(Product product) async {
    final lastUpdated = product.lastUpdated;
    String id;
    bool needFirebase;
    if(hasInternet == true){
      needFirebase = false;
      final response = await http.post(
        Uri.parse('${Constants.PRODUCT_BASE_URL}.json'),
        body: jsonEncode(
          {
            "name": product.name,
            "description": product.description,
            "aplications": product.aplications,
            "characteristics": product.characteristics,
            "lastUpdated": product.lastUpdated.toIso8601String(),
            "needFirebase": needFirebase,
          },
        ),
      );
      id = jsonDecode(response.body)['name'];
    }else{
      id = Random().nextDouble().toString();
      needFirebase = true;
      checkFirebase = 0;
    }

    Product novaProduct = Product(
        id: id,
        lastUpdated: lastUpdated,
        name: product.name,
        category: product.category,
        description: product.description,
        aplications: product.aplications,
        characteristics: product.characteristics,
        needFirebase: needFirebase,
        isDeleted: product.isDeleted,
    );

    //ADDING TO SQL THROUGH ADD FUNCTION
    if(countProducts == 0){
      await DB.insert('products', novaProduct.toMapSQL());
    }

    await loadProducts();
    notifyListeners();
  }



 
  Future<void> updateProduct(Product product) async {
    int index = _items.indexWhere((p) => p.id == product.id);
    
    if(hasInternet == true){
      if (index >= 0) {
        await http.patch(
          Uri.parse('${Constants.PRODUCT_BASE_URL}/${product.id}.json'),
          body: jsonEncode(
            {
              "name": product.name,
              "description": product.description,
              "aplications": product.aplications,
              "characteristics": product.characteristics,
              "lastUpdated": product.lastUpdated.toIso8601String(),
            },
          ),
        );
        _items[index] = product;
      }
    }
    product.lastUpdated = DateTime.now();
    await DB.updateInfo('products', product.id, product.toMapSQL());
    await loadProducts();
    notifyListeners();
  }

  Future<void> removeProduct(Product product) async {
    if(hasInternet == true){
      product.toggleDeletion();
      await DB.deleteInfo("products", product.id);
    }else{
      product.isDeleted = true;
      await DB.updateInfo('products', product.id, product.toMapSQL());
    }
    _items.remove(product);
    notifyListeners();
  }
}