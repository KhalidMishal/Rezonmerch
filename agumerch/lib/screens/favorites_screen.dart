import 'package:flutter/material.dart';

import '../models/product.dart';
import '../state/app_state.dart';
import '../widgets/empty_state.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key, required this.onProductSelected});

  final ValueChanged<Product> onProductSelected;

  @override
  Widget build(BuildContext context) {
    final AppState state = AppStateScope.of(context);
    final List<Product> favorites = state.products.where(state.isFavorite).toList();

    if (favorites.isEmpty) {
      return const SafeArea(
        child: EmptyState(
          icon: Icons.favorite_border,
          title: 'Favorites feel empty',
          message: 'Tap the heart icon on products to build your personalized AGU wishlist.',
        ),
      );
    }

    return SafeArea(
      bottom: false,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
        itemCount: favorites.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (BuildContext context, int index) {
          final Product product = favorites[index];
          return Dismissible(
            key: ValueKey<String>('favorite-${product.id}'),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => state.toggleFavorite(product),
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.onErrorContainer),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              tileColor: Theme.of(context).colorScheme.surface,
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(product.imageUrl, fit: BoxFit.cover, width: 70, height: 70),
              ),
              title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                       subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
              trailing: IconButton(
                icon: const Icon(Icons.open_in_new),
                onPressed: () => onProductSelected(product),
              ),
              onTap: () => onProductSelected(product),
            ),
          );
        },
      ),
    );
  }
}
