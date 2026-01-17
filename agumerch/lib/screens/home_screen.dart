import 'package:flutter/material.dart';

import '../models/product.dart';
import '../state/app_state.dart';
import '../widgets/product_card.dart';
import '../widgets/section_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onProductSelected,
    required this.onSeeAll,
  });

  final ValueChanged<Product> onProductSelected;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final AppState state = AppStateScope.of(context);
    final ThemeData theme = Theme.of(context);

    return ColoredBox(
      color: theme.colorScheme.surfaceContainerLowest,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
          children: <Widget>[
            _HeroBanner(onSeeAll: onSeeAll),
            const SizedBox(height: 24),
            _SearchField(
              initialValue: state.searchQuery,
              onChanged: state.updateSearchQuery,
            ),
            const SizedBox(height: 20),
            _CategoryFilter(
              categories: state.categories,
              activeCategory: state.activeCategory,
              onCategorySelected: state.setCategory,
            ),
            const SizedBox(height: 20),
            SectionHeader(
              title: 'Featured Drops',
              actionLabel: 'View catalog',
              onTap: onSeeAll,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 320,
              child: Builder(
                builder: (BuildContext ctx) {
                  final List<Product> featured =
                      state.filteredProducts.take(3).toList(growable: false);
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: featured.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (BuildContext context, int index) {
                      final Product product = featured[index];
                      return SizedBox(
                        width: 200,
                        child: ProductCard(
                          product: product,
                          isFavorite: state.isFavorite(product),
                          onFavoriteToggle: () =>
                              state.toggleFavorite(product),
                          onTap: () => onProductSelected(product),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            SectionHeader(title: 'Popular Categories'),
            const SizedBox(height: 12),
            _CategoryTiles(
              categories:
                  state.categories.where((String c) => c != 'All').toList(),
              onCategoryTap: (String category) {
                state.setCategory(category);
                onSeeAll();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.onSeeAll});

  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Rezon',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(
                    color:
                        Theme.of(context).colorScheme.onPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Elevated streetwear and accessories, designed for everyday style',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimary
                        .withValues(alpha: 0.85)),
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: onSeeAll,
            style: FilledButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.onPrimary),
            child: Text(
              'Browse collections',
              style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.initialValue,
    required this.onChanged,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: 'Search Rezon merchandise',
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({
    required this.categories,
    required this.activeCategory,
    required this.onCategorySelected,
  });

  final List<String> categories;
  final String activeCategory;
  final ValueChanged<String> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          final String category = categories[index];
          final bool isActive = category == activeCategory;
          return ChoiceChip(
            label: Text(category),
            selected: isActive,
            onSelected: (_) => onCategorySelected(category),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: categories.length,
      ),
    );
  }
}

class _CategoryTiles extends StatelessWidget {
  const _CategoryTiles({
    required this.categories,
    required this.onCategoryTap,
  });

  final List<String> categories;
  final ValueChanged<String> onCategoryTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: categories.length,
      itemBuilder: (BuildContext context, int index) {
        final String category = categories[index];
        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => onCategoryTap(category),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  _iconForCategory(category),
                  size: 28,
                  color:
                      Theme.of(context).colorScheme.primary,
                ),
                const Spacer(),
                Text(
                  category,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                          fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Apparel':
        return Icons.local_mall_outlined;
      case 'Accessories':
        return Icons.watch_outlined;
      case 'Stationery':
        return Icons.menu_book_outlined;
      default:
        return Icons.dashboard_outlined;
    }
  }
}
