import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../logic/game_state.dart';

/// Persists game state to local SharedPreferences.
class SaveService {
  static const _keyData = 'hotel_save_v1';
  static const _keyTimestamp = 'hotel_save_ts';

  static Future<void> save(GameState gs) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'cash': gs.cash,
      'totalEarned': gs.totalEarned,
      'reputation': gs.reputation,
      'hotelName': gs.hotelName,
      'stations': gs.stations.map((s) => {
        'id': s.id,
        'level': s.level,
      }).toList(),
      'managers': gs.managers.map((m) => {
        'id': m.id,
        'isUnlocked': m.isUnlocked,
        'isAssigned': m.isAssigned,
      }).toList(),
    };
    await prefs.setString(_keyData, jsonEncode(data));
    await prefs.setInt(
        _keyTimestamp, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<void> load(GameState gs) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyData);
    final ts = prefs.getInt(_keyTimestamp);

    if (raw == null) return;

    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      gs.cash = (data['cash'] as num?)?.toDouble() ?? gs.cash;
      gs.totalEarned = (data['totalEarned'] as num?)?.toDouble() ?? 0;
      gs.reputation = (data['reputation'] as int?) ?? 1;
      gs.hotelName = (data['hotelName'] as String?) ?? gs.hotelName;

      // Restore station levels
      final stationData = data['stations'] as List<dynamic>?;
      if (stationData != null) {
        for (final sd in stationData) {
          final id = sd['id'] as String;
          final level = sd['level'] as int;
          final s = gs.stations.firstWhere(
            (s) => s.id == id,
            orElse: () => gs.stations.first,
          );
          if (s.id == id) s.level = level;
        }
      }

      // Restore managers
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

      // Calculate offline earnings
      if (ts != null) {
        final elapsed = DateTime.now().millisecondsSinceEpoch - ts;
        final elapsedSeconds = elapsed / 1000.0;
        // Cap at 8 hours
        final cappedSeconds = elapsedSeconds.clamp(0, 8 * 3600).toDouble();
        // Rough offline rate: sum of all station incomes
        final incomeRate = gs.stations.fold(
            0.0, (sum, s) => sum + s.income / s.actionDuration);
        gs.offlineEarnings = incomeRate * cappedSeconds * 0.25; // 25% efficiency offline
      }
    } catch (_) {
      // Corrupted save — just continue fresh
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyData);
    await prefs.remove(_keyTimestamp);
  }
}
