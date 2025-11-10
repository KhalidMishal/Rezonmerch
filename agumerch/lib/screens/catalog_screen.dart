import 'package:flutter/material.dart';

import '../models/product.dart';
import '../state/app_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/product_card.dart';
import '../widgets/section_header.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key, required this.onProductSelected});

  final ValueChanged<Product> onProductSelected;

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String _sort = 'Featured';

  @override
  Widget build(BuildContext context) {
    final AppState state = AppStateScope.of(context);
    final List<Product> products = _sorted(state.filteredProducts);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SectionHeader(title: 'All Merchandise'),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: SegmentedButton<String>(
                    segments: state.categories
                        .map((String category) => ButtonSegment<String>(value: category, label: Text(category)))
                        .toList(),
                    selected: <String>{state.activeCategory},
                    onSelectionChanged: (Set<String> value) {
                      state.setCategory(value.first);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    initialValue: state.searchQuery,
                    onChanged: state.updateSearchQuery,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search products',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _sort,
                  onChanged: (String? value) {
                    if (value == null) {
                      return;
                    }
                    setState(() => _sort = value);
                  },
                  items: const <DropdownMenuItem<String>>[
                    DropdownMenuItem<String>(value: 'Featured', child: Text('Featured')),
                    DropdownMenuItem<String>(value: 'Price: Low to High', child: Text('Price: Low to High')),
                    DropdownMenuItem<String>(value: 'Price: High to Low', child: Text('Price: High to Low')),
                    DropdownMenuItem<String>(value: 'Inventory', child: Text('Inventory')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (products.isEmpty)
              const Expanded(
                child: EmptyState(
                  icon: Icons.search_off,
                  title: 'No items found',
                  message: 'Try adjusting the filters or searching with a different phrase.',
                ),
              )
            else
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.68,
                  ),
                  itemCount: products.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Product product = products[index];
                    return ProductCard(
                      product: product,
                      isFavorite: state.isFavorite(product),
                      onFavoriteToggle: () => state.toggleFavorite(product),
                      onTap: () => widget.onProductSelected(product),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Product> _sorted(List<Product> products) {
    switch (_sort) {
      case 'Price: Low to High':
        return products.toList()..sort((Product a, Product b) => a.price.compareTo(b.price));
      case 'Price: High to Low':
        return products.toList()..sort((Product a, Product b) => b.price.compareTo(a.price));
      case 'Inventory':
        return products.toList()..sort((Product a, Product b) => b.inventory.compareTo(a.inventory));
      default:
        return products;
    }
  }
}
