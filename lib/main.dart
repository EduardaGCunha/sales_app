import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_app/models/diary_list.dart';
import 'package:sales_app/models/obra_list.dart';
import 'package:sales_app/models/project_list.dart';
import 'package:sales_app/pages/data_page.dart';
import 'package:sales_app/pages/obra_detail.dart';
import 'package:sales_app/pages/obra_form.dart';
import 'package:sales_app/pages/product_detail.dart';
import 'package:sales_app/pages/product_form.dart';
import 'package:sales_app/pages/products_screen.dart';
import 'package:sales_app/pages/obras_page.dart';
import 'package:sales_app/pages/project_form.dart';
import 'package:sales_app/pages/splash.dart';
import 'package:sales_app/utils/app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'models/product_list.dart';
import 'pages/diary_form.dart';

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
        ChangeNotifierProvider(create: (_) => ObraList()),
        ChangeNotifierProvider(create: (_) => ProjectList()),
        ChangeNotifierProvider(create: (_) => DiaryList()),
      ],
      child: MaterialApp(
        title: 'Vendas',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: const ProductScreen(),
        routes: {
          AppRoutes.PRODUCT_PAGE: (ctx) => const ProductScreen(),
          AppRoutes.PRODUCT_FORM: (ctx) => const ProductForm(),
          AppRoutes.PRODUCT_DETAIL: (ctx) => const ProductDetail(),
          AppRoutes.OBRAS_PAGE: (ctx) => const ObrasPage(),
          AppRoutes.OBRA_FORM: (ctx) => const ObraForm(),
          AppRoutes.OBRA_DETAIL: (ctx) => const ObraDetail(),
          AppRoutes.PROJECT_FORM: (ctx) => const ProjectForm(),
          AppRoutes.DIARY_FORM: (ctx) => const DiaryForm(),
        },
      ),
    );
  }
}
