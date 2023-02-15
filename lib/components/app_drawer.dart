
import 'package:flutter/material.dart';

class AppDrawer extends StatefulWidget {

  const AppDrawer({ Key? key}) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {


  @override
  Widget build(BuildContext context) {
  
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(0),
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 107, 177, 235),
            ), 
            child: SizedBox(
              height: 100,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close)),
                    ],
                  )
                ],
              ),
            ),//BoxDecoration
        ),
        ]
    ),
    );
  }
}