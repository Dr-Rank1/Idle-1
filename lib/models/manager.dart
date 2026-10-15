import 'package:flutter/material.dart';
import 'enums.dart';


/// A manager card that can be assigned to boost a zone.
class Manager {
  final String id;
  final String name;
  final String emoji;
  final ManagerRarity rarity;
  final ZoneType affectsZone;
  final String description;

  // Boost values
  final double incomeBoost;   // multiplier, e.g. 2.0 = +100%
  final double speedBoost;    // multiplier, e.g. 1.5 = 50% faster
  final double guestBoost;    // extra guest patience multiplier

  bool isUnlocked;
  bool isAssigned;

  Manager({
    required this.id,
    required this.name,
    required this.emoji,
    required this.rarity,
    required this.affectsZone,
    required this.description,
    this.incomeBoost = 1.0,
    this.speedBoost = 1.0,
    this.guestBoost = 1.0,
    this.isUnlocked = false,
    this.isAssigned = false,
  });

  Color get rarityColor {
    switch (rarity) {
      case ManagerRarity.common:
        return const Color(0xFF9E9E9E);
      case ManagerRarity.rare:
        return const Color(0xFF2196F3);
      case ManagerRarity.epic:
        return const Color(0xFF9C27B0);
      case ManagerRarity.legendary:
        return const Color(0xFFFF9800);
    }
  }

  String get rarityLabel {
    switch (rarity) {
      case ManagerRarity.common:
        return 'COMMON';
      case ManagerRarity.rare:
        return 'RARE';
      case ManagerRarity.epic:
        return 'EPIC';
      case ManagerRarity.legendary:
        return 'LEGENDARY';
    }
  }
}

/// All manager cards available in the game.
final allManagers = <Manager>[
  Manager(
    id: 'chef_pierre',
    name: 'Chef Pierre',
    emoji: '👨‍🍳',
    rarity: ManagerRarity.legendary,
    affectsZone: ZoneType.kitchen,
    description: 'World-renowned chef. Kitchen speed ×3, meal income ×2.',
    incomeBoost: 2.0,
    speedBoost: 3.0,
  ),
  Manager(
    id: 'victoria_concierge',
    name: 'Victoria',
    emoji: '👩‍💼',
    rarity: ManagerRarity.epic,
    affectsZone: ZoneType.reception,
    description: 'Expert concierge. Check-in speed ×2.5, guest patience ×1.5.',
    speedBoost: 2.5,
    guestBoost: 1.5,
  ),
  Manager(
    id: 'rosa_maid',
    name: 'Rosa',
    emoji: '🧹',
    rarity: ManagerRarity.rare,
    affectsZone: ZoneType.hotelRoom,
    description: 'Swift housekeeper. Cleaning speed ×4.',
    speedBoost: 4.0,
  ),
  Manager(
    id: 'marco_waiter',
    name: 'Marco',
    emoji: '🤵',
    rarity: ManagerRarity.rare,
    affectsZone: ZoneType.diningRoom,
    description: 'Seasoned waiter. Tip income ×2, serving speed ×2.',
    incomeBoost: 2.0,
    speedBoost: 2.0,
  ),
  Manager(
    id: 'lisa_hostess',
    name: 'Lisa',
    emoji: '💁‍♀️',
    rarity: ManagerRarity.common,
    affectsZone: ZoneType.lobby,
    description: 'Friendly hostess. Guests arrive 50% faster.',
    speedBoost: 1.5,
  ),
  Manager(
    id: 'tony_sommelier',
    name: 'Tony',
    emoji: '🍷',
    rarity: ManagerRarity.epic,
    affectsZone: ZoneType.diningRoom,
    description: 'Master sommelier. Dining income ×3.',
    incomeBoost: 3.0,
  ),
  Manager(
    id: 'arthur_manager',
    name: 'Arthur (GM)',
    emoji: '💼',
    rarity: ManagerRarity.legendary,
    affectsZone: ZoneType.managerOffice,
    description: 'Executive general manager. Floor inspections boost all stations +25%.',
    incomeBoost: 1.25,
    speedBoost: 1.25,
  ),
  Manager(
    id: 'leo_mixologist',
    name: 'Leo (Mixologist)',
    emoji: '🍸',
    rarity: ManagerRarity.rare,
    affectsZone: ZoneType.lounge,
    description: 'Master craft mixologist. Cocktail speed ×2, cash tips ×2.',
    incomeBoost: 2.0,
    speedBoost: 2.0,
  ),
  Manager(
    id: 'penny_barista',
    name: 'Penny (Barista)',
    emoji: '🥤',
    rarity: ManagerRarity.rare,
    affectsZone: ZoneType.milkshakeDiner,
    description: 'Vintage soda fountain lead. Sundae & shake prep speed ×2.',
    incomeBoost: 1.8,
    speedBoost: 2.0,
  ),
  Manager(
    id: 'otis_custodian',
    name: 'Otis (Custodian)',
    emoji: '🧹',
    rarity: ManagerRarity.common,
    affectsZone: ZoneType.breakroom,
    description: 'Head custodian. Fast table turnover and quick breakroom recovery.',
    speedBoost: 2.5,
  ),
  Manager(
    id: 'marcel_pastry',
    name: 'Marcel (Pastry)',
    emoji: '🥐',
    rarity: ManagerRarity.epic,
    affectsZone: ZoneType.kitchen,
    description: 'Artisan patissier. Dessert meal values ×2.5, baking speed ×2.',
    incomeBoost: 2.5,
    speedBoost: 2.0,
  ),
];
