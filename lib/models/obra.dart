
import 'dart:convert';

import 'package:flutter/material.dart';

import '../utils/bool.dart';
import '../utils/constants.dart';
import 'package:http/http.dart' as http;

class Obra with ChangeNotifier{
  final String id;
  final String enterprise;
  final String address;
  final String owner;
  final List<String> image;
  final List<String> products;
  final DateTime data;
  DateTime lastUpdated;
  bool hasInternet = false;
  bool isDeleted;
  bool needFirebase;

  Obra({
    required this.id,
    required this.enterprise,
    required this.image,
    required this.products,
    required this.owner,
    required this.address,
    required this.data,
    required this.lastUpdated,
    this.isDeleted = false,
    this.needFirebase = false,
  });

  Map<String, dynamic> toMapSQL() {
    return {
      'id': id,
      'enterprise': enterprise,
      'data': data,
      'image': image.join(','),
      'products': products.join(','),
      'lastUpdated': lastUpdated.toIso8601String(),
      'isDeleted': boolToSql(isDeleted),
      'address': address,
      'needFirebase': boolToSql(needFirebase),
    };
  }

  factory Obra.fromSQLMap(Map<String, dynamic> map) {
    return Obra(
      id: map['id'] as String,
      enterprise: map['enterprise'] as String,
      image: map['image'] as List<String>,
      products: map['products'] as List<String>,
      owner: map['owner'] as String,
      address: map['address'] != null? map['address'] as String: '',
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