import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_app/pages/product_detail.dart';
import 'package:sales_app/pages/product_form.dart';
import 'package:sales_app/pages/products_screen.dart';
import 'package:sales_app/pages/sales_page.dart';
import 'package:sales_app/pages/splash.dart';
import 'package:sales_app/utils/app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'models/product_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductList()),
      ],
      child: MaterialApp(
        title: 'Vendas',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
        routes: {
          AppRoutes.PRODUCT_PAGE: (ctx) => const ProductScreen(),
          AppRoutes.PRODUCT_FORM: (ctx) => const ProductForm(),
          AppRoutes.PRODUCT_DETAIL: (ctx) => const ProductDetail(),
          AppRoutes.SALES_PAGE: (ctx) => const SalesPage(),
        },
      ),
    );
  }
}
