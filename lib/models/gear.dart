import 'package:flutter/material.dart';

enum GearRarity {
  common,
  rare,
  epic,
  legendary,
}

extension GearRarityExt on GearRarity {
  String get name {
    switch (this) {
      case GearRarity.common:
        return 'common';
      case GearRarity.rare:
        return 'rare';
      case GearRarity.epic:
        return 'epic';
      case GearRarity.legendary:
        return 'legendary';
    }
  }

  String get displayName {
    switch (this) {
      case GearRarity.common:
        return 'Common';
      case GearRarity.rare:
        return 'Rare';
      case GearRarity.epic:
        return 'Epic';
      case GearRarity.legendary:
        return 'Legendary';
    }
  }

  double get multiplier {
    switch (this) {
      case GearRarity.common:
        return 1.0;
      case GearRarity.rare:
        return 1.5;
      case GearRarity.epic:
        return 2.2;
      case GearRarity.legendary:
        return 3.2;
    }
  }

  Color get color {
    switch (this) {
      case GearRarity.common:
        return const Color(0xFFB0BEC5);
      case GearRarity.rare:
        return const Color(0xFF29B6F6);
      case GearRarity.epic:
        return const Color(0xFFBA68C8);
      case GearRarity.legendary:
        return const Color(0xFFFFD54F);
    }
  }

  static GearRarity fromString(String str) {
    switch (str.toLowerCase()) {
      case 'rare':
        return GearRarity.rare;
      case 'epic':
        return GearRarity.epic;
      case 'legendary':
        return GearRarity.legendary;
      default:
        return GearRarity.common;
    }
  }
}

class GearItem {
  final String id;
  final String name;
  final String slot; // 'head', 'body', 'tool'
  GearRarity rarity;
  int count;
  bool unlocked;
  final String icon;
  final double statInstantCook;
  final double statDivineDish;
  final double statWalkSpeed;
  final String desc;

  GearItem({
    required this.id,
    required this.name,
    required this.slot,
    this.rarity = GearRarity.common,
    this.count = 1,
    this.unlocked = true,
    required this.icon,
    this.statInstantCook = 0.0,
    this.statDivineDish = 0.0,
    this.statWalkSpeed = 0.0,
    required this.desc,
  });

  double get effectiveInstantCook => statInstantCook * rarity.multiplier;
  double get effectiveDivineDish => statDivineDish * rarity.multiplier;
  double get effectiveWalkSpeed => statWalkSpeed * rarity.multiplier;

  GearItem copyWith({
    String? id,
    String? name,
    String? slot,
    GearRarity? rarity,
    int? count,
    bool? unlocked,
    String? icon,
    double? statInstantCook,
    double? statDivineDish,
    double? statWalkSpeed,
    String? desc,
  }) {
    return GearItem(
      id: id ?? this.id,
      name: name ?? this.name,
      slot: slot ?? this.slot,
      rarity: rarity ?? this.rarity,
      count: count ?? this.count,
      unlocked: unlocked ?? this.unlocked,
      icon: icon ?? this.icon,
      statInstantCook: statInstantCook ?? this.statInstantCook,
      statDivineDish: statDivineDish ?? this.statDivineDish,
      statWalkSpeed: statWalkSpeed ?? this.statWalkSpeed,
      desc: desc ?? this.desc,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slot': slot,
    'rarity': rarity.name,
    'count': count,
    'unlocked': unlocked,
    'icon': icon,
    'stat_instant_cook': statInstantCook,
    'stat_divine_dish': statDivineDish,
    'stat_walk_speed': statWalkSpeed,
    'desc': desc,
  };

  factory GearItem.fromJson(Map<String, dynamic> json) {
    return GearItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slot: json['slot'] as String? ?? 'head',
      rarity: GearRarityExt.fromString(json['rarity'] as String? ?? 'common'),
      count: json['count'] as int? ?? 1,
      unlocked: json['unlocked'] as bool? ?? true,
      icon: json['icon'] as String? ?? '✨',
      statInstantCook: (json['stat_instant_cook'] as num?)?.toDouble() ?? 0.0,
      statDivineDish: (json['stat_divine_dish'] as num?)?.toDouble() ?? 0.0,
      statWalkSpeed: (json['stat_walk_speed'] as num?)?.toDouble() ?? 0.0,
      desc: json['desc'] as String? ?? '',
    );
  }

