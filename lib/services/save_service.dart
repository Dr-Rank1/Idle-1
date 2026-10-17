import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../logic/game_state.dart';
import '../models/gear.dart';
import '../models/guest_review.dart';

/// Persists game state to local SharedPreferences and synchronizes with
/// the Godot Restaurant Tycoon 3D save file (user://restaurant_save.json).
class SaveService {
  static const _keyData = 'hotel_save_v1';
  static const _keyTimestamp = 'hotel_save_ts';

  /// Resolves the Godot app_userdata path on Linux, Windows, or macOS if present.
  static File? _getGodotSaveFile() {
    if (kIsWeb) return null;
    try {
      String? dirPath;
      if (Platform.isLinux) {
        final home = Platform.environment['HOME'];
        if (home != null) {
          dirPath = '$home/.local/share/godot/app_userdata/Idle Restaurant Tycoon 3D';
        }
      } else if (Platform.isWindows) {
        final appData = Platform.environment['APPDATA'];
        if (appData != null) {
          dirPath = '$appData/Godot/app_userdata/Idle Restaurant Tycoon 3D';
        }
      } else if (Platform.isMacOS) {
        final home = Platform.environment['HOME'];
        if (home != null) {
          dirPath = '$home/Library/Application Support/Godot/app_userdata/Idle Restaurant Tycoon 3D';
        }
      }
      if (dirPath != null) {
        return File('$dirPath/restaurant_save.json');
      }
    } catch (_) {}
    return null;
  }

  static Future<void> save(GameState gs) async {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final nowSec = nowMs / 1000.0;

    final stationLevels = <String, int>{};
    for (final s in gs.stations) {
      stationLevels[s.id] = s.level;
    }

    final data = <String, dynamic>{
      'cash': gs.cash,
      'gems': gs.gems,
      'total_earned': gs.totalEarned,
      'totalEarned': gs.totalEarned,
      'star_rating': gs.starRating,
      'reputation': gs.reputation,
      'prestigeStars': gs.prestigeStars,
      'prestige_level': gs.prestigeLevel,
      'franchise_keys': gs.franchiseKeys,
      'restaurant_valuation': gs.getRestaurantValuation(),
      'restaurant_name': gs.restaurantName,
      'hotelName': gs.hotelName,
      'restaurant_level': gs.restaurantLevel,
      'restaurant_xp': gs.restaurantXp,
      'marketing_level': gs.marketingLevel,
      'unlocked_stalls': gs.unlockedStalls,
      'terrace_unlocked': gs.terraceUnlocked,
      'unlocked_tables': gs.unlockedTables,
      'station_levels': stationLevels,
      'cash_per_sec': gs.cashPerSecond,
      'saved_timestamp': nowSec,
      'stations': gs.stations.map((s) => {
        'id': s.id,
        'level': s.level,
      }).toList(),
      'managers': gs.managers.map((m) => {
        'id': m.id,
        'isUnlocked': m.isUnlocked,
        'isAssigned': m.isAssigned,
      }).toList(),
      'sector_managers': gs.sectorManagers.map((k, v) => MapEntry(k, v.toJson())),
      'unlocked_star_tiers': gs.unlockedStarTiers,
      'claimed_star_rewards': gs.claimedStarRewards,
      'piggy_bank_diamonds': gs.piggyBankDiamonds,
      'tutorial_completed': gs.tutorialCompleted,
      'tutorial_step': gs.tutorialStep,
      'equipped_gear': gs.equippedGear,
      'gear_inventory': gs.gearInventory.map((k, v) => MapEntry(k, v.toJson())),
      'recent_guest_reviews': gs.recentGuestReviews.map((r) => r.toJson()).toList(),
    };

    final jsonStr = jsonEncode(data);

    // 1. Persist to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyData, jsonStr);
    await prefs.setInt(_keyTimestamp, nowMs);

    // 2. Persist to Godot save file if directory exists
    try {
      final godotFile = _getGodotSaveFile();
      if (godotFile != null && godotFile.parent.existsSync()) {
        await godotFile.writeAsString(const JsonEncoder.withIndent('\t').convert(data));
      }
    } catch (_) {}
  }

  static Future<void> load(GameState gs) async {
    Map<String, dynamic>? data;
    num? savedTs;

    // 1. Try reading directly from Godot save file first
    try {
      final godotFile = _getGodotSaveFile();
      if (godotFile != null && godotFile.existsSync()) {
        final content = await godotFile.readAsString();
        data = jsonDecode(content) as Map<String, dynamic>?;
        if (data != null && data.containsKey('saved_timestamp')) {
          savedTs = data['saved_timestamp'] as num?;
        }
      }
    } catch (_) {}

    // 2. Fall back to SharedPreferences if file not available
    if (data == null) {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyData);
      if (raw != null) {
        try {
          data = jsonDecode(raw) as Map<String, dynamic>?;
          savedTs = prefs.getInt(_keyTimestamp);
        } catch (_) {}
      }
    }

