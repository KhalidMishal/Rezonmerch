import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class AppState extends ChangeNotifier {
  AppState() {
    _products = List<Product>.unmodifiable(mockProducts);
  }

  late final List<Product> _products;
  final Map<String, CartItem> _cart = {};
  final Set<String> _favorites = <String>{};
  String _searchQuery = '';
  String _activeCategory = 'All';
  String? _userName;
  String? _userGender;

  List<Product> get products => _products;
  String get searchQuery => _searchQuery;
  String get activeCategory => _activeCategory;
  Set<String> get favorites => _favorites;
  String get userName => (_userName == null || _userName!.trim().isEmpty) ? 'Guest' : _userName!.trim();
  String? get userGender => _userGender;
  bool get isProfileComplete => _userName != null && _userGender != null;

  List<String> get categories {
    final Set<String> unique = {'All'};
    for (final Product product in _products) {
      unique.add(product.category);
    }
    return unique.toList(growable: false);
  }

  List<Product> get featuredProducts => _products.take(3).toList(growable: false);

  List<Product> get filteredProducts {
    return _products.where((Product product) {
      final bool matchesCategory =
          _activeCategory == 'All' || product.category == _activeCategory;
      final bool matchesQuery = product.name.toLowerCase().contains(
            _searchQuery.trim().toLowerCase(),
          );
      return matchesCategory && matchesQuery;
    }).toList(growable: false);
  }

  List<CartItem> get cartItems => _cart.values.toList(growable: false);

  double get cartSubtotal => _cart.values.fold(0, (double sum, CartItem item) => sum + item.lineTotal);

  double get cartTaxEstimate => cartSubtotal * 0.07;

  double get cartTotal => cartSubtotal + cartTaxEstimate;

  void updateSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setCategory(String category) {
    _activeCategory = category;
    notifyListeners();
  }

  void toggleFavorite(Product product) {
    if (_favorites.contains(product.id)) {
      _favorites.remove(product.id);
    } else {
      _favorites.add(product.id);
    }
    notifyListeners();
  }

  bool isFavorite(Product product) => _favorites.contains(product.id);

  void addToCart(Product product, {String? color, String? size}) {
    final String key = _cartKey(product.id, color, size);
    if (_cart.containsKey(key)) {
      _cart[key]!.quantity++;
    } else {
      _cart[key] = CartItem(product: product, color: color, size: size);
    }
    notifyListeners();
  }

  void updateCartQuantity(CartItem item, int quantity) {
    if (quantity <= 0) {
      removeFromCart(item);
      return;
    }
    item.quantity = quantity;
    notifyListeners();
  }

  void removeFromCart(CartItem item) {
    final String key = _cartKey(item.product.id, item.color, item.size);
    _cart.remove(key);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  void setUserProfile({required String name, required String gender}) {
    _userName = name;
    _userGender = gender;
    notifyListeners();
  }

  String _cartKey(String productId, String? color, String? size) =>
      [productId, color ?? '-', size ?? '-'].join('__');
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({super.key, required super.notifier, required super.child});

  static AppState of(BuildContext context) {
    final AppStateScope? scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope not found in widget tree');
    return scope!.notifier!;
  }
}
