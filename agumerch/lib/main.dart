import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'models/product.dart';
import 'screens/cart_screen.dart';
import 'screens/catalog_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/home_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/profile_screen.dart';
import 'state/app_state.dart';

void main() {
  runApp(const AGUMerchApp());
}

class AGUMerchApp extends StatefulWidget {
  const AGUMerchApp({super.key});

  @override
  State<AGUMerchApp> createState() => _AGUMerchAppState();
}

class _AGUMerchAppState extends State<AGUMerchApp> {
  final AppState _state = AppState();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  bool _signedInAsGuest = false; // <-- new: control showing welcome screen
  ThemeMode _themeMode = ThemeMode.system;

  void _openProduct(Product product) {
    _navigatorKey.currentState?.push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => ProductDetailScreen(product: product),
      ),
    );
  }

  void _updateThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'AGU Merch',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF10628A)),
        scaffoldBackgroundColor: const Color(0xFFF5F6F8),
      ),
      darkTheme: ThemeData.dark().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF10628A), brightness: Brightness.dark),
        scaffoldBackgroundColor: const Color(0xFF0B0B0D),
      ),
      builder: (BuildContext context, Widget? child) {
        return AppStateScope(
          notifier: _state,
          child: child ?? const SizedBox.shrink(),
        );
      },
      // show welcome screen until user taps "Sign in as guest"
      home: _signedInAsGuest
          ? _MainShell(
              onProductSelected: _openProduct,
              themeMode: _themeMode,
              onThemeModeChanged: _updateThemeMode,
            )
          : WelcomeScreen(
              onSignInAsGuest: () {
                setState(() => _signedInAsGuest = true);
              },
              onSignInWithGoogle: () {
                // non-functional placeholder
              },
              onRegister: () {
                // non-functional placeholder
              },
              themeMode: _themeMode,
              onThemeModeChanged: _updateThemeMode,
            ),
    );
  }
}

class _MainShell extends StatefulWidget {
  const _MainShell({required this.onProductSelected, required this.themeMode, required this.onThemeModeChanged});

  final ValueChanged<Product> onProductSelected;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  int _index = 0;

  void _setIndex(int value) {
    setState(() => _index = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: <Widget>[
          HomeScreen(
            onProductSelected: widget.onProductSelected,
            onSeeAll: () => _setIndex(1),
          ),
          CatalogScreen(
            onProductSelected: widget.onProductSelected,
          ),
          FavoritesScreen(onProductSelected: widget.onProductSelected),
          CartScreen(onExplore: () => _setIndex(1)),
          ProfileScreen(
            themeMode: widget.themeMode,
            onThemeModeChanged: widget.onThemeModeChanged,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _setIndex,
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view), label: 'Catalog'),
          NavigationDestination(icon: Icon(Icons.favorite_outline), selectedIcon: Icon(Icons.favorite), label: 'Favorites'),
          NavigationDestination(icon: Icon(Icons.shopping_bag_outlined), selectedIcon: Icon(Icons.shopping_bag), label: 'Cart'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