  static Map<String, GearItem> createDefaultInventory() {
    return {
      // Head Slot
      'toque': GearItem(
        id: 'toque',
        name: 'Classic Tall Toque',
        slot: 'head',
        rarity: GearRarity.common,
        count: 1,
        unlocked: true,
        icon: '👨‍🍳',
        statInstantCook: 5.0,
        statDivineDish: 0.0,
        statWalkSpeed: 5.0,
        desc: '+5% Instant Cook Chance, +5% Staff Walk Speed',
      ),
      'crown': GearItem(
        id: 'crown',
        name: 'Royal Golden Crown',
        slot: 'head',
        rarity: GearRarity.rare,
        count: 1,
        unlocked: true,
        icon: '👑',
        statInstantCook: 0.0,
        statDivineDish: 8.0,
        statWalkSpeed: 4.0,
        desc: '+8% Divine Dish Chance, +4% Staff Walk Speed',
      ),
      'visor': GearItem(
        id: 'visor',
        name: 'Neon Visor',
        slot: 'head',
        rarity: GearRarity.common,
        count: 1,
        unlocked: true,
        icon: '🥽',
        statInstantCook: 6.0,
        statDivineDish: 0.0,
        statWalkSpeed: 10.0,
        desc: '+6% Instant Cook Chance, +10% Staff Walk Speed',
      ),
      // Body Slot
      'apron': GearItem(
        id: 'apron',
        name: 'Butcher Apron',
        slot: 'body',
        rarity: GearRarity.common,
        count: 1,
        unlocked: true,
        icon: '🦺',
        statInstantCook: 6.0,
        statDivineDish: 3.0,
        statWalkSpeed: 0.0,
        desc: '+6% Instant Cook Chance, +3% Divine Dish Chance',
      ),
      'vest': GearItem(
        id: 'vest',
        name: 'Executive Silk Vest',
        slot: 'body',
        rarity: GearRarity.rare,
        count: 1,
        unlocked: true,
        icon: '👔',
        statInstantCook: 0.0,
        statDivineDish: 4.0,
        statWalkSpeed: 12.0,
        desc: '+12% Staff Walk Speed, +4% Divine Dish Chance',
      ),
      'jacket': GearItem(
        id: 'jacket',
        name: 'Michelin Gold Jacket',
        slot: 'body',
        rarity: GearRarity.epic,
        count: 1,
        unlocked: true,
        icon: '🧥',
        statInstantCook: 0.0,
        statDivineDish: 10.0,
        statWalkSpeed: 8.0,
        desc: '+10% Divine Dish Chance, +8% Staff Walk Speed',
      ),
      // Hand Tool Slot
      'skillet': GearItem(
        id: 'skillet',
        name: 'Cast-Iron Skillet',
        slot: 'tool',
        rarity: GearRarity.common,
        count: 1,
        unlocked: true,
        icon: '🍳',
        statInstantCook: 8.0,
        statDivineDish: 4.0,
        statWalkSpeed: 0.0,
        desc: '+8% Instant Cook Chance, +4% Divine Dish Chance',
      ),
      'spatula': GearItem(
        id: 'spatula',
        name: 'Golden Spatula',
        slot: 'tool',
        rarity: GearRarity.rare,
        count: 1,
        unlocked: true,
        icon: '🥢',
        statInstantCook: 10.0,
        statDivineDish: 6.0,
        statWalkSpeed: 0.0,
        desc: '+10% Instant Cook Chance, +6% Divine Dish Chance',
      ),
      'tray': GearItem(
        id: 'tray',
        name: 'Turbo Serving Tray',
        slot: 'tool',
        rarity: GearRarity.common,
        count: 1,
        unlocked: true,
        icon: '🍱',
        statInstantCook: 0.0,
        statDivineDish: 5.0,
        statWalkSpeed: 15.0,
        desc: '+15% Staff Walk Speed, +5% Divine Dish Chance',
      ),
    };
  }

  static Map<String, String> createDefaultEquipped() {
    return {
      'head': 'toque',
      'body': 'apron',
      'tool': 'skillet',
    };
  }
}
