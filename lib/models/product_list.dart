// ignore_for_file: avoid_classes_with_only_static_members

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:sales_app/models/product.dart';

import '../utils/bool.dart';
import '../utils/connectivity.dart';
import '../utils/db.dart';
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

    Future<void> synchronizedAdding(List<Product> firebase, List<Product> SQL, String table) async {
      final productService = ProductList();
      List<Product> fireNewInfo = [];
      List<Product> sqlNewInfo = [];
      if(SQL.isEmpty && firebase.isNotEmpty){
        fireNewInfo = firebase.where((element) => !element.isDeleted).toList();
      }else if(firebase.isEmpty && SQL.isNotEmpty){
        sqlNewInfo = SQL; 
      }else{
        fireNewInfo = SQL.where((element) => element.needFirebase).toList();
        sqlNewInfo = firebase.where((element) => !getSpecificProduct(element.id) && !element.isDeleted).toList();
      }

      for(var obra in fireNewInfo){
        await DB.insert(table, obra.toMapSQL());
      }
      countProducts = 1;
      for(var product in sqlNewInfo){
        await addProduct(product, File(product.image));
      }
      countProducts = 0;

      return; 
    }

  Future<void> synchronizedDeleting(List<Product> toBeDeleted, bool fireBase) async {

    for (var element in toBeDeleted) {
      fireBase ? await http.patch(Uri.parse('${Constants.PRODUCT_BASE_URL}/${element.id}.json'),body: jsonEncode({"isDeleted": element.isDeleted}),) : null;
      await DB.deleteInfo('products', element.id);
    }
  }

  Future<void> synchronizedUpdating(List<Product> SQL, List<Product> firebase) async {
    List<Product> newInfoFire = [];
    List<Product> newInfoSQL = [];

    List<Product> needUpdateSQL = 
      SQL.where(((element) => element.lastUpdated.isAfter(DateTime.now().subtract(const Duration(days: 14))))).toList();
    List<Product> needUpdateFirebase = 
      firebase.where(((element) => element.lastUpdated.isAfter(DateTime.now().subtract(const Duration(days: 14))))).toList();

    final firebaseMap = {for (final obra in firebase) obra.id: obra};
    final sqlMap = {for (final obra in SQL) obra.id: obra};

    for(var obra in needUpdateSQL){
      final matchingObra = firebaseMap[obra.id];
      if(matchingObra == null){
        return;
      }
      if((matchingObra.lastUpdated).isBefore(obra.lastUpdated)){
        newInfoFire.add(obra);
      }else if((matchingObra.lastUpdated).isAfter(obra.lastUpdated)){
        newInfoSQL.add(matchingObra);
      }
    }

    //updating Firebase
    for(var obra in needUpdateFirebase){
       final matchingObra = sqlMap[obra.id];
      if (matchingObra == null) {
        // Handle error: matching Obra not found in SQL
        continue;
      }
      if((matchingObra.lastUpdated).isBefore(obra.lastUpdated)){
        newInfoSQL.add(obra);
      }else if((matchingObra.lastUpdated).isAfter(obra.lastUpdated)){
        newInfoFire.add(matchingObra);
      }
      
    }

    for(var item in newInfoSQL){
      await DB.updateInfo('products', item.id, item.toMapSQL());
    }
    for(var obra in newInfoFire){
      await http.patch(Uri.parse('${Constants.PRODUCT_BASE_URL}/${obra.id}.json'),
        body: jsonEncode(
          { 
            "name": obra.name,
            "description": obra.description,
            "aplications": obra.aplications,
            "characteristics": obra.characteristics,
            "lastUpdated": obra.lastUpdated.toIso8601String(),
            "needFirebase": false,
          }
        ),
      );
    }
  }


   Future<void> checkData() async {
    await loadProducts();
    List<Product> loadedProducts = _items;
    List<Product> toBeDeleted = [];
    
    //getting stuff from firebase
    final response = await http.get(Uri.parse('${Constants.PRODUCT_BASE_URL}.json'),);
    if (response.body == 'null') return;
    Map<String, dynamic> data = jsonDecode(response.body);
    data.forEach((productId, productData) {
        firebaseItems.add(
          Product(
            id: productId,
            lastUpdated: DateTime.parse(productData['lastUpdated']),
            name: productData['name'],
            description: productData['description'],
            characteristics: productData['characteristics'],
            aplications: productData['aplications'],
            image: productData['image'],
            category: productData['category'] ?? [],
            isDeleted: checkBool(productData['isDeleted']),
            needFirebase: checkBool(productData['needFirebase']),
          ),
        );
    });
  

    if(firebaseItems.isEmpty && loadedProducts.isEmpty){
      return;
    }
    await synchronizedAdding(firebaseItems, loadedProducts, 'products');
    toBeDeleted = loadedProducts.where((element) => element.isDeleted).toList();
    await synchronizedDeleting(toBeDeleted, true);
    toBeDeleted = firebaseItems.where((element) => element.isDeleted && !getSpecificProduct(element.id)).toList();
    await synchronizedDeleting(toBeDeleted, false);
    await synchronizedUpdating(loadedProducts, firebaseItems);

  }

  // List<Product> get andamentoItems => _items.where((prod) => prod.isComplete).toList();


  // int get itemsCount {
  //   return _items.length;
  // }

  bool getSpecificProduct(String id){
    if(_items.isEmpty){
      return false;
    }
    return _items.where((p) => p.id == id).toList().isEmpty ? true : false;
  }


  Future<String> uploadImageFirebase(Product product, File image) async{
    final storage = FirebaseStorage.instance;
    final imageRef = storage.ref().child('user_images').child(product.id);
    await imageRef.putFile(image).whenComplete(() {});
    return await imageRef.getDownloadURL();
  }

  Future<void> saveProduct(Map<String, Object> data, File? image) async {
    await onLoad();

    bool hasId = data['id'] != null;

    final product = Product(
      id: hasId ? data['id'] as String : Random().nextDouble().toString(),
      name: data['name'] as String,
      image: '',
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
      return await addProduct(product, image);
    }
  }

  Future<void> addProduct(Product product, File? image) async {
    final lastUpdated = product.lastUpdated;
    String id;
    bool needFirebase;
    String imageURL = '';
    if(hasInternet == true){
      if(image != null){
        imageURL = await uploadImageFirebase(product, image);
      }
      final response = await http.post(
        Uri.parse('${Constants.PRODUCT_BASE_URL}.json'),
        body: jsonEncode(
          {
            "image": imageURL,
            "name": product.name,
            "description": product.description,
            "aplications": product.aplications,
            "characteristics": product.characteristics,
            "lastUpdated": product.lastUpdated.toIso8601String(),
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
        image: image == null? '': image.path,
        name: product.name,
        category: product.category,
        description: product.description,
        aplications: product.aplications,
        characteristics: product.characteristics,
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