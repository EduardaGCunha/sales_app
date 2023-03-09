
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../utils/bool.dart';
import '../utils/constants.dart';
import 'package:http/http.dart' as http;

class Project with ChangeNotifier{
  String id;
  String firebaseId;
  String engineer;
  String matchmakingId;
  DateTime lastUpdated;
  DateTime begDate;
  DateTime endDate;
  bool isDeleted;
  bool civil;
  bool eletrical;
  bool financial;
  File? pdfFile; // New property to store the PDF file

  Project({
    required this.id,
    required this.firebaseId,
    required this.begDate,
    required this.endDate,
    required this.engineer,
    required this.lastUpdated,
    required this.matchmakingId,
    this.isDeleted = false,
    this.civil = false,
    this.eletrical = false,
    this.financial = false,
    this.pdfFile, // Add the PDF file parameter
  });

  Map<String, dynamic> toMapSQL() {
    return {
      'id': id,
      'firebaseId': firebaseId,
      'engineer': engineer,
      'lastUpdated': lastUpdated.toIso8601String(),
      'begDate': begDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isDeleted': boolToSql(isDeleted),
      'civil': boolToSql(civil),
      'eletrical': boolToSql(eletrical),
      'financial': boolToSql(financial),
      'matchmakingId': matchmakingId,
      'pdfFile': pdfFile?.path, // Include the PDF file path in the map
    };
  }

  factory Project.fromSQLMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] as String,
      engineer: map['engineer'] as String,
      firebaseId: map['firebaseId'] as String,
      matchmakingId: map['matchmakingId'] as String,
      lastUpdated: DateTime.parse(map['lastUpdated']),
      begDate: DateTime.parse(map['begDate']),
      endDate: DateTime.parse(map['endDate']),
      isDeleted: map['isDeleted'] != null? checkBool(map['isDeleted']) : false,
      civil: map['civil'] != null? checkBool(map['civil']) : false,
      eletrical: map['eletrical'] != null? checkBool(map['eletrical']) : false,
      financial: map['financial'] != null? checkBool(map['financial']) : false,
      pdfFile: map['pdfFile'] != null ? File(map['pdfFile']) : null, // Create a File object from the stored PDF file path
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