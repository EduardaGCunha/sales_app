import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/constants.dart';
import '../utils/db.dart';
import 'package:http/http.dart' as http;

typedef AddToFirebase = Future<void> Function(dynamic element, bool isUpdate, {dynamic parent});

class SyncDB with ChangeNotifier{
  final List<Map<String, dynamic>> _items = [];
  static Map<String, dynamic> parentLookup = {};
  

  Future<void> loadProducts() async {
    _items.clear();
    List data = await DB.getInfoFromDb('sync'); //create new DB
    for(var place in data){
      _items.add(place);
    }
  }

  
  Future<void> loadData() async {
    await loadProducts();
    List<Map<String, dynamic>> sqlSync = _items;
    List<Map<String, dynamic>> fireSync = [];
    List<Map<String, dynamic>> sClSync = [];
    List<Map<String, dynamic>> fClSync = [];

    final response = await http.get(Uri.parse('${Constants.SYNC_URL}.json'),); //
    if (response.body != 'null'){
      Map<String, dynamic> data = jsonDecode(response.body);
      data.forEach((productId, productData) {
          Map<String, dynamic> itemMap = {
          'id': productId,
          'classId': productData['classId'],
          'createTime': DateTime.parse(productData['createTime']),
          'tableName': productData['tableName'],
          'crud': productData['crud'],
        };
        fireSync.add(itemMap);
      });
    }

    if(fireSync.isEmpty && sqlSync.isEmpty){
      return;
    }

    // sClSync = sqlSync.where((element) => element['tableName'] == 'obras').toList();
    // fClSync = fireSync.where((element) => element['tableName'] == 'obras').toList();
    // if(sClSync.isNotEmpty || fClSync.isNotEmpty){
    //   await ObraList().syncData(fClSync, sClSync);
    // }

    List<Map<String,dynamic>> removeSync = 
      fireSync.where((element) => element['createTime'].isBefore(DateTime.now().subtract(const Duration(days: 3)))).toList();  
    
    try {
      await Future.wait(removeSync.map((item) => http.delete(
        Uri.parse('${Constants.SYNC_URL}/${item['id']}.json'),
      )));
    } catch (error) {
      // Handle any errors that occur during the HTTP requests.
      print('Error deleting items: $error');
    }

  }


  Future<void> commonSyncData(fireSync, sqlSync, firebaseLookup, matchLookup, sqlLookup, AddToFirebase function, table, baseUrl) async{
    List<Map<String, dynamic>> fSync = fireSync.where((element) => element['crud'] == 'add').toList();
    List<Map<String, dynamic>> sSync = sqlSync.where((element) => element['crud'] == 'add').toList(); 

    if(fSync.isNotEmpty || sSync.isNotEmpty){
      List newInfoFire = await SyncDB().syncAdding(fSync, sSync, firebaseLookup, matchLookup, sqlLookup, table);
      if(newInfoFire.isNotEmpty){
        for(var obra in newInfoFire){
          function(obra, false, parent: parentLookup);
        }
      }
    }

    fSync = fireSync.where((element) => element['crud'] == 'delete').toList();
    sSync = sqlSync.where((element) => element['crud'] == 'delete').toList(); 
    if(fSync.isNotEmpty || sSync.isNotEmpty){
      await SyncDB().syncDelete(sSync, fSync, firebaseLookup, matchLookup, sqlLookup, table, baseUrl);
    }

    fSync = fireSync.where((element) => element['crud'] == 'update').toList();
    sSync = sqlSync.where((element) => element['crud'] == 'update').toList(); 
    if(fSync.isNotEmpty || sSync.isNotEmpty){
      List newInfoFire = await SyncDB().syncUpdate(sSync, fSync, firebaseLookup, matchLookup, table);
      if(newInfoFire.isNotEmpty){
        for(var obra in newInfoFire){
          function(obra, true);
        }
      }
    }

    parentLookup = sqlLookup;
    notifyListeners();
  }

