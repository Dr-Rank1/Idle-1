import 'dart:ui';
import 'enums.dart';

/// A functional station in the resort (reception desk, stove, table, hotel room).
class Station {
  final String id;
  final ZoneType zone;
  final String name;

  // Grid position (top-left of the station footprint)
  final double gx;
  final double gy;
  final int widthTiles;
  final int heightTiles;

  // Level & upgrade
  int level;
  int maxLevel;

  // Is a guest or staff occupying this station right now?
  String? occupiedByCharacterId;
  bool get isOccupied => occupiedByCharacterId != null;

  // Upgrade cost & income stats
  double Function(int level) baseCostFn;
  double Function(int level) baseIncomeFn;
  double Function(int level) baseSpeedFn; // seconds per action

  // Manager boost multipliers (applied by the game engine)
  double incomeMultiplier = 1.0;
  double speedMultiplier = 1.0;

  // Computed from level + multipliers
  double get upgradeCost => baseCostFn(level);
  double get income => baseIncomeFn(level) * incomeMultiplier;
  double get actionDuration => baseSpeedFn(level) / speedMultiplier;

  // For kitchen stoves: how much food is ready to be served?
  bool foodReady = false;
  double cookTimer = 0.0;

  // For hotel rooms: dirty after checkout?
  bool isDirty = false;
  double cleanTimer = 0.0;

  // Visual progress bar (0.0–1.0)
  double progressFraction = 0.0;

  // Center of the station in grid coords for character targeting
  Offset get centerGrid => Offset(gx + widthTiles / 2, gy + heightTiles / 2);

  // Queue point (where guests stand to wait outside the station)
  Offset queuePoint;

  Station({
    required this.id,
    required this.zone,
    required this.name,
    required this.gx,
    required this.gy,
    this.widthTiles = 1,
    this.heightTiles = 1,
    this.level = 1,
    this.maxLevel = 20,
    required this.baseCostFn,
    required this.baseIncomeFn,
    required this.baseSpeedFn,
    Offset? queuePoint,
  }) : queuePoint = queuePoint ?? Offset(gx - 1, gy + 0.5);
}
