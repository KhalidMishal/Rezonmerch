import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/product.dart';
import '../state/app_state.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late final PageController _verticalController;
  late final Random _random;

  @override
  void initState() {
    super.initState();
    _verticalController = PageController();
    _random = Random();
  }

  @override
  void dispose() {
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = AppStateScope.of(context);
    final List<Product> availableProducts =
        state.products.isNotEmpty ? state.products : <Product>[widget.product];
    final List<Product> curatedFeed = _curatedFeed(availableProducts);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          if (state.isLoadingProducts && curatedFeed.isEmpty)
            const Center(child: CircularProgressIndicator())
          else
            PageView.builder(
              controller: _verticalController,
              scrollDirection: Axis.vertical,
              itemBuilder: (BuildContext context, int index) {
                final Product product = _productForIndex(
                  index: index,
                  curated: curatedFeed,
                  pool: availableProducts,
                );
                final bool isFavorite = state.isFavorite(product);
                return _ProductReel(
                  key: ValueKey<String>('${product.id}-$index'),
                  product: product,
                  isFavorite: isFavorite,
                  onFavoriteToggle: () => state.toggleFavorite(product),
                  onAddToCart: () => state.addToCart(product),
                );
              },
            ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
        ],
      ),
    );
  }

  List<Product> _curatedFeed(List<Product> products) {
    final Map<String, Product> uniqueById = <String, Product>{
      for (final Product product in products) product.id: product,
    };

    final List<Product> ordered = <Product>[];
    ordered.add(uniqueById[widget.product.id] ?? widget.product);
    uniqueById.remove(widget.product.id);
    ordered.addAll(uniqueById.values);
    return ordered;
  }

  Product _productForIndex({
    required int index,
    required List<Product> curated,
    required List<Product> pool,
  }) {
    if (index < curated.length) {
      return curated[index];
    }
    if (pool.isEmpty) {
      return widget.product;
    }
    return pool[_random.nextInt(pool.length)];
  }
}

class _ProductReel extends StatefulWidget {
  const _ProductReel({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onAddToCart,
  });

  final Product product;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onAddToCart;

  @override
  State<_ProductReel> createState() => _ProductReelState();
}

