// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sales_app/models/diary.dart';
import '../models/project.dart';

//ImagePicker()
class DiaryItem extends StatefulWidget {

  DiaryItem();


  @override
  State<DiaryItem> createState() => _DiaryItemState();

}

class _DiaryItemState extends State<DiaryItem> {
  @override
    void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final diary = Provider.of<Diary>(context, listen: false);
    return Card(
      color: const Color.fromARGB(255, 32, 52, 82),
      child: InkWell(
        onTap: () {
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 120,
                height: 120,
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('dd').format(diary.date),
                      style: const TextStyle(
                        fontSize: 45,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      DateFormat('MMM').format(diary.date).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  ],
                )
              ),
              const SizedBox(width: 10),
              Container(
                alignment: Alignment.center,
                width: 150,
                child: Text(
                  diary.currentPhase,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
