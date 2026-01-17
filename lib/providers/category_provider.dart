import 'package:flutter/material.dart';
import 'package:stock_management/models/category_model.dart';
import 'package:stock_management/services/api_service.dart';

class CategoryProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Category> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _apiService.getCategories();
      _categories = data.map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCategory(
    String name,
    String? description, {
    String? imagePath,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newCategoryJson = await _apiService.addCategory(
        name,
        description,
        imagePath: imagePath,
      );
      final newCategory = Category.fromJson(newCategoryJson);
      _categories.add(newCategory);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow; // Rethrow to let UI handle success/failure navigation
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCategory(
    Category category,
    String name,
    String? description, {
    String? imagePath,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedCategoryJson = await _apiService.updateCategory(
        category.id,
        name,
        description,
        imagePath: imagePath,
      );
      final updatedCategory = Category.fromJson(updatedCategoryJson);

      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = updatedCategory;
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

  Future<void> deleteCategory(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.deleteCategory(id);
      _categories.removeWhere((c) => c.id == id);
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
