import '../models/product.dart';

final List<Product> mockProducts = [
  Product(
    id: 'hoodie-agu-classic',
    name: 'Rezon Classic Hoodie',
    price: 925.0,
    category: 'Apparel',
    imageUrl:
        'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=800&q=80',
    description:
        'Premium cotton hoodie with embroidered Rezon crest. Designed for everyday comfort and campus pride.',
    threeDModelUrl: 'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
    colors: ['Midnight Blue', 'Charcoal Gray', 'Campus Green'],
    sizes: ['XS', 'S', 'M', 'L', 'XL'],
    inventory: 32,
    badges: ['Top Seller'],
  ),
  Product(
    id: 'tee-agu-statement',
    name: 'Statement Tee',
    price: 375.0,
    category: 'Apparel',
    imageUrl:
        'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=800&q=80',
    description:
        'Soft-touch shirt featuring the new Rezon typography lockup. Lightweight and breathable.',
    colors: ['Arctic White', 'Sunset Coral'],
    sizes: ['S', 'M', 'L', 'XL'],
    inventory: 60,
    badges: ['New'],
  ),
  Product(
    id: 'bottle-agu-hydro',
    name: 'Hydro Sport Bottle',
    price: 275.0,
    category: 'Accessories',
    imageUrl:
        'https://images.unsplash.com/photo-1514996937319-344454492b37?auto=format&fit=crop&w=800&q=80',
    description:
        'Insulated water bottle keeps drinks cold for 24 hours. Laser-etched Rezon crest with matte finish.',
    colors: ['Matte Black', 'Polar White'],
    sizes: ['600ml'],
    inventory: 75,
    badges: ['Eco'],
  ),
  Product(
    id: 'cap-agu-retro',
    name: 'Retro Baseball Cap',
    price: 325.0,
    category: 'Accessories',
    imageUrl:
        'https://images.unsplash.com/photo-1503342394128-c104d54dba01?auto=format&fit=crop&w=800&q=80',
    description:
        'Throwback corduroy cap with raised Rezon lettering. Adjustable back closure and interior moisture band.',
    colors: ['Vintage Maroon', 'Denim Blue'],
    sizes: ['One Size'],
    inventory: 42,
    badges: ['Campus Favorite'],
  ),
  Product(
    id: 'notebook-agu-grid',
    name: 'Grid Notebook Set',
    price: 190.0,
    category: 'Stationery',
    imageUrl:
        'https://images.unsplash.com/photo-1521587760476-6c12a4b040da?auto=format&fit=crop&w=800&q=80',
    description:
        'Three-pack of recycled paper notebooks with subtle Rezon branding. Includes dotted, lined, and blank pages.',
    colors: ['Neutral'],
    sizes: ['A5'],
    inventory: 120,
    badges: ['Sustainable'],
  ),
  Product(
    id: 'jacket-agu-tech',
    name: 'All-Weather Tech Jacket',
    price: 1975.0,
    category: 'Apparel',
    imageUrl:
        'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?auto=format&fit=crop&w=800&q=80',
    description:
        'Lightweight waterproof shell with reflective accents and thermal lining. Engineered for campus commuters.',
    colors: ['Graphite', 'Storm Navy'],
    sizes: ['S', 'M', 'L', 'XL'],
    inventory: 18,
    badges: ['Limited'],
  ),
];
