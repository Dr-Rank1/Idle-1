import 'package:flutter/material.dart';

/// Represents a Sector Manager responsible for a specific zone
/// with active skills and cooldowns (matching the Kolibri Games manager system).
class SectorManager {
  final String sectorId;
  final String sectorName;
  String managerName;
  String tier; // 'junior', 'senior', 'executive'
  bool assigned;

  // Active Skill Attributes
  final String skillId;
  final String skillName;
  final String skillDesc;
  final String skillIcon;
  bool isActive;
  double activeTimer;
  double cooldownTimer;
  final double activeDuration;
  final double cooldownDuration;

  SectorManager({
    required this.sectorId,
    required this.sectorName,
    required this.managerName,
    this.tier = 'junior',
    this.assigned = true,
    required this.skillId,
    required this.skillName,
    required this.skillDesc,
    required this.skillIcon,
    this.isActive = false,
    this.activeTimer = 0.0,
    this.cooldownTimer = 0.0,
    this.activeDuration = 60.0,
    this.cooldownDuration = 300.0,
  });

  bool get canActivate => assigned && !isActive && cooldownTimer <= 0.0;

  double get activeProgress =>
      isActive && activeDuration > 0 ? (activeTimer / activeDuration).clamp(0.0, 1.0) : 0.0;

  double get cooldownProgress =>
      !isActive && cooldownDuration > 0
          ? (cooldownTimer / cooldownDuration).clamp(0.0, 1.0)
          : 0.0;

  Color get tierColor {
    switch (tier.toLowerCase()) {
      case 'executive':
        return const Color(0xFFFFB300); // Gold
      case 'senior':
        return const Color(0xFFAB47BC); // Purple
      case 'junior':
      default:
        return const Color(0xFF42A5F5); // Blue
    }
  }

  String get tierLabel => tier.toUpperCase();

  Map<String, dynamic> toJson() => {
        'sector_id': sectorId,
        'sector_name': sectorName,
        'manager_name': managerName,
        'tier': tier,
        'assigned': assigned,
        'skill_id': skillId,
        'skill_name': skillName,
        'skill_desc': skillDesc,
        'skill_icon': skillIcon,
        'is_active': isActive,
        'active_timer': activeTimer,
        'cooldown_timer': cooldownTimer,
        'active_duration': activeDuration,
        'cooldown_duration': cooldownDuration,
      };

  factory SectorManager.fromJson(Map<String, dynamic> json) {
    return SectorManager(
      sectorId: json['sector_id'] as String? ?? 'kitchen',
      sectorName: json['sector_name'] as String? ?? 'Kitchen',
      managerName: json['manager_name'] as String? ?? 'Manager',
      tier: json['tier'] as String? ?? 'junior',
      assigned: json['assigned'] as bool? ?? true,
      skillId: json['skill_id'] as String? ?? '',
      skillName: json['skill_name'] as String? ?? '',
      skillDesc: json['skill_desc'] as String? ?? '',
      skillIcon: json['skill_icon'] as String? ?? '⚡',
      isActive: json['is_active'] as bool? ?? false,
      activeTimer: (json['active_timer'] as num?)?.toDouble() ?? 0.0,
      cooldownTimer: (json['cooldown_timer'] as num?)?.toDouble() ?? 0.0,
      activeDuration: (json['active_duration'] as num?)?.toDouble() ?? 60.0,
      cooldownDuration: (json['cooldown_duration'] as num?)?.toDouble() ?? 300.0,
    );
  }
}

/// Default sector managers matching Godot GameManager sector_managers dictionary.
Map<String, SectorManager> createDefaultSectorManagers() => {
      'kitchen': SectorManager(
        sectorId: 'kitchen',
        sectorName: 'Commercial Kitchen',
        managerName: 'Chef Marcus',
        tier: 'senior',
        assigned: true,
        skillId: 'cooking_speed_2x',
        skillName: '2x Cooking Speed',
        skillDesc: 'All kitchen chefs prepare orders twice as fast.',
        skillIcon: '🍳',
        activeDuration: 60.0,
        cooldownDuration: 300.0,
      ),
      'dining': SectorManager(
        sectorId: 'dining',
        sectorName: 'Main Dining Hall',
        managerName: 'Maître Valerie',
        tier: 'executive',
        assigned: true,
        skillId: 'instant_table_clean',
        skillName: 'Instant Table Clean',
        skillDesc: 'Immediately wipes all dirty tables and accelerates bussing.',
        skillIcon: '🧽',
        activeDuration: 60.0,
        cooldownDuration: 300.0,
      ),
      'milkshake': SectorManager(
        sectorId: 'milkshake',
        sectorName: '50s Milkshake Cafe',
        managerName: 'Supervisor Dex',
        tier: 'junior',
        assigned: true,
        skillId: 'upgrade_cost_discount',
        skillName: '-30% Upgrade Cost',
        skillDesc: 'Grants a 30% discount across all station and furniture upgrades.',
        skillIcon: '🏷️',
        activeDuration: 60.0,
        cooldownDuration: 300.0,
      ),
      'lounge': SectorManager(
        sectorId: 'lounge',
        sectorName: 'Cocktail Lounge',
        managerName: 'Director Evelyn',
        tier: 'senior',
        assigned: true,
        skillId: 'walk_speed_boost',
        skillName: '+100% Walk Speed',
        skillDesc: 'Waiters and servers sprint at +100% walk speed.',
        skillIcon: '👟',
        activeDuration: 60.0,
        cooldownDuration: 300.0,
      ),
    };
