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
                  color: const Color.fromARGB(255, 211, 179, 90),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.picture_as_pdf, size: 50, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Projeto',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.engineering, color: Color.fromARGB(255, 72, 87, 121),),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(widget.project.engineer),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.house, color: Color.fromARGB(255, 72, 87, 121),),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text('Obra Civil: ${widget.project.civil ? 'Sim' : 'Não'}'),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.bolt, color: Color.fromARGB(255, 72, 87, 121),),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text('Obra Elétrica: ${widget.project.eletrical ? 'Sim' : 'Não'}'),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.monetization_on, color: Color.fromARGB(255, 72, 87, 121),),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text('Financiamento: ${widget.project.financial ? 'Sim' : 'Não'}'),
                      ),
                    ],
                  ),
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