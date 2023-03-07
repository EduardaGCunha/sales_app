import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_app/components/product_item.dart';

import '../models/product.dart';
import '../models/product_list.dart';


class ProductGrid extends StatelessWidget {

  const ProductGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductList>(context);
    final List<Product> loadedProducts = provider.items; //do filter here

    return SizedBox(
      height: 270,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: loadedProducts.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
            value: loadedProducts[i],
            child: ProductItem(),
          ),
        ),
      ),
    );
  }
}