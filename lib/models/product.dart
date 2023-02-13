// import 'dart:convert';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../utils/bool.dart';
// import 'package:http/http.dart' as http;

class Product with ChangeNotifier{
  final String id;
  final String name;
  final String description;
  final String aplications;
  final String characteristics;
  DateTime lastUpdated;
  bool hasInternet = false;
  bool isDeleted;
  bool needFirebase;

  Product({
    required this.id,
    required this.name,
    required this.aplications,
    required this.description,
    required this.characteristics,
    required this.lastUpdated,
    this.isDeleted = false,
    this.needFirebase = false,
  });

  Map<String, dynamic> toMapSQL() {
    return {
      'id': id,
      'name': name,
      'aplications': aplications,
      'characteristics': characteristics,
      'lastUpdated': lastUpdated.toIso8601String(),
      'isDeleted': boolToSql(isDeleted),
      'description': description,
      'needFirebase': boolToSql(needFirebase),
    };
  }

  factory Product.fromSQLMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      aplications: map['aplications'] as String,
      characteristics: map['characteristics'] as String,
      description: map['description'] != null? map['description'] as String: '',
      lastUpdated: DateTime.parse(map['lastUpdated']),
      isDeleted: map['isDeleted'] != null? checkBool(map['isDeleted']) : false,
      needFirebase: map['needFirebase'] != null? checkBool(map['needFirebase']) : false,
    );
  }

  void toggleDeleted(){
    isDeleted = !isDeleted;
    notifyListeners();
  }

  // Future<void> toggleDeletion() async {
  //   try {
  //     toggleDeleted();

  //     final response = await http.patch(
  //       Uri.parse('${Constants.ITEM_BASE_URL}/$id.json'),
  //       body: jsonEncode({"isDeleted": isDeleted}),
  //     );

  //     if (response.statusCode >= 400) {
  //       toggleDeleted();
  //     }
  //   } catch (_) {
  //     toggleDeleted();
  //   }

  //   notifyListeners();
  // }

  // onLoad() async {
  //   hasInternet = await hasInternetConnection();
  // }

} 