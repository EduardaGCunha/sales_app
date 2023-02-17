
import 'dart:convert';

import 'package:flutter/material.dart';

import '../utils/bool.dart';
import '../utils/constants.dart';
import 'package:http/http.dart' as http;

class Sales with ChangeNotifier{
  final String id;
  final String name;
  final String description;
  final String preco;
  final DateTime data;
  DateTime lastUpdated;
  bool hasInternet = false;
  bool isDeleted;
  bool needFirebase;

  Sales({
    required this.id,
    required this.name,
    required this.preco,
    required this.description,
    required this.data,
    required this.lastUpdated,
    this.isDeleted = false,
    this.needFirebase = false,
  });

  Map<String, dynamic> toMapSQL() {
    return {
      'id': id,
      'name': name,
      'preco': preco,
      'data': data,
      'lastUpdated': lastUpdated.toIso8601String(),
      'isDeleted': boolToSql(isDeleted),
      'description': description,
      'needFirebase': boolToSql(needFirebase),
    };
  }

  factory Sales.fromSQLMap(Map<String, dynamic> map) {
    return Sales(
      id: map['id'] as String,
      name: map['name'] as String,
      preco: map['preco'] as String,
      description: map['description'] != null? map['description'] as String: '',
      lastUpdated: DateTime.parse(map['lastUpdated']),
      data: DateTime.parse(map['lastUpdated']),
      isDeleted: map['isDeleted'] != null? checkBool(map['isDeleted']) : false,
      needFirebase: map['needFirebase'] != null? checkBool(map['needFirebase']) : false,
    );
  }

  void toggleDeleted(){
    isDeleted = !isDeleted;
    notifyListeners();
  }

  Future<void> toggleDeletion() async {
    try {
      toggleDeleted();

      final response = await http.patch(
        Uri.parse('${Constants.PRODUCT_BASE_URL}/$id.json'),
        body: jsonEncode({"isDeleted": isDeleted}),
      );

      if (response.statusCode >= 400) {
        toggleDeleted();
      }
    } catch (_) {
      toggleDeleted();
    }

    notifyListeners();
  }

} 