// ignore_for_file: use_key_in_widget_constructors
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/obra.dart';
import '../utils/app_routes.dart';


//ImagePicker()
class ObraItem extends StatefulWidget {
  @override
  State<ObraItem> createState() => _ObraItemState();
}

class _ObraItemState extends State<ObraItem> {
  double percentage = 0.0;
  String hasInternet = '';

  @override
    void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    final product = Provider.of<Obra>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5),
      child: Container(
        width: 200,
        padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 236, 182, 55),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            const SizedBox(height: 15,),
            SizedBox(
              height: 160,
              width: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.OBRA_DETAIL, arguments: product);
                  },
                  child: Stack(
                        children: [
                        Container(
                          height: double.infinity,
                          width: double.infinity,
                          padding: const EdgeInsets.only(bottom: 5),
                          color: const Color.fromARGB(234, 57, 91, 143),
                          alignment: Alignment.bottomCenter,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              product.enterprise,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        // Align(
                        //   alignment: Alignment.bottomCenter,
                        //   child: SizedBox(
                        //     width: 200,
                        //     child: Center(
                        //       child: SingleChildScrollView(
                        //         scrollDirection: Axis.horizontal,
                        //         child: Text(
                        //           product.enterprise,
                        //           style: const TextStyle(
                        //             color: Colors.white,
                        //             fontSize: 18,
                        //             fontWeight: FontWeight.w800,
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        ]
                      ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed:() => print('need to add changing favorites'),
                  icon: const Icon(Icons.favorite_border),
                  color: Colors.white,
                ),
                IconButton(
                  onPressed: () => print('adicionar pro carrinho'),
                  icon: const Icon(
                    Icons.shopping_cart,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}