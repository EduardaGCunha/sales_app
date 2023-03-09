import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_app/models/obra.dart';
import 'package:sales_app/models/obra_list.dart';
import 'obra_item.dart';


class ObraGrid extends StatelessWidget {

  const ObraGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ObraList>(context);
    final List<Obra> loadedProducts = provider.items; 

    return SizedBox(
      height: 265,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: loadedProducts.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
            value: loadedProducts[i],
            child: ObraItem(),
          ),
        ),
      ),
    );
  }
}