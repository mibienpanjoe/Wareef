import 'package:flutter/material.dart';
import 'package:stock_management/models/product_model.dart';
import 'package:stock_management/services/api_service.dart';

class ProductProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _apiService.getProducts();
      _products = data.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(
    String name,
    String? categoryId,
    int stockQuantity,
    double price,
    String? description, {
    String? imagePath,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newProductJson = await _apiService.addProduct(
        name,
        categoryId,
        stockQuantity,
        price,
        description,
        imagePath: imagePath,
      );
      final newProduct = Product.fromJson(newProductJson);
      _products.add(newProduct);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProduct(
    Product product,
    String name,
    String? categoryId,
    int stockQuantity,
    double price,
    String? description, {
    String? imagePath,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedProductJson = await _apiService.updateProduct(
        product.id,
        name,
        categoryId,
        stockQuantity,
        price,
        description,
        imagePath: imagePath,
      );
      final updatedProduct = Product.fromJson(updatedProductJson);

      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = updatedProduct;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.deleteProduct(id);
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
