
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_app/models/diary.dart';
import 'package:sales_app/models/diary_list.dart';

import '../utils/app_routes.dart';
import 'diary_item.dart';

class DiaryGrid extends StatelessWidget {
  final String matchmakingId;
  const DiaryGrid({ Key? key, required this.matchmakingId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DiaryList>(context);
    final List<Diary> stages = provider.allMatchingDiaries(matchmakingId);
    
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 72, 87, 121),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: ListView.builder(
          itemCount: stages.length,
          itemBuilder: (ctx,i) => ChangeNotifierProvider.value(
            value: stages[i],
            child: DiaryItem(),
          ),
        ),
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