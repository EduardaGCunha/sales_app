

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_app/components/app_drawer.dart';
import 'package:sales_app/models/product_list.dart';

import '../components/product_grid.dart';
import '../utils/app_routes.dart';
import '../utils/cache.dart';


class ProductScreen extends StatefulWidget {

  const ProductScreen({ Key? key}) : super(key: key);

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int _currentIndex = 0;
  
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
    Cache().setHasInternet;

    List<String> _imageUrls = [
    'https://www.grainsystems.com/content/dam/public/grain-and-protein/grain-systems/product-images/storage/evo-50/4024-EVO24-1440.jpg',
    'https://www.grainsystems.com/content/dam/public/grain-and-protein/grain-systems/product-images/material-handling/Bucket%20Elevators/bucket-elevator-sa-1440.jpg',
    'https://www.grainsystems.com/content/dam/public/grain-and-protein/grain-systems/product-images/material-handling/belt-conveyors/open-belt-conveyor/Open-Belt-Conveyor-1440.jpg',
    'https://www.grainsystems.com/content/dam/public/grain-and-protein/grain-systems/product-images/material-handling/pre-cleaning-machine/pre-cleaning-machine-1440.jpg',
    'https://picsum.photos/seed/5/600/400',
    ];
    
    return Scaffold(
      backgroundColor: const Color.fromARGB(157, 25, 42, 68),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(157, 25, 42, 68),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // do something when the search icon is pressed
            },
          ),
        ],
        title: SizedBox(
          width: 600,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Padding(padding: EdgeInsets.only(left: 120)),
              Text('ConsilTec',
              style: TextStyle(
                color: Colors.white
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
                color: Colors.white,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
      ),
      drawer: const Drawer(
        child: AppDrawer(),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        color: Color.fromARGB(255, 25, 42, 68),
        child: IconTheme(
          data: const IconThemeData(color:  Color.fromARGB(255, 60, 105, 172)), 
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(onPressed: () {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.PRODUCT_PAGE);
                }, icon: const Icon(Icons.home, color: Colors.white,)),
                IconButton(onPressed: () {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.SALES_PAGE);
                }, icon: const Icon(Icons.construction, color: Colors.white,)),
                const SizedBox(width: 20,),
                IconButton(onPressed: () {}, icon: const Icon(Icons.analytics_outlined, color: Colors.white,)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.settings, color: Colors.white,)),
              ],
            ),
          )
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 39, 62, 97),
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).pushNamed(AppRoutes.PRODUCT_FORM);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SingleChildScrollView(
        child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 20, top: 15),
            alignment: Alignment.centerLeft,
            child: const Text(
              'Descubra',
              style: TextStyle(
                fontSize: 40,
                color: Colors.white,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600
              ),
            ),
          ),
          SizedBox(height: 20,),
          Stack(
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 3),
                  height: 200.0,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                items: _imageUrls.map((imageUrl) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }).toList(),
              ),
              Container(
                height: 190,
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _imageUrls.map((imageUrl) {
                    int index = _imageUrls.indexOf(imageUrl);
                    return Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == index ? Color.fromARGB(255, 255, 233, 35) : Colors.grey[400],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.only(left: 15, top: 15),
            alignment: Alignment.centerLeft,
            child: const Text(
              'Transportadores',
              style: TextStyle(
                fontSize: 25,
                color: Colors.white,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w700
              ),
            ),
          ),
          const ProductGrid(),
          Container(
            padding: const EdgeInsets.only(left: 15, top: 15),
            alignment: Alignment.centerLeft,
            child: const Text(
              'Silos',
              style: TextStyle(
                fontSize: 25,
                color: Colors.white,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w700
              ),
            ),
          ),
          const ProductGrid(),
        ],
          ),
      ),
    );
  }
}