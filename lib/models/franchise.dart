/// Model representing an unlocked or discoverable restaurant location on the World Map.
class WorldRestaurant {
  final String id;
  final String name;
  final String icon;
  final String tagline;
  final int stars;
  final double multiplier;
  bool unlocked;
  final double cost;

  WorldRestaurant({
    required this.id,
    required this.name,
    required this.icon,
    required this.tagline,
    required this.stars,
    required this.multiplier,
    required this.unlocked,
    required this.cost,
  });

  factory WorldRestaurant.fromJson(Map<String, dynamic> json) {
    return WorldRestaurant(
      id: json['id'] as String? ?? 'idle_diner',
      name: json['name'] as String? ?? 'Idle Diner',
      icon: json['icon'] as String? ?? '🍔',
      tagline: json['tagline'] as String? ?? '',
      stars: (json['stars'] as num?)?.toInt() ?? 5,
      multiplier: (json['multiplier'] as num?)?.toDouble() ?? 1.0,
      unlocked: json['unlocked'] as bool? ?? false,
      cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'icon': icon,
    'tagline': tagline,
    'stars': stars,
    'multiplier': multiplier,
    'unlocked': unlocked,
    'cost': cost,
  };
}

/// Baseline world restaurant empire locations matching Godot GameManager.
final List<WorldRestaurant> defaultWorldRestaurants = [
  WorldRestaurant(
    id: 'idle_diner',
    name: 'Idle Diner',
    icon: '🍔',
    tagline: 'Classic 1950s American Diner • 100% Max Level Complete',
    stars: 5,
    multiplier: 1.0,
    unlocked: true,
    cost: 0.0,
  ),
  WorldRestaurant(
    id: 'idles_chain',
    name: "Idle's Chain",
    icon: '🍟',
    tagline: 'Fast Food Drive-Thru Franchise',
    stars: 3,
    multiplier: 3.5,
    unlocked: false,
    cost: 5000.0,
  ),
  WorldRestaurant(
    id: 'snowy_peaks',
    name: 'Snowy Peaks',
    icon: '⛷️',
    tagline: 'Alpine Mountain Fondue Lodge',
    stars: 2,
    multiplier: 10.0,
    unlocked: false,
    cost: 25000.0,
  ),
  WorldRestaurant(
    id: 'taverna_athena',
    name: 'Taverna Athena',
    icon: '🏛️',
    tagline: 'Aegean Seaside Seafood Taverna',
    stars: 4,
    multiplier: 25.0,
    unlocked: false,
    cost: 100000.0,
  ),
  WorldRestaurant(
    id: 'noodle_palace',
    name: 'Noodle Palace',
    icon: '🍜',
    tagline: 'High-Altitude Ramen & Dim Sum Temple',
    stars: 3,
    multiplier: 60.0,
    unlocked: false,
    cost: 450000.0,
  ),
  WorldRestaurant(
    id: 'sakura_springs',
    name: 'Sakura Springs',
    icon: '🌸',
    tagline: 'Zen Garden Kaiseki & Tea Sanctuary',
    stars: 5,
    multiplier: 150.0,
    unlocked: false,
    cost: 2000000.0,
  ),
];
