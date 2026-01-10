import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/product.dart';

class ProductRepository {
  const ProductRepository._();

  static const String recommendedAsset = 'assets/data/recommended.json';

  static Future<List<Product>> loadRecommended() async {
    try {
      final String jsonString = await rootBundle.loadString(recommendedAsset);
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(_mapJsonToProduct)
          .whereType<Product>()
          .toList(growable: false);
    } catch (error) {
      // Surface partial failure by returning an empty list rather than crashing the UI.
      // Logging can be added later via a telemetry layer.
      return <Product>[];
    }
  }

  static Product? _mapJsonToProduct(Map<String, dynamic> json) {
    final String? name = json['name'] as String?;
    final String? photoUrl = json['photoUrl'] as String?;
    final num? price = json['price'] as num?;

    if (name == null || name.isEmpty || photoUrl == null || price == null) {
      return null;
    }

    final String id = json['id'] as String? ?? _slugFromName(name);

    return Product(
      id: id,
      name: name,
      price: price.toDouble(),
      category: json['category'] as String? ?? 'Recommended',
      imageUrl: photoUrl,
      threeDModelUrl: json['threeDModelUrl'] as String?,
      description: json['description'] as String? ?? 'Featured Rezon pick.',
      colors: _coerceStringList(json['colors']) ?? const <String>['Standard'],
      sizes: _coerceStringList(json['sizes']) ?? const <String>['One Size'],
      inventory: (json['inventory'] as num?)?.toInt() ?? 25,
      badges: _coerceStringList(json['badges']) ?? const <String>['Staff Pick'],
    );
  }

  static List<String>? _coerceStringList(dynamic value) {
    if (value is List) {
      return value.whereType<String>().toList(growable: false);
    }
    if (value is String && value.isNotEmpty) {
      return <String>[value];
    }
    return null;
  }

  static String _slugFromName(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '')
        .trim();
  }
}
