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
  String? _selectedColor;
  String? _selectedSize;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.product.colors.isNotEmpty ? widget.product.colors.first : null;
    _selectedSize = widget.product.sizes.isNotEmpty ? widget.product.sizes.first : null;
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = AppStateScope.of(context);
    final bool isFavorite = state.isFavorite(widget.product);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        actions: <Widget>[
          IconButton(
            onPressed: () => state.toggleFavorite(widget.product),
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      Image.network(widget.product.imageUrl, fit: BoxFit.cover),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: <Color>[Colors.black87, Colors.transparent],
                            ),
                          ),
                          child: Text(
                            widget.product.badges.join(' • '),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.product.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '\$${widget.product.price.toStringAsFixed(2)}',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(widget.product.description),
              const SizedBox(height: 20),
              if (widget.product.colors.isNotEmpty)
                _OptionSelector(
                  label: 'Available colors',
                  options: widget.product.colors,
                  selected: _selectedColor,
                  onChanged: (String value) => setState(() => _selectedColor = value),
                ),
              if (widget.product.sizes.isNotEmpty)
                _OptionSelector(
                  label: 'Select size',
                  options: widget.product.sizes,
                  selected: _selectedSize,
                  onChanged: (String value) => setState(() => _selectedSize = value),
                ),
              const SizedBox(height: 20),
              _PreviewCard(product: widget.product),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () {
                  state.addToCart(widget.product, color: _selectedColor, size: _selectedSize);
                  _showAddedToCart(context);
                },
                icon: const Icon(Icons.add_shopping_cart_outlined),
                label: const Text('Add to cart'),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddedToCart(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: const <Widget>[
                  Icon(Icons.check_circle, color: Colors.green, size: 28),
                  SizedBox(width: 12),
                  Text('Added to cart', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 12),
              Text('${widget.product.name} is now in your cart. Complete the simulated checkout to finalize.'),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Continue exploring'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OptionSelector extends StatelessWidget {
  const _OptionSelector({
    required this.label,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final String label;
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: options
              .map(
                (String option) => ChoiceChip(
                  label: Text(option),
                  selected: selected == option,
                  onSelected: (_) => onChanged(option),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.auto_awesome_motion, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Text('3D View Placeholder', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Imagine rotating a 3D model of the ${product.name}. In the final build, this section will host interactive merchandise previews.',
          ),
        ],
      ),
    );
  }
}
