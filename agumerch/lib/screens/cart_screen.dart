import 'package:flutter/material.dart';

import '../models/cart_item.dart';
import '../state/app_state.dart';
import '../widgets/empty_state.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key, required this.onExplore});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final AppState state = AppStateScope.of(context);
    final List<CartItem> items = state.cartItems;

    if (items.isEmpty) {
      return SafeArea(
        child: EmptyState(
          icon: Icons.shopping_bag_outlined,
          title: 'Your cart is ready for merch',
          message: 'Add AGU gear to simulate the checkout experience.',
          action: FilledButton.icon(
            onPressed: onExplore,
            icon: const Icon(Icons.explore_outlined),
            label: const Text('Browse catalog'),
          ),
        ),
      );
    }

    return SafeArea(
      bottom: false,
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (BuildContext context, int index) {
                final CartItem item = items[index];
                return _CartTile(item: item, state: state);
              },
            ),
          ),
          _SummaryPanel(state: state),
        ],
      ),
    );
  }
}

class _CartTile extends StatelessWidget {
  const _CartTile({required this.item, required this.state});

  final CartItem item;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(item.product.imageUrl, width: 90, height: 90, fit: BoxFit.cover),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('\$${item.product.price.toStringAsFixed(2)}'),
                    if (item.color != null || item.size != null)
                      Text(
                        [item.color, item.size].whereType<String>().join(' • '),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => state.removeFromCart(item),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _QuantityStepper(
                quantity: item.quantity,
                onChange: (int value) => state.updateCartQuantity(item, value),
              ),
              Text(
                '\$${item.lineTotal.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({required this.quantity, required this.onChange});

  final int quantity;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          onPressed: quantity > 1 ? () => onChange(quantity - 1) : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text('$quantity', style: Theme.of(context).textTheme.titleMedium),
        IconButton(
          onPressed: () => onChange(quantity + 1),
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _SummaryRow(label: 'Subtotal', value: state.cartSubtotal),
          _SummaryRow(label: 'Campus tax (7%)', value: state.cartTaxEstimate),
          const SizedBox(height: 8),
          _SummaryRow(label: 'Total', value: state.cartTotal, emphasize: true),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _simulateCheckout(context),
            icon: const Icon(Icons.lock_open_outlined),
            label: const Text('Simulate checkout'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)),
          ),
        ],
      ),
    );
  }

  void _simulateCheckout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Checkout prototype'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Total: \$${state.cartTotal.toStringAsFixed(2)}'),
              const SizedBox(height: 12),
              const Text('This flow demonstrates the steps your real checkout would follow:'),
              const SizedBox(height: 12),
              const Text('1. Confirm shipping details\n2. Apply student discounts\n3. Complete payment securely'),
            ],
          ),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
            FilledButton(
              onPressed: () {
                state.clearCart();
                Navigator.of(context).pop();
              },
              child: const Text('Finish demo'),
            ),
          ],
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.emphasize = false});

  final String label;
  final double value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = emphasize
        ? Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)
        : Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Text(label),
          const Spacer(),
          Text('\$${value.toStringAsFixed(2)}', style: style),
        ],
      ),
    );
  }
}
