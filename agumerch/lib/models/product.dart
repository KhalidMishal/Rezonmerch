class Product {
  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.description,
    this.threeDModelUrl,
    this.colors = const [],
    this.sizes = const [],
    this.inventory = 0,
    this.badges = const [],
  });

  final String id;
  final String name;
  final double price;
  final String category;
  final String imageUrl;
  final String description;
  final String? threeDModelUrl;
  final List<String> colors;
  final List<String> sizes;
  final int inventory;
  final List<String> badges;

  Product copyWith({
    String? name,
    double? price,
    String? category,
    String? imageUrl,
    String? threeDModelUrl,
    String? description,
    List<String>? colors,
    List<String>? sizes,
    int? inventory,
    List<String>? badges,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      threeDModelUrl: threeDModelUrl ?? this.threeDModelUrl,
      description: description ?? this.description,
      colors: colors ?? this.colors,
      sizes: sizes ?? this.sizes,
      inventory: inventory ?? this.inventory,
      badges: badges ?? this.badges,
    );
  }
}
