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

/// All staff / manager positions available in the restaurant tycoon.
final allManagers = <Manager>[
  Manager(
    id: 'chef_stove',
    name: 'Gordon (Master Range)',
    emoji: '👨‍🍳',
    rarity: ManagerRarity.legendary,
    affectsZone: ZoneType.kitchen,
    description: 'Culinary virtuoso managing hot stove sautés & flame broiling at Stove 1.',
    incomeBoost: 2.0,
    speedBoost: 3.0,
    isUnlocked: true,
    isAssigned: true,
  ),
  Manager(
    id: 'chef_prep',
    name: 'Pierre (Prep Artisan)',
    emoji: '🔪',
    rarity: ManagerRarity.rare,
    affectsZone: ZoneType.kitchen,
    description: 'Knife master at the central prep table cutting fresh vegetables & starters.',
    incomeBoost: 1.5,
    speedBoost: 2.0,
    isUnlocked: true,
    isAssigned: true,
  ),
  Manager(
    id: 'chef_sous',
    name: 'Antoine (Sous Chef)',
    emoji: '🍳',
    rarity: ManagerRarity.rare,
    affectsZone: ZoneType.kitchen,
    description: 'Expedites hot pass dishes and coordinates kitchen line output by +40%.',
    incomeBoost: 1.4,
    speedBoost: 1.8,
  ),
  Manager(
    id: 'chef_pastry',
    name: 'Marcel (Pastry & Bakery)',
    emoji: '🥐',
    rarity: ManagerRarity.epic,
    affectsZone: ZoneType.kitchen,
    description: 'Bakes artisanal breads and desserts, boosting meal earnings by +25%.',
    incomeBoost: 2.5,
    speedBoost: 2.0,
  ),
  Manager(
    id: 'waiter_1',
    name: 'Marco (Head Waiter)',
    emoji: '🤵',
    rarity: ManagerRarity.rare,
    affectsZone: ZoneType.diningRoom,
    description: 'Frontline banquet server. Upgrading boosts floor run speed and carrying capacity.',
    incomeBoost: 1.5,
    speedBoost: 2.0,
    isUnlocked: true,
    isAssigned: true,
  ),
  Manager(
    id: 'waiter_2',
    name: 'Sophia (Speed Runner)',
    emoji: '🏃‍♀️',
    rarity: ManagerRarity.rare,
    affectsZone: ZoneType.diningRoom,
    description: 'High-speed runner doubling dining room throughput and table turn speed.',
    incomeBoost: 1.5,
    speedBoost: 2.5,
    isUnlocked: true,
    isAssigned: true,
  ),
  Manager(
    id: 'waiter_3',
    name: 'Lucas (VIP Concierge)',
    emoji: '🍷',
    rarity: ManagerRarity.epic,
    affectsZone: ZoneType.diningRoom,
    description: 'Dedicated concierge expediting multi-dish orders for VIP critics and window booths.',
    incomeBoost: 2.0,
    speedBoost: 2.0,
  ),
  Manager(
    id: 'waiter_4',
    name: 'Elena (Banquet Server)',
    emoji: '🍽️',
    rarity: ManagerRarity.epic,
    affectsZone: ZoneType.diningRoom,
    description: 'Master server carrying up to 3 plates per run for rapid multi-table turnover.',
    incomeBoost: 2.2,
    speedBoost: 2.2,
  ),
  Manager(
    id: 'hostess',
    name: 'Chloe (Reception Hostess)',
    emoji: '💁‍♀️',
    rarity: ManagerRarity.common,
    affectsZone: ZoneType.reception,
    description: 'Welcomes arriving patrons at the podium, boosting guest patience by +35%.',
    speedBoost: 1.5,
    guestBoost: 1.35,
    isUnlocked: true,
    isAssigned: true,
  ),
  Manager(
    id: 'bartender',
    name: 'Leo (Lounge Mixologist)',
    emoji: '🍸',
    rarity: ManagerRarity.rare,
    affectsZone: ZoneType.lounge,
    description: 'Crafts shaken cocktails & pours vintage wines at the mahogany bar counter.',
    incomeBoost: 2.0,
    speedBoost: 2.0,
    isUnlocked: true,
    isAssigned: true,
  ),
  Manager(
    id: 'barista',
    name: 'Penny (Diner Barista)',
    emoji: '🥤',
    rarity: ManagerRarity.rare,
    affectsZone: ZoneType.milkshakeDiner,
    description: 'Blends malted shakes and dishes ice cream sundaes at the 50s Diner fountain.',
    incomeBoost: 1.8,
    speedBoost: 2.0,
    isUnlocked: true,
    isAssigned: true,
  ),
  Manager(
    id: 'janitor',
    name: 'Otis (Head Custodian)',
    emoji: '🧹',
    rarity: ManagerRarity.common,
    affectsZone: ZoneType.breakroom,
    description: 'Sweeps dining aisles, wipes down tables, and keeps the restaurant spotless.',
    speedBoost: 2.5,
    isUnlocked: true,
    isAssigned: true,
  ),
  Manager(
    id: 'manager',
    name: 'Arthur (General Manager)',
    emoji: '💼',
    rarity: ManagerRarity.legendary,
    affectsZone: ZoneType.managerOffice,
    description: 'Stationed in executive office. Triggers inspection tours that boost all stations +25%!',
    incomeBoost: 1.25,
    speedBoost: 1.25,
  ),
  // Legacy Aliases for backwards compatibility with earlier saves
  Manager(
    id: 'chef_pierre',
    name: 'Chef Pierre',
    emoji: '👨‍🍳',
    rarity: ManagerRarity.legendary,
    affectsZone: ZoneType.kitchen,
    description: 'Master chef specializing in French cuisine.',
    incomeBoost: 2.0,
    speedBoost: 2.5,
  ),
  Manager(
    id: 'victoria_concierge',
    name: 'Victoria',
    emoji: '👩‍💼',
    rarity: ManagerRarity.epic,
    affectsZone: ZoneType.reception,
    description: 'Expert concierge expediting check-ins.',
    speedBoost: 2.0,
    guestBoost: 1.5,
  ),
  Manager(
    id: 'rosa_maid',
    name: 'Rosa',
    emoji: '🧹',
    rarity: ManagerRarity.rare,
    affectsZone: ZoneType.restroom,
    description: 'Swift housekeeper maintaining spotless restrooms.',
    speedBoost: 3.0,
  ),
];