  Future<void> syncDelete(sSync, fSync, firebaseLookup, matchLookup, sqlLookup, String table, baseUrl) async {
    if(fSync.isNotEmpty){
       for(var sync in fSync){
        final element = firebaseLookup[sync['classId']];
        final checker = matchLookup[sync['classId']];
        if(element != null && checker != null){
          await DB.deleteInfo(table, element.id);
        }
      }
    }

    if(sSync.isNotEmpty){
      for(var sync in sSync){
        final element = sqlLookup[sync['classId']];
          if(element == null){
            String id = sync['id'];
            await http.patch(
              Uri.parse('$baseUrl/$id.json'),
              body: jsonEncode({"isDeleted": true}),
            );
          await DB.deleteInfo('sync', sync['id'], crud: 'delete');
        }
      }
    }
  }

   Future<List> syncUpdate(sSync, fSync, firebaseLookup, matchLookup, table) async {
    List newInfoFire = [];
    List newInfoSQL = [];
    List<Map<String, dynamic>> removeSyncSQL = [];

    if(fSync.isNotEmpty){
       for(var sync in fSync){
        final fireInfo = firebaseLookup[sync['classId']];
        final sqlInfo = matchLookup[sync['classId']];
        if(fireInfo != null && sqlInfo != null){
          if((fireInfo.lastUpdated).isBefore(sqlInfo.lastUpdated)){
            newInfoFire.add(sqlInfo); //need to update firebase
          }else if((fireInfo.lastUpdated).isAfter(sqlInfo.lastUpdated)){
            newInfoSQL.add(fireInfo);  //need to update sql
          }
        }
      }
    }

    if(sSync.isNotEmpty){
      for(var sync in fSync){
        final sqlInfo = matchLookup[sync['classId']];
        final fireInfo = firebaseLookup[sync['classId']];
        if(sqlInfo != null && fireInfo != null){
          if((sqlInfo.lastUpdated).isBefore(fireInfo.lastUpdated)){
            newInfoSQL.add(fireInfo); //update sql
          }else if((sqlInfo.lastUpdated).isAfter(fireInfo.lastUpdated)){
            newInfoFire.add(sqlInfo); //update firebase
          }
        }
      }
    }

    if(removeSyncSQL.isNotEmpty){
      for(var sync in removeSyncSQL){
        await DB.deleteInfo('sync', sync['id'], crud: 'update');
      }
    }

    if(newInfoSQL.isNotEmpty){
      for(var item in newInfoSQL){
        await DB.updateInfo(table, item.id, item.toMapSQL());
      }
    }
    return newInfoFire;
  }

  Future<List> syncAdding(fSync, sSync, firebaseLookup, matchLookup, sqlLookup, table, {isEva}) async {
    List infoFromSQL = [];

    if(fSync.isNotEmpty){
      final elementsToInsert = fSync
        .where((sync) => firebaseLookup[sync['classId']] != null && matchLookup[sync['classId']] == null)
        .map((sync) => firebaseLookup[sync['classId']]!.toMapSQL())
        .toList();

      for (var syncItem in elementsToInsert) {
        if(syncItem['image'] != null ){
          Directory appDocDir = await getApplicationDocumentsDirectory();
          await downloadImageFromFirebase(syncItem['image'], appDocDir);

          syncItem['image'] = '${appDocDir.path}/${syncItem['image'].split('/').last}';
        }

      }
    
      if(elementsToInsert.isNotEmpty){
        await DB.batch(table, elementsToInsert.cast<Map<String, dynamic>>());
      }
    }

    if(sSync.isNotEmpty){
      for(var sync in sSync){
        final element = sqlLookup[sync['id']];
        if(element != null){
          infoFromSQL.add(element);
        }
      }
      return infoFromSQL;
    }
    return []; 
  }

  Future<void> downloadImageFromFirebase(String imageDownloadUrl, Directory appDocDir) async {
    
    // Extract the image filename from the download URL
    final imageFileName = imageDownloadUrl.split('/').last;

    // Create a file in the app's document directory with the same name as the image
    final localFile = File('${appDocDir.path}/$imageFileName');

    // Download the image from Firebase and save it to the local file
    await FirebaseStorage.instance
        .refFromURL(imageDownloadUrl)
        .writeToFile(localFile);
  }
}