class _ProductReelState extends State<_ProductReel> {
  late PageController _galleryController;
  int _galleryIndex = 0;
  bool _showLikeSplash = false;
  Timer? _likeTimer;
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
    _galleryController = PageController();
  }

  @override
  void didUpdateWidget(covariant _ProductReel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product.id != widget.product.id) {
      _galleryController.dispose();
      _galleryController = PageController();
      _galleryIndex = 0;
      _likeTimer?.cancel();
      _showLikeSplash = false;
      _showDetails = false;
    }
  }

  @override
  void dispose() {
    _galleryController.dispose();
    _likeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final EdgeInsets padding = MediaQuery.of(context).padding;
    final List<String> gallery = _galleryForProduct(widget.product);

    return GestureDetector(
      onDoubleTap: _handleLike,
      child: Stack(
        children: <Widget>[
          PageView.builder(
            controller: _galleryController,
            scrollDirection: Axis.horizontal,
            itemCount: gallery.length,
            onPageChanged: (int index) => setState(() => _galleryIndex = index),
            itemBuilder: (_, int index) => _GalleryImage(
              imageUrl: gallery[index],
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: AnimatedOpacity(
                opacity: _showLikeSplash ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                child: Center(
                  child: Icon(
                    Icons.favorite,
                    color: Colors.white.withValues(alpha: 0.9),
                    size: 140,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: screenSize.height * 0.35,
            child: _ActionRail(
              isFavorite: widget.isFavorite,
              onFavoriteToggle: _handleLike,
              onAddToCart: _handleAddToCart,
              price: widget.product.price,
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: padding.bottom + 24,
            child: _ProductInfoPanel(
              product: widget.product,
              galleryIndex: _galleryIndex,
              galleryLength: gallery.length,
              isExpanded: _showDetails,
              onToggle: () => setState(() => _showDetails = !_showDetails),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLike() {
    widget.onFavoriteToggle();
    _likeTimer?.cancel();
    setState(() => _showLikeSplash = true);
    _likeTimer = Timer(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() => _showLikeSplash = false);
      }
    });
  }

  void _handleAddToCart() {
    widget.onAddToCart();
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${widget.product.name} added to bag'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
  }
}

class _GalleryImage extends StatelessWidget {
  const _GalleryImage({
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.4),
                  BlendMode.darken,
                ),
                child: imageUrl.startsWith('http')
                    ? Image.network(imageUrl, fit: BoxFit.cover)
                    : Image.asset(imageUrl, fit: BoxFit.cover),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: FractionallySizedBox(
              widthFactor: 0.9,
              heightFactor: 0.85,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: DecoratedBox(
                  decoration: const BoxDecoration(color: Colors.black),
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      imageUrl.startsWith('http')
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                            )
                          : Image.asset(
                              imageUrl,
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                            ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: <Color>[Colors.black87, Colors.transparent],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRail extends StatelessWidget {
  const _ActionRail({
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onAddToCart,
    required this.price,
  });

  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onAddToCart;
  final double price;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _RailButton(
          icon: isFavorite ? Icons.favorite : Icons.favorite_border,
          label: 'Like',
          onTap: onFavoriteToggle,
          isActive: isFavorite,
        ),
        const SizedBox(height: 18),
        _RailButton(
          icon: Icons.shopping_bag_outlined,
          label: '\$${price.toStringAsFixed(0)}',
          onTap: onAddToCart,
        ),
      ],
    );
  }
}

class _RailButton extends StatelessWidget {
  const _RailButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: <Widget>[
          AnimatedScale(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutBack,
            scale: isActive ? 1.15 : 1.0,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(28),
                border: isActive ? Border.all(color: Colors.pinkAccent, width: 2) : null,
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white70,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductInfoPanel extends StatelessWidget {
  const _ProductInfoPanel({
    required this.product,
    required this.galleryIndex,
    required this.galleryLength,
    required this.isExpanded,
    required this.onToggle,
  });

  final Product product;
  final int galleryIndex;
  final int galleryLength;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final bool hasDescription = product.description.trim().isNotEmpty;
    final bool hasColors = product.colors.isNotEmpty;
    final bool hasSizes = product.sizes.isNotEmpty;

    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              product.name,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              '${product.category} • \$${product.price.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white70,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  isExpanded ? 'Hide' : 'Details',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: isExpanded
                  ? Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if (hasDescription)
                            Text(
                              product.description,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          if (hasDescription && (hasColors || hasSizes))
                            const SizedBox(height: 12),
                          if (hasColors)
                            _PillScroller(label: 'Colors', values: product.colors),
                          if (hasColors && hasSizes)
                            const SizedBox(height: 8),
                          if (hasSizes)
                            _PillScroller(label: 'Sizes', values: product.sizes),
                          const SizedBox(height: 12),
                          _GalleryIndicator(length: galleryLength, activeIndex: galleryIndex),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: _GalleryIndicator(length: galleryLength, activeIndex: galleryIndex),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PillScroller extends StatelessWidget {
  const _PillScroller({required this.label, required this.values});

  final String label;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: values
                .map(
                  (String value) => Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(value, style: const TextStyle(color: Colors.white)),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _GalleryIndicator extends StatelessWidget {
  const _GalleryIndicator({required this.length, required this.activeIndex});

  final int length;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(length, (int index) {
        final bool isActive = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(right: 6),
          height: 4,
          width: isActive ? 32 : 12,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white38,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

List<String> _galleryForProduct(Product product) {
  int variations = 1;
  variations = max(variations, product.colors.length);
  variations = max(variations, product.badges.length);

  return List<String>.generate(variations, (int index) {
    return _imageUrlWithSeed(product.imageUrl, index);
  });
}

String _imageUrlWithSeed(String url, int seed) {
  if (!url.startsWith('http')) {
    return url;
  }
  final String separator = url.contains('?') ? '&' : '?';
  return '$url${separator}sig=${seed + 1}';
}
