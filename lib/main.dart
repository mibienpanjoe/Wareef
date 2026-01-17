import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_management/providers/category_provider.dart';
import 'package:stock_management/providers/product_provider.dart';
import 'package:stock_management/providers/stock_movement_provider.dart';
import 'package:stock_management/providers/dashboard_provider.dart';
import 'package:stock_management/ui/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => StockMovementProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ],
      child: MaterialApp(
        title: 'Stock Management',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        home: const LoginScreen(),
      ),
    );
  }
}
