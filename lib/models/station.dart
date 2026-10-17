import 'dart:math';
import 'dart:ui';
import 'enums.dart';

/// A functional station in the restaurant resort (table, kitchen stove, bar, parking).
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
  bool isUnlocked;

  // Exact exponential multipliers synchronized with Godot GameManager
  // Formula: Cost = BaseCost * CostMultiplier^(L - 1)
  // Formula: Revenue = BaseRevenue * RevenueMultiplier^(L - 1)
  final double baseCost;
  final double costMultiplier;
  final double baseRevenue;
  final double revenueMultiplier;

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
  double get upgradeCost => level >= maxLevel ? 0.0 : baseCostFn(level);
  double get income => baseIncomeFn(level) * incomeMultiplier;
  double get actionDuration => baseSpeedFn(level) / speedMultiplier;

  // For kitchen stoves: how much food is ready to be served?
  bool foodReady = false;
  double cookTimer = 0.0;

  // For hotel rooms / restrooms: dirty after checkout?
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
    this.maxLevel = 50,
    this.isUnlocked = true,
    this.baseCost = 50.0,
    this.costMultiplier = 1.15,
    this.baseRevenue = 15.0,
    this.revenueMultiplier = 1.10,
    double Function(int level)? baseCostFn,
    double Function(int level)? baseIncomeFn,
    double Function(int level)? baseSpeedFn,
    Offset? queuePoint,
  })  : baseCostFn = baseCostFn ??
            ((l) => (baseCost * pow(costMultiplier, l - 1)).roundToDouble()),
        baseIncomeFn = baseIncomeFn ??
            ((l) => (baseRevenue * pow(revenueMultiplier, l - 1)).roundToDouble()),
        baseSpeedFn = baseSpeedFn ?? ((l) => max(1.0, 5.0 - l * 0.05)),
        queuePoint = queuePoint ?? Offset(gx - 1, gy + 0.5);
}
