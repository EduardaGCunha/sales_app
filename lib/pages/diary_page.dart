

import 'package:flutter/material.dart';
import 'package:sales_app/models/diary.dart';

import '../utils/app_routes.dart';

// ignore: must_be_immutable
class DiaryPage extends StatelessWidget {
  List<Diary> diaries;
  String matchmakingId;

  DiaryPage({
    Key? key,
    required this.diaries,
    required this.matchmakingId,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 72, 87, 121),
      body: SingleChildScrollView(
        child: diaries.isEmpty
        ? Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(top: 150),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 200,
                    child: Image.asset(
                      'lib/images/waiting.png',
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),
          ) 
          : Column(
            children: [
              
            ],
          )
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor:const Color.fromARGB(255, 211, 179, 90),
        label: const Text('Adicionar Diário'),
        icon: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).pushNamed(AppRoutes.DIARY_FORM, arguments: {
            "id": matchmakingId,
          });
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}