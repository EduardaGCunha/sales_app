
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../utils/bool.dart';
import '../utils/constants.dart';
import 'package:http/http.dart' as http;

class Diary with ChangeNotifier{
  String id;
  String firebaseId;
  String description;
  String matchmakingId;
  String initiatedServ;
  String finishedServ;
  String currentPhase;
  DateTime lastUpdated;
  DateTime date;
  bool isDeleted;
  File? images; // New property to store the PDF file

  Diary({
    required this.id,
    required this.firebaseId,
    required this.date,
    required this.description,
    required this.lastUpdated,
    required this.finishedServ,
    required this.initiatedServ,
    required this.currentPhase,
    required this.matchmakingId,
    this.isDeleted = false,
    this.images, // Add the PDF file parameter
  });

  Map<String, dynamic> toMapSQL() {
    return {
      'id': id,
      'firebaseId': firebaseId,
      'description': description,
      'initiatedServ': initiatedServ,
      'finishedServ': finishedServ,
      'currentPhase': currentPhase,
      'lastUpdated': lastUpdated.toIso8601String(),
      'date': date.toIso8601String(),
      'isDeleted': boolToSql(isDeleted),
      'matchmakingId': matchmakingId,
      'images': images?.path, // Include the PDF file path in the map
    };
  }

  factory Diary.fromSQLMap(Map<String, dynamic> map) {
    return Diary(
      id: map['id'] as String,
      description: map['description'] as String,
      firebaseId: map['firebaseId'] as String,
      matchmakingId: map['matchmakingId'] as String,
      currentPhase: map['currentPhase'] as String,
      initiatedServ: map['initiatedServ'] as String,
      finishedServ: map['finishedServ'] as String,
      lastUpdated: DateTime.parse(map['lastUpdated']),
      date: DateTime.parse(map['date']),
      isDeleted: map['isDeleted'] != null? checkBool(map['isDeleted']) : false,
      images: map['images'] != null ? File(map['images']) : null, // Create a File object from the stored PDF file path
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
        Uri.parse('${Constants.DIARY_URL}/$id.json'),
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