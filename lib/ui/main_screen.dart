import 'package:flutter/material.dart';
import 'package:stock_management/ui/dashboard/dashboard_screen.dart';
import 'package:stock_management/ui/categories_screen.dart';
import 'package:stock_management/ui/products/product_list_screen.dart';
import 'package:stock_management/ui/stock/stock_movement_list_screen.dart';
import 'package:stock_management/ui/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Dashboard is index 0

  static final List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    ProductListScreen(),
    CategoriesScreen(),
    StockMovementListScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1E293B),
        unselectedItemColor: Colors.grey[400],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.grid_view_rounded),
            ),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.inventory_2_outlined),
            ),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.category_outlined),
            ),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.home_work_outlined),
            ),
            label: 'Stock',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.person_outline),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
