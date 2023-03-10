// ignore_for_file: use_key_in_widget_constructors
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

import '../models/project.dart';

//ImagePicker()
class ProjectItem extends StatefulWidget {
  final File? pdf;
  final Project project;

  ProjectItem({this.pdf, required this.project});


  @override
  State<ProjectItem> createState() => _ProjectItemState();

}

class _ProjectItemState extends State<ProjectItem> {
  @override
    void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 72, 87, 121), 
      margin: const EdgeInsets.all(10),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PDFViewer(file: widget.pdf!),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 196, 37),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.picture_as_pdf, size: 50, color: Colors.white),
                    Text(
                      'Projeto',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    'Características',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    )
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const SizedBox(width: 3),
                      const Icon(Icons.engineering, color: Color.fromARGB(255, 255, 196, 37),),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(widget.project.engineer, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500,),),
                      ),
                    ],
                  ),
                  widget.project.civil 
                  ? Row(
                    children: const [
                      Icon(Icons.house, color: Color.fromARGB(255, 255, 196, 37),),
                      SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'Obra Civil',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ) : SizedBox(),
                  widget.project.eletrical ? 
                  Row(
                    children: const [
                      Icon(Icons.bolt, color: Color.fromARGB(255, 255, 196, 37),),
                      SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'Obra Elétrica',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ) : SizedBox(),
                  widget.project.financial? 
                  Row(
                    children: const [
                      Icon(Icons.monetization_on, color: Color.fromARGB(255, 255, 196, 37),),
                      SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'Financiado',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ) : SizedBox(),
                ],
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}


class PDFViewer extends StatelessWidget {
  final File file;

  const PDFViewer({required this.file});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projeto'),
        backgroundColor: const Color.fromARGB(255, 72, 87, 121),
      ),
      body: PDFView(
        filePath: file.path,
        fitEachPage: true,
        enableSwipe: true,
        swipeHorizontal: true,
      ),
    );
  }
}