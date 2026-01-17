import 'package:flutter/material.dart';
import 'package:stock_management/models/product_model.dart';
import 'package:stock_management/models/stock_movement_model.dart';
import 'package:stock_management/services/api_service.dart';
import 'package:intl/intl.dart';

class DashboardProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _error;

  double _totalValue = 0;
  int _lowStockCount = 0;
  List<Product> _allProducts = [];
  List<Product> _lowStockProducts = [];
  List<Product> _outOfStockProducts = [];
  List<StockMovement> _recentMovements = [];
  Map<String, Map<String, double>> _dailyStats = {};
  Map<String, double> _categoryDistribution = {};
  String _inventoryFilter = 'All Items';

  bool get isLoading => _isLoading;
  String? get error => _error;
  double get totalValue => _totalValue;
  int get lowStockCount => _lowStockCount;
  List<Product> get allProducts => _allProducts;
  List<Product> get lowStockProducts => _lowStockProducts;
  List<Product> get outOfStockProducts => _outOfStockProducts;
  List<StockMovement> get recentMovements => _recentMovements;
  Map<String, Map<String, double>> get dailyStats => _dailyStats;
  Map<String, double> get categoryDistribution => _categoryDistribution;
  String get inventoryFilter => _inventoryFilter;

  int get inStockCount => _allProducts.where((p) => p.stockQuantity > 0).length;

  void setInventoryFilter(String filter) {
    _inventoryFilter = filter;
    notifyListeners();
  }

  List<Product> get filteredProducts {
    if (_inventoryFilter == 'Low Stock') {
      return _lowStockProducts;
    } else if (_inventoryFilter == 'Out of Stock') {
      return _outOfStockProducts;
    } else {
      return _allProducts;
    }
  }

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Fetch all products
      final productsData = await _apiService.getProducts();
      _allProducts = productsData
          .map((json) => Product.fromJson(json))
          .toList();

      _calculateStockStats();

      // 2. Fetch all movements and process locally
      final movementsData = await _apiService.getStockMovements();
      final allMovements = movementsData
          .map((json) => StockMovement.fromJson(json))
          .toList();

      _processMovements(allMovements);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _calculateStockStats() {
    _totalValue = 0;
    _outOfStockProducts = [];
    _lowStockProducts = [];
    Map<String, int> categoryCounts = {};

    for (var product in _allProducts) {
      _totalValue += (product.price * product.stockQuantity);
      if (product.stockQuantity == 0) {
        _outOfStockProducts.add(product);
      }
      if (product.stockQuantity > 0 && product.stockQuantity <= 5) {
        _lowStockProducts.add(product);
      }

      // Distribution calculation (by product count)
      if (product.categoryId != null) {
        categoryCounts[product.categoryId!] =
            (categoryCounts[product.categoryId!] ?? 0) + 1;
      }
    }
    _lowStockCount = _lowStockProducts.length;

    // Convert counts to percentages
    _categoryDistribution = {};
    if (_allProducts.isNotEmpty) {
      categoryCounts.forEach((catId, count) {
        _categoryDistribution[catId] = (count / _allProducts.length) * 100;
      });
    }
  }

  void _processMovements(List<StockMovement> allMovements) {
    final now = DateTime.now();

    // Sort by date descending for activity list
    allMovements.sort((a, b) {
      final dateA = DateTime.tryParse(a.createdAt ?? '') ?? DateTime(0);
      final dateB = DateTime.tryParse(b.createdAt ?? '') ?? DateTime(0);
      return dateB.compareTo(dateA);
    });

    _recentMovements = allMovements.take(10).toList();

    // Group for chart (last 7 days including today)
    _dailyStats = {};
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final dayName = DateFormat('E').format(date); // Mon, Tue, etc.
      _dailyStats[dayName] = {'IN': 0, 'OUT': 0};
    }

    for (var m in allMovements) {
      final date = DateTime.tryParse(m.createdAt ?? '');
      if (date != null) {
        // Only count if within last 7 days
        if (now.difference(date).inDays <= 7) {
          final dayName = DateFormat('E').format(date);
          if (_dailyStats.containsKey(dayName)) {
            final type = m.type.toUpperCase();
            if (type == 'IN' || type == 'OUT') {
              _dailyStats[dayName]![type] =
                  (_dailyStats[dayName]![type] ?? 0) + m.quantity;
            }
          }
        }
      }
    }
  }
}
