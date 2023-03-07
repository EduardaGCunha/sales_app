// ignore_for_file: use_key_in_widget_constructors
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_app/models/product.dart';

import '../utils/app_routes.dart';
import '../utils/cache.dart';


//ImagePicker()
class ProductItem extends StatefulWidget {
  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  double percentage = 0.0;
  String hasInternet = '';

  @override
    void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    final product = Provider.of<Product>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5),
      child: Container(
        height: 150,
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
              height: 150,
              width: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.PRODUCT_DETAIL, arguments: product);
                  },
                  child: product.image == ''
                      ? Container(color: Color.fromARGB(234, 57, 91, 143)) 
                      : Stack(
                        children: [
                          Image.file(
                          File(product.image),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                          Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                const Color.fromARGB(0, 25, 48, 114),
                                Color.fromARGB(255, 39, 62, 97).withOpacity(0.7),
                              ],
                            ),
                          ),
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: SizedBox(
                            width: 150,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Text(
                                product.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
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