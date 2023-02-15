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

    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const SizedBox(height: 15,),
          SizedBox(
            height: 120,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.PRODUCT_DETAIL, arguments: product);
                },
                child: product.image == ''
                    ? Container(color: const Color.fromARGB(255, 35, 150, 179),) 
                    : Cache.hasInternet == 'yes'? 
                    Image.network(
                      product.image,
                      fit: BoxFit.cover,
                    )
                    : Image.file(
                      File(product.image),
                        fit: BoxFit.cover,
                        width: double.infinity,
                    ),
              ),
            ),
          ),
          const SizedBox(height: 5,),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              product.name,
              style: const TextStyle(
                color: Color.fromARGB(255, 9, 2, 49),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Container(
            height: 50,
            alignment: Alignment.topLeft,
            child: Expanded(
              child: Text(
                product.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color.fromARGB(255, 105, 102, 102),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
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
                color: Colors.black,
              ),
              IconButton(
                onPressed: () => print('adicionar pro carrinho'),
                icon: const Icon(
                  Icons.shopping_cart,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}