    if (data == null) return;

    try {
      gs.cash = (data['cash'] as num?)?.toDouble() ?? gs.cash;
      gs.gems = (data['gems'] as num?)?.toInt() ?? gs.gems;
      gs.totalEarned = (data['total_earned'] as num?)?.toDouble() ??
          (data['totalEarned'] as num?)?.toDouble() ??
          gs.totalEarned;
      gs.starRating = (data['star_rating'] as num?)?.toDouble() ?? gs.starRating;
      gs.reputation = (data['reputation'] as int?) ?? gs.reputation;
      gs.prestigeStars = (data['prestigeStars'] as int?) ?? gs.prestigeStars;
      gs.prestigeLevel = (data['prestige_level'] as int?) ?? gs.prestigeLevel;
      gs.franchiseKeys = (data['franchise_keys'] as int?) ?? gs.franchiseKeys;
      gs.restaurantValuation = (data['restaurant_valuation'] as num?)?.toDouble() ?? gs.getRestaurantValuation();
      gs.restaurantName = (data['restaurant_name'] as String?) ??
          (data['hotelName'] as String?) ??
          gs.restaurantName;
      gs.hotelName = gs.restaurantName;
      gs.restaurantLevel = (data['restaurant_level'] as int?) ?? gs.restaurantLevel;
      gs.restaurantXp = (data['restaurant_xp'] as num?)?.toDouble() ?? gs.restaurantXp;
      gs.marketingLevel = (data['marketing_level'] as int?) ?? gs.marketingLevel;
      gs.unlockedStalls = (data['unlocked_stalls'] as int?) ?? gs.unlockedStalls;
      gs.terraceUnlocked = (data['terrace_unlocked'] as bool?) ?? gs.terraceUnlocked;

      // Restore unlocked tables
      final tableMap = data['unlocked_tables'] as Map<String, dynamic>?;
      if (tableMap != null) {
        for (final entry in tableMap.entries) {
          gs.unlockedTables[entry.key] = entry.value as bool;
        }
      }

      // Restore station levels from station_levels map
      final levelMap = data['station_levels'] as Map<String, dynamic>?;
      if (levelMap != null) {
        for (final s in gs.stations) {
          if (levelMap.containsKey(s.id)) {
            s.level = (levelMap[s.id] as num).toInt();
          } else if (s.id == 'kitchen_cook' && levelMap.containsKey('stove')) {
            s.level = (levelMap['stove'] as num).toInt();
          } else if (s.id == 'parking_lot' && levelMap.containsKey('parking')) {
            s.level = (levelMap['parking'] as num).toInt();
          } else if (s.id == 'cocktail_lounge' && levelMap.containsKey('cocktail_bar')) {
            s.level = (levelMap['cocktail_bar'] as num).toInt();
          }
        }
      }

      // Restore station levels from legacy list if present
      final stationList = data['stations'] as List<dynamic>?;
      if (stationList != null && levelMap == null) {
        for (final sd in stationList) {
          final id = sd['id'] as String;
          final level = sd['level'] as int;
          final s = gs.stations.firstWhere(
            (s) => s.id == id,
            orElse: () => gs.stations.first,
          );
          if (s.id == id) s.level = level;
        }
      }

      // Restore managers / staff
      final managerData = data['managers'] as List<dynamic>?;
      if (managerData != null) {
        for (final md in managerData) {
          final id = md['id'] as String;
          final m = gs.managers.firstWhere((m) => m.id == id,
              orElse: () => gs.managers.first);
          if (m.id == id) {
            m.isUnlocked = md['isUnlocked'] as bool? ?? false;
            m.isAssigned = md['isAssigned'] as bool? ?? false;
          }
        }
      }

      // Also restore staff roster from Godot format if present
      final staffRoster = data['staff_roster'] as Map<String, dynamic>?;
      if (staffRoster != null) {
        for (final entry in staffRoster.entries) {
          final sid = entry.key;
          final sdata = entry.value as Map<String, dynamic>;
          final hired = sdata['hired'] as bool? ?? false;
          final m = gs.managers.firstWhere(
            (m) => m.id == sid,
            orElse: () => gs.managers.first,
          );
          if (m.id == sid) {
            m.isUnlocked = hired;
            m.isAssigned = hired;
          }
        }
      }

      // Restore sector managers
      final sectorMgrData = data['sector_managers'] as Map<String, dynamic>?;
      if (sectorMgrData != null) {
        for (final entry in sectorMgrData.entries) {
          final secId = entry.key;
          final mdata = entry.value as Map<String, dynamic>;
          if (gs.sectorManagers.containsKey(secId)) {
            final mgr = gs.sectorManagers[secId]!;
            mgr.tier = mdata['tier'] as String? ?? mgr.tier;
            mgr.assigned = mdata['assigned'] as bool? ?? mgr.assigned;
            mgr.isActive = mdata['is_active'] as bool? ?? false;
            mgr.activeTimer = (mdata['active_timer'] as num?)?.toDouble() ?? 0.0;
            mgr.cooldownTimer = (mdata['cooldown_timer'] as num?)?.toDouble() ?? 0.0;
          }
        }
      }

      // Restore unlocked star dish tiers
      final unlockedTiers = data['unlocked_star_tiers'] as List<dynamic>?;
      if (unlockedTiers != null) {
        gs.unlockedStarTiers.clear();
        for (final t in unlockedTiers) {
          if (t is num) gs.unlockedStarTiers.add(t.toInt());
        }
        if (gs.unlockedStarTiers.isEmpty) gs.unlockedStarTiers.add(1);
      }

      // Restore claimed star rewards
      final claimedRewards = data['claimed_star_rewards'] as List<dynamic>?;
      if (claimedRewards != null) {
        gs.claimedStarRewards.clear();
        for (final r in claimedRewards) {
          if (r is num) gs.claimedStarRewards.add(r.toInt());
        }
      }

      // Restore piggy bank diamonds
      gs.piggyBankDiamonds = (data['piggy_bank_diamonds'] as num?)?.toInt() ?? gs.piggyBankDiamonds;

      // Restore tutorial state
      if (data.containsKey('tutorial_completed')) {
        gs.tutorialCompleted = data['tutorial_completed'] as bool? ?? gs.tutorialCompleted;
      }
      if (data.containsKey('tutorial_step')) {
        gs.tutorialStep = (data['tutorial_step'] as num?)?.toInt() ?? gs.tutorialStep;
      }

      // Restore gear loadout & inventory
      final eqGear = data['equipped_gear'] as Map<String, dynamic>?;
      if (eqGear != null) {
        for (final entry in eqGear.entries) {
          if (entry.value is String) {
            gs.equippedGear[entry.key] = entry.value as String;
          }
        }
      }

      final gearInv = data['gear_inventory'] as Map<String, dynamic>?;
      if (gearInv != null) {
        for (final entry in gearInv.entries) {
          final gid = entry.key;
          final gdata = entry.value as Map<String, dynamic>;
          if (gs.gearInventory.containsKey(gid)) {
            final item = gs.gearInventory[gid]!;
            if (gdata.containsKey('rarity')) {
              item.rarity = GearRarityExt.fromString(gdata['rarity'] as String);
            }
            if (gdata.containsKey('count')) {
              item.count = (gdata['count'] as num).toInt();
            }
            if (gdata.containsKey('unlocked')) {
              item.unlocked = gdata['unlocked'] as bool;
            }
          } else {
            gs.gearInventory[gid] = GearItem.fromJson(gdata);
          }
        }
      }

      // Restore recent guest reviews
      final reviewsData = data['recent_guest_reviews'] as List<dynamic>?;
      if (reviewsData != null && reviewsData.isNotEmpty) {
        gs.recentGuestReviews.clear();
        for (final r in reviewsData) {
          if (r is Map<String, dynamic>) {
            gs.recentGuestReviews.add(GuestReview.fromJson(r));
          }
        }
      }

      // Calculate offline earnings: min(ElapsedSeconds, 28800) * CashPerSecond * 0.85
      savedTs ??= data['saved_timestamp'] as num?;
      if (savedTs != null && savedTs > 0) {
        double elapsedSeconds = 0.0;
        final nowMs = DateTime.now().millisecondsSinceEpoch;
        if (savedTs > 10000000000) {
          // Stored as milliseconds
          elapsedSeconds = (nowMs - savedTs) / 1000.0;
        } else {
          // Stored as Unix timestamp seconds (Godot style)
          elapsedSeconds = (nowMs / 1000.0) - savedTs;
        }

        if (elapsedSeconds >= 30.0) {
          final cappedSeconds = min(elapsedSeconds, 28800.0); // Up to 8 hours
          final rate = gs.cashPerSecond > 0 ? gs.cashPerSecond : 14.0;
          gs.offlineEarnings = (cappedSeconds * rate * 0.85).roundToDouble();
        }
      }
    } catch (_) {
      // Corrupted save — continue fresh
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyData);
    await prefs.remove(_keyTimestamp);
  }
}
