// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_app/utils/connectivity.dart';

import '../models/product_list.dart';
import '../utils/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 3), (timer) {
     });

    Timer.run(() async => await onLoad());
  }

  Future onLoad() async {
    if(await hasInternetConnection()){
      await Firebase.initializeApp();
      await Provider.of<ProductList>(context, listen: false).checkData();
      await Future.delayed(const Duration(milliseconds: 1500), () {
        Navigator.pushReplacementNamed(context, AppRoutes.PRODUCT_PAGE);
      });
    }
    else{ 
      await Future.delayed(const Duration(milliseconds: 1500), () {
        Navigator.pushReplacementNamed(context, AppRoutes.PRODUCT_PAGE);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 65, 134, 190),
              Color.fromARGB(255, 0, 96, 173),
            ]
          )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Icon(
              Icons.house,
              size: 70,
              color: Colors.white,
            ),
            SizedBox(height: 30,),
            CircularProgressIndicator()
          ],
        ),
      ),
    );
  }
}