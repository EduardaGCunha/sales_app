
import 'dart:io';

import 'package:flutter/material.dart';

import '../components/project_item.dart';
import '../models/project.dart';
import '../utils/app_routes.dart';

// ignore: must_be_immutable
class DataPage extends StatelessWidget {
  List<Project> projects;
  String matchmakingId;

  DataPage({
    Key? key,
    required this.projects,
    required this.matchmakingId,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    File? pdf;
    if(projects.isNotEmpty && projects.first.pdfFile != null){
      pdf = projects.first.pdfFile!;
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 72, 87, 121),
      body: SingleChildScrollView(
        child: projects.isEmpty? Container(
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
            SizedBox(height: 19,),
            ProjectItem(project: projects.first, pdf: pdf,)
          ],
        )
      ),
      floatingActionButton: Visibility(
        visible: projects.isEmpty? true : false,
        child: FloatingActionButton.extended(
          backgroundColor:const Color.fromARGB(255, 211, 179, 90),
          label: const Text('Adicionar Projeto'),
          icon: const Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).pushNamed(AppRoutes.PROJECT_FORM, arguments: {
              "id": matchmakingId,
            });
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}