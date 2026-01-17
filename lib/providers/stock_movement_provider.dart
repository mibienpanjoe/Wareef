import 'package:flutter/material.dart';
import 'package:stock_management/models/stock_movement_model.dart';
import 'package:stock_management/services/api_service.dart';

enum StockMovementSort {
  dateNewest,
  dateOldest,
  quantityHigh,
  quantityLow,
  productNameAZ,
  productNameZA,
}

class StockMovementProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<StockMovement> _movements = [];
  bool _isLoading = false;
  String? _error;

  List<StockMovement> get movements => _movements;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get filterType => _filterType;
  StockMovementSort get sortBy => _sortBy;

  // Filter and Sort properties
  String _filterType = 'ALL'; // ALL, IN, OUT
  String _searchQuery = '';
  StockMovementSort _sortBy = StockMovementSort.dateNewest;

  List<StockMovement> get filteredMovements {
    final filtered = _movements.where((movement) {
      final matchesType = _filterType == 'ALL' || movement.type == _filterType;
      final matchesSearch =
          movement.productName?.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ??
          false;
      return matchesType && matchesSearch;
    }).toList();

    // Apply sorting
    switch (_sortBy) {
      case StockMovementSort.dateNewest:
        filtered.sort((a, b) {
          final dateA = DateTime.tryParse(a.createdAt ?? '') ?? DateTime(0);
          final dateB = DateTime.tryParse(b.createdAt ?? '') ?? DateTime(0);
          return dateB.compareTo(dateA);
        });
        break;
      case StockMovementSort.dateOldest:
        filtered.sort((a, b) {
          final dateA = DateTime.tryParse(a.createdAt ?? '') ?? DateTime(0);
          final dateB = DateTime.tryParse(b.createdAt ?? '') ?? DateTime(0);
          return dateA.compareTo(dateB);
        });
        break;
      case StockMovementSort.quantityHigh:
        filtered.sort((a, b) => b.quantity.compareTo(a.quantity));
        break;
      case StockMovementSort.quantityLow:
        filtered.sort((a, b) => a.quantity.compareTo(b.quantity));
        break;
      case StockMovementSort.productNameAZ:
        filtered.sort(
          (a, b) => (a.productName ?? '').compareTo(b.productName ?? ''),
        );
        break;
      case StockMovementSort.productNameZA:
        filtered.sort(
          (a, b) => (b.productName ?? '').compareTo(a.productName ?? ''),
        );
        break;
    }

    return filtered;
  }

  void setFilterType(String type) {
    _filterType = type;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSortBy(StockMovementSort sort) {
    _sortBy = sort;
    notifyListeners();
  }

  Future<void> fetchStockMovements() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.getStockMovements();
      _movements = data.map((json) => StockMovement.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addStockMovement(
    String productId,
    String type,
    int quantity,
    String? description,
  ) async {
    try {
      await _apiService.addStockMovement(
        productId,
        type,
        quantity,
        description,
      );
      await fetchStockMovements(); // Refresh list
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteStockMovement(String id) async {
    try {
      await _apiService.deleteStockMovement(id);
      await fetchStockMovements(); // Refresh list
    } catch (e) {
      rethrow;
    }
  }
}
