
import 'dart:convert';

import 'package:flutter/material.dart';

import '../utils/bool.dart';
import '../utils/constants.dart';
import 'package:http/http.dart' as http;

class Obra with ChangeNotifier{
  String id;
  String enterprise;
  String address;
  String owner;
  String responsible;
  List<String> image;
  List<String> products;
  DateTime data;
  String firebaseId;
  DateTime lastUpdated;
  bool hasInternet = false;
  bool isDeleted;

  Obra({
    required this.id,
    required this.enterprise,
    required this.image,
    required this.products,
    required this.owner,
    required this.responsible,
    required this.address,
    required this.firebaseId,
    required this.data,
    required this.lastUpdated,
    this.isDeleted = false,
  });

  Map<String, dynamic> toMapSQL() {
    return {
      'id': id,
      'enterprise': enterprise,
      'firebaseId': firebaseId,
      'owner': owner,
      'data': data.toIso8601String(),
      'responsible': responsible,
      'image': image.join(','),
      'products': products.join(','),
      'lastUpdated': lastUpdated.toIso8601String(),
      'isDeleted': boolToSql(isDeleted),
      'address': address,
    };
  }

  factory Obra.fromSQLMap(Map<String, dynamic> map) {
    return Obra(
      id: map['id'] as String,
      enterprise: map['enterprise'] as String,
      firebaseId: map['firebaseId'] as String,
      responsible: map['responsible'] as String,
      image: map['image'] != ''? map['image'] as List<String> : [''],
      products: map['products'] != ''? map['products'] as List<String> : [''],
      owner: map['owner'] as String,
      address: map['address'] != null? map['address'] as String: '',
      lastUpdated: DateTime.parse(map['lastUpdated']),
      data: DateTime.parse(map['data']),
      isDeleted: map['isDeleted'] != null? checkBool(map['isDeleted']) : false,
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