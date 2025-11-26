import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

import '../config/endpoints.dart';

import '../models/product.dart';

import '../models/category.dart';

class ApiClient {
  final String baseUrl;

  final bool useMock;

  ApiClient({String? baseUrl, bool? useMock})
      : baseUrl = baseUrl ?? AppConfig.baseUrl,
        useMock = useMock ?? AppConfig.useMock;

  Future<List<Product>> fetchProducts({int? categoryId}) async {
    if (useMock) {
      final raw = await rootBundle.loadString('assets/mock/products.json');

      final list = (json.decode(raw) as List).cast<Map<String, dynamic>>();

      final products = list.map(Product.fromJson).toList();

      if (categoryId != null) {
        return products.where((p) => p.categoryId == categoryId).toList();
      }

      return products;
    }

    final uri = Uri.parse(
      categoryId == null
          ? "$baseUrl${Endpoints.products}"
          : "$baseUrl${Endpoints.productsByCategory(categoryId)}",
    );

    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception("Failed to load products (${res.statusCode})");
    }

    final data = json.decode(res.body);

    // If your backend wraps responses, unwrap accordingly:

    final list = (data is Map && data['data'] != null && data['data'] is List)
        ? (data['data'] as List)
        : (data as List);

    return list.map((e) => Product.fromJson(e)).toList();
  }

  Future<List<Category>> fetchCategories() async {
    if (useMock) {
      final raw = await rootBundle.loadString('assets/mock/categories.json');

      final list = (json.decode(raw) as List).cast<Map<String, dynamic>>();

      return list.map(Category.fromJson).toList();
    }

    //final uri = Uri.parse("$baseUrl${Endpoints.categories}");

    final uri = Uri.parse(AppConfig.loginUrl);

    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception("Failed to load categories (${res.statusCode})");
    }

    final data = json.decode(res.body);

    final list = (data is Map && data['data'] != null && data['data'] is List)
        ? (data['data'] as List)
        : (data as List);

    return list.map((e) => Category.fromJson(e)).toList();
  }

  Future<bool> login(String email, String password) async {
    //  if (useMock) {

    //    await Future.delayed(const Duration(milliseconds: 400));

    //    return true; // Always succeed in mock
    //}

    final uri = Uri.parse("$baseUrl${Endpoints.authLogin}");

    final res = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': email, 'password': password}));
    print("res statuskod: ${res.statusCode}");
    if (res.statusCode == 200) return true;
    return false;
  }
}
