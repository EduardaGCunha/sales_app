// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../models/product_list.dart';
import '../utils/app_routes.dart';
import '../utils/cache.dart';

class ProductDetail extends StatelessWidget {
  const ProductDetail({Key? key}) : super(key: key);

  void _viewImage(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) {
        return Scaffold(
          body: Center(
            child: Hero(
              tag: product.id, 
              child: Material(
                type: MaterialType.transparency,
                child: product.image == ''
                  ? Container(color: const Color.fromARGB(255, 7, 71, 122),) 
                  : Cache.hasInternet == 'yes' 
                    ? Image.network(
                        product.image,
                        fit: BoxFit.contain,
                      )
                    : Image.file(
                        File(product.image),
                        fit: BoxFit.contain,
                      ),
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = ModalRoute.of(context)?.settings.arguments as Product;
    final List<Color> colors = [
      const Color.fromARGB(255, 149, 195, 233),
      const Color.fromARGB(255, 255, 171, 165),
      const Color.fromARGB(255, 168, 241, 171),
      const Color.fromARGB(255, 255, 246, 160),
      const Color.fromARGB(255, 253, 219, 167),
      const Color.fromARGB(255, 237, 183, 247),
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color.fromARGB(255, 7, 71, 122),
            expandedHeight: 300,
            flexibleSpace: GestureDetector(
              onTap: () {
                _viewImage(context, product); // Call the _viewImage method on tap
              },
              child: FlexibleSpaceBar(
                background: Hero(
                  tag: product.id,
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
              ),
            ),
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(50),
              child: SizedBox(),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          padding: const EdgeInsets.only(left: 20),
                          child: Text(
                          product.name.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w700
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => print('adicionar add favorite pag detalhe'),
                      icon: const Icon(Icons.favorite_border),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 10,),
                    Wrap(
                      children: [
                        for (var item in product.category) 
                          Container(
                            width: item.length * 11,
                            height: 25,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: colors[Random().nextInt(colors.length)],
                            ),
                            margin: const EdgeInsets.all(8),
                            child: Text(
                              item,
                              style: const TextStyle(fontSize: 20),
                              textAlign: TextAlign.center,
                            ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10,),
                Container(
                  padding: const EdgeInsets.only(left: 20),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Descrição',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w400,
                    )
                  ),
                ),
                const SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Text(
                        product.description,
                        style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                            color: Color.fromARGB(255, 94, 92, 92)
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                 Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Text(
                        product.description,
                        style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                            color: Color.fromARGB(255, 94, 92, 92)
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                 Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Text(
                        product.description,
                        style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                            color: Color.fromARGB(255, 94, 92, 92)
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ]
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          color: Colors.blue,
          child: IconTheme(
            data: const IconThemeData(color: Colors.blue), 
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Excluir Produto?'),
                        content: const Text('Tem certeza?'),
                        actions: [
                          TextButton(
                            child: const Text('Não'),
                            onPressed: () => Navigator.of(ctx).pop(false),
                          ),
                          TextButton(
                            child: const Text('Sim'),
                            onPressed: () => Navigator.of(ctx).pop(true),
                          ),
                        ],
                      ),
                    ).then((value) async {
                      if (value ?? false){
                        await Provider.of<ProductList>(context, listen: false).removeProduct(product);
                        Navigator.of(context).pop();
                      }
                    });
                  }, 
                  icon: const Icon(Icons.delete, color: Colors.white,)),
                  IconButton(onPressed: () async {
                    await Navigator.of(context).popAndPushNamed(AppRoutes.PRODUCT_FORM, arguments: product);
                  }, icon: const Icon(Icons.edit, color: Colors.white,)),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.settings, color: Colors.white,)),
                ],
              ),
            )
          ),
        ),
      ),
    );
  }
}