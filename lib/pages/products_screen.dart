

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_app/components/app_drawer.dart';
import 'package:sales_app/models/product_list.dart';

import '../components/product_grid.dart';
import '../utils/app_routes.dart';


class ProductScreen extends StatefulWidget {

  const ProductScreen({ Key? key}) : super(key: key);

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {

  @override
    void initState() {
      super.initState();
      Provider.of<ProductList>(
        context,
        listen: false,
      ).loadProducts();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 236, 234, 234),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 236, 234, 234),
        elevation: 0,
        title: SizedBox(
          width: 600,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Padding(padding: EdgeInsets.only(left: 120)),
              Text('ConsilTec',
              style: TextStyle(
                color: Colors.black
              ),
              ),
            ],
          ),
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.black,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Container(
            padding: const EdgeInsets.only(bottom: 20, right: 150),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                 Text(
                  'Produtos',
                  style: TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                )
              ],
            )
          ),
        ),
      ),
      drawer: const Drawer(
        child: AppDrawer(),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        color: Colors.blue,
        child: IconTheme(
          data: const IconThemeData(color: Colors.blue), 
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.home, color: Colors.white,)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.business_center, color: Colors.white,)),
                SizedBox(width: 20,),
                IconButton(onPressed: () {}, icon: const Icon(Icons.analytics_outlined, color: Colors.white,)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.settings, color: Colors.white,)),
              ],
            ),
          )
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor:const  Color.fromARGB(255, 102, 183, 197),
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).pushNamed(AppRoutes.PRODUCT_FORM);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: const ProductGrid(),
    );
  }
}