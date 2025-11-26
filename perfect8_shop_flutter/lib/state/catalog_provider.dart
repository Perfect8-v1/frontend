// Corrected line below: add `hide Category` to the foundation import
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../models/product.dart';
import '../models/category.dart';

class CatalogProvider extends ChangeNotifier {
  final _api = ApiClient();

  List<Product> _products = [];
  List<Category> _categories = [];
  bool _loading = false;

  String? _error;

  List<Product> get products => _products;
  List<Category> get categories => _categories;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> init() async {
    await Future.wait([loadCategories(), loadProducts()]);
  }

  Future<void> loadProducts({int? categoryId}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _products = await _api.fetchProducts(categoryId: categoryId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    try {
      _categories = await _api.fetchCategories();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}