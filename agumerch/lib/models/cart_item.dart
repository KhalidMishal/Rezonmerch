import 'product.dart';

class CartItem {
  CartItem({
    required this.product,
    this.color,
    this.size,
    this.quantity = 1,
  });

  final Product product;
  final String? color;
  final String? size;
  int quantity;

  double get lineTotal => product.price * quantity;
}
