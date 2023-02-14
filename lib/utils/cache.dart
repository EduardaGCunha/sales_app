
import 'package:shared_preferences/shared_preferences.dart';

import 'connectivity.dart';


class Cache {
  static final String hasInternet = 'hasInternet'; 
  //static final String cacheObra = 'cacheObra';

  Future<bool> setHasInternet() async {
    String value = '';
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool hasInternetVar = await hasInternetConnection();
    if(hasInternetVar == true){
      value = 'yes';
    }else{
      value = 'no';
    }

    bool result = await prefs.setString(hasInternet, value);
    
    return result;
  }

  

  Future<String> getHasInternet() async {
    try{
      SharedPreferences prefs = await SharedPreferences.getInstance();

      var result = prefs.getString(hasInternet);
      print(result.toString());

      if(result != null){
        return result.toString();
      }
    }
    catch(err){
      print(err);
    }
    return 'null';
  }


  // Future<bool> setObraId(String id) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();

  //   bool result = await prefs.setString(obraId, id);
    
  //   return result;
  // }

  // Future<String> getObraId() async {
  //   try{
  //     SharedPreferences prefs = await SharedPreferences.getInstance();

  //     var result = prefs.getString(obraId);
  //     print(result.toString());

  //     if(result != null){
  //       return result.toString();
  //     }
  //   }
  //   catch(err){
  //     print(err);
  //   }
  //   return 'null';
  // }
}
