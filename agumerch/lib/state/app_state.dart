import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/product_repository.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class AppState extends ChangeNotifier {
  AppState() {
    _products = [];
    loadProducts();

    // Listen for Firebase login state
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _firebaseUser = user;
      notifyListeners();
    });
  }

  // ──────────────────────
  // AUTH STATE (Firebase Email/Password)
  // ──────────────────────

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _firebaseUser;
  String? _authError;

  User? get firebaseUser => _firebaseUser;
  bool get isLoggedIn => _firebaseUser != null;
  String? get authError => _authError;

  Future<bool> signIn(String email, String password) async {
    try {
      _authError = null;
      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      _firebaseUser = result.user;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _authError = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      _authError = null;
      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      _firebaseUser = result.user;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _authError = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _firebaseUser = null;
    notifyListeners();
  }

  // ──────────────────────
  // PRODUCTS
  // ──────────────────────

  late List<Product> _products;
  bool _isLoadingProducts = true;
  String? _productLoadError;

  List<Product> get products => _products;
  bool get isLoadingProducts => _isLoadingProducts;
  String? get productLoadError => _productLoadError;

  Future<void> loadProducts() async {
    _isLoadingProducts = true;
    _productLoadError = null;
    notifyListeners();

    try {
      final List<Product> recommended =
          await ProductRepository.loadRecommended();
      _products = recommended;
      if (_products.isEmpty) {
        _productLoadError = 'No products available.';
      }
    } catch (_) {
      _products = <Product>[];
      _productLoadError = 'Unable to load products.';
    } finally {
      _isLoadingProducts = false;
      notifyListeners();
    }
  }

  // ──────────────────────
  // CART & FAVORITES
  // ──────────────────────

  final Map<String, CartItem> _cart = {};
  final Set<String> _favorites = <String>{};

  Set<String> get favorites => _favorites;
  List<CartItem> get cartItems => _cart.values.toList(growable: false);

  double get cartSubtotal =>
      _cart.values.fold(0, (sum, item) => sum + item.lineTotal);
  double get cartTaxEstimate => cartSubtotal * 0.07;
  double get cartTotal => cartSubtotal + cartTaxEstimate;

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

  String _cartKey(String productId, String? color, String? size) =>
      [productId, color ?? '-', size ?? '-'].join('__');

  // ──────────────────────
  // FILTERING
  // ──────────────────────

  String _searchQuery = '';
  String _activeCategory = 'All';

  String get searchQuery => _searchQuery;
  String get activeCategory => _activeCategory;

  void updateSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setCategory(String category) {
    _activeCategory = category;
    notifyListeners();
  }

  List<String> get categories {
    final Set<String> unique = {'All'};
    for (final Product product in _products) {
      unique.add(product.category);
    }
    return unique.toList(growable: false);
  }

  List<Product> get featuredProducts =>
      _products.take(3).toList(growable: false);

  List<Product> get filteredProducts {
    return _products.where((product) {
      final bool matchesCategory =
          _activeCategory == 'All' || product.category == _activeCategory;
      final bool matchesQuery = product.name
          .toLowerCase()
          .contains(_searchQuery.trim().toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList(growable: false);
  }

  // ──────────────────────
  // USER PROFILE
  // ──────────────────────

  String? _userName;
  String? _userGender;

  String get userName =>
      (_userName == null || _userName!.trim().isEmpty)
          ? (_firebaseUser?.displayName ?? 'Guest')
          : _userName!.trim();

  String? get userGender => _userGender;

  bool get isProfileComplete => _userName != null && _userGender != null;

  void setUserProfile({required String name, required String gender}) {
    _userName = name;
    _userGender = gender;
    notifyListeners();
  }

  // ──────────────────────
  // NOTIFICATIONS
  // ──────────────────────

  bool _notifyCompletedTransactions = true;
  bool _notifyAvailableDiscounts = true;
  bool _notifyNewProducts = true;

  bool get notifyCompletedTransactions => _notifyCompletedTransactions;
  bool get notifyAvailableDiscounts => _notifyAvailableDiscounts;
  bool get notifyNewProducts => _notifyNewProducts;

  void setNotifyCompletedTransactions(bool value) {
    _notifyCompletedTransactions = value;
    notifyListeners();
  }

  void setNotifyAvailableDiscounts(bool value) {
    _notifyAvailableDiscounts = value;
    notifyListeners();
  }

  void setNotifyNewProducts(bool value) {
    _notifyNewProducts = value;
    notifyListeners();
  }
}

// ──────────────────────
// PROVIDER
// ──────────────────────

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required super.notifier,
    required super.child,
  });

  static AppState of(BuildContext context) {
    final AppStateScope? scope =
        context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope not found');
    return scope!.notifier!;
  }
}