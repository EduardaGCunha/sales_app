

// ignore_for_file: constant_identifier_names, unused_field, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:sales_app/models/diary.dart';
import 'package:sales_app/models/diary_list.dart';
import 'package:sales_app/models/obra.dart';

import '../components/diary_grid.dart';
import '../models/project.dart';
import '../models/project_list.dart';
import 'data_page.dart';


enum FilterOptions {
  Andamento,
  All,
}

class ObraDetail extends StatefulWidget {
  const ObraDetail({ Key? key}) : super(key: key);

  @override
  State<ObraDetail> createState() => _ObraDetailState();
}

class _ObraDetailState extends State<ObraDetail> with TickerProviderStateMixin{
  bool _isLoading = true;
  bool _isVisible = true;
  double percentage = 0.0;


  @override
  Widget build(BuildContext context) {
    List<String> allPhases = ['Phase1', 'Phase2', 'Phase3', 'Phase4'];

    final obra = ModalRoute.of(context)?.settings.arguments as Obra;
    TabController tabController = TabController(length: 2, vsync: this);
    dynamic provider = Provider.of<ProjectList>(context);
    final List<Project> loadedProjects = provider.items; 
    provider = Provider.of<DiaryList>(context);
    final List<Diary> loadedDiaries = provider.items; 

    List<Diary> copiedDiaries = loadedDiaries;
    copiedDiaries.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
    Diary mostRecent = copiedDiaries.first;

    for(int i = 0; i < allPhases.length; i++){
      if(allPhases[i] == mostRecent.currentPhase){
        percentage = (i+1)/allPhases.length;
      }
    }

    return Scaffold(
    backgroundColor: const Color.fromARGB(255, 72, 87, 121),
    body: CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          expandedHeight: 200.0,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://www.grainsystems.com/content/dam/public/grain-and-protein/grain-systems/product-images/storage/evo-50/4024-EVO24-1440.jpg',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromARGB(75, 108, 114, 211),
                        Color.fromARGB(255, 25, 42, 68),
                      ],
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      obra.enterprise,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 10,),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: LinearPercentIndicator(
                        width: MediaQuery.of(context).size.width-20,
                        animation: true,
                        lineHeight: 20,
                        animationDuration: 1000,
                        percent: percentage,
                        center: Text(
                          '${(percentage * 100).toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        linearGradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 243, 212, 33),
                            Color.fromARGB(255, 250, 224, 109),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        backgroundColor: Colors.white.withOpacity(0.4),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
        SliverFillRemaining(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 39, 62, 97),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(255, 10, 30, 61).withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const TabBar(
                    tabs: [
                      Tab(text: 'Dados'),
                      Tab(text: 'Diários'),
                    ],
                    labelColor: Colors.white,
                    indicatorColor: Color.fromARGB(255, 255, 233, 35),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      DataPage(projects: loadedProjects, matchmakingId: obra.id),
                      DiaryGrid(matchmakingId: obra.id,)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
  }
}