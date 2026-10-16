/// Signature Dish Model representing the 5-Star Recipe Progression
/// (synchronized with Godot STAR_DISH_TIERS).
class StarDishTier {
  final int star;
  final String id;
  final String name;
  final String icon;
  final double price;
  final double multiplier;
  final String description;
  final int requiredLevel;

  const StarDishTier({
    required this.star,
    required this.id,
    required this.name,
    required this.icon,
    required this.price,
    required this.multiplier,
    required this.description,
    required this.requiredLevel,
  });

  Map<String, dynamic> toJson() => {
        'star': star,
        'id': id,
        'name': name,
        'icon': icon,
        'price': price,
        'multiplier': multiplier,
        'description': description,
        'required_level': requiredLevel,
      };
}

/// The 5 signature dishes corresponding to the 5 stars on the HUD bar.
const Map<int, StarDishTier> defaultStarDishTiers = {
  1: StarDishTier(
    star: 1,
    id: 'burger',
    name: 'Classic Diner Burger & Fries',
    icon: '🍔',
    price: 45.0,
    multiplier: 1.0,
    description: 'Crispy golden french fries paired with a fire-grilled beef patty on toasted brioche.',
    requiredLevel: 1,
  ),
  2: StarDishTier(
    star: 2,
    id: 'sundae',
    name: 'Retro Strawberry Sundae & Frappe',
    icon: '🍨',
    price: 120.0,
    multiplier: 2.5,
    description: 'Double strawberry sundae with whipped cream, cherry, and an icy retro diner frappe.',
    requiredLevel: 3,
  ),
  3: StarDishTier(
    star: 3,
    id: 'steak_platter',
    name: 'Double Cheese Steak Platter',
    icon: '🥩',
    price: 280.0,
    multiplier: 4.0,
    description: 'Thick sizzling seared ribeye platter smothered in melted double Wisconsin cheddar.',
    requiredLevel: 6,
  ),
  4: StarDishTier(
    star: 4,
    id: 'cocktail_tapas',
    name: 'Artisan Cocktail & Tapas Combo',
    icon: '🍸',
    price: 650.0,
    multiplier: 6.5,
    description: 'Handcrafted botanical cocktail paired with crunchy artisan tapas bites.',
    requiredLevel: 10,
  ),
  5: StarDishTier(
    star: 5,
    id: 'michelin_feast',
    name: 'Golden Michelin Lobster & Ribeye Feast',
    icon: '🦞',
    price: 1500.0,
    multiplier: 10.0,
    description: 'Supreme 5-star Michelin feast: butter-poached lobster and 24k gold ribeye.',
    requiredLevel: 15,
  ),
};
