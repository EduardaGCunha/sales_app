import 'dart:io';

import 'package:flutter/material.dart';

import '../models/product.dart';
import '../utils/cache.dart';

class ProductDetail extends StatelessWidget {
  const ProductDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
    final product = arguments['product'] as Product;
  
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 7, 71, 122),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 300,
              width: double.infinity,
              child: product.image == ''
              ? Container(color: const Color.fromARGB(255, 7, 71, 122),) 
              : Cache.hasInternet == 'yes' 
                ? Image.network(
                    product.image,
                    fit: BoxFit.cover,
                  )
                  : Image.file(
                      File(product.image),
                        fit: BoxFit.cover,
                        width: double.infinity,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
