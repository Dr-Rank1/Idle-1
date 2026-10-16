import 'dart:math';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import '../models/character.dart';
import '../models/enums.dart';
import '../models/franchise.dart';
import '../models/manager.dart';
import '../models/particles.dart';
import '../models/station.dart';
import '../utils/iso_math.dart';

/// Central game state — all simulation data lives here.
/// Extends ChangeNotifier so the UI rebuilds on every tick.
class GameState extends ChangeNotifier {
  // ─── Economy & Tycoon State (100% Synchronized with Godot GameManager) ──
  double cash = 500.0;
  int gems = 130;
  double totalEarned = 0.0;
  int reputation = 1;          // prestige multiplier level
  int prestigeStars = 0;       // permanent prestige stars earned
  int prestigeLevel = 0;       // franchise prestige level
  int franchiseKeys = 0;       // franchise golden keys earned
  double restaurantValuation = 0.0;
  final List<WorldRestaurant> worldRestaurants = List.from(defaultWorldRestaurants);
  String activeRestaurantId = 'idle_diner';
  double starRating = 5.0;
  String restaurantName = 'Idle Diner';
  String get hotelName => restaurantName;
  set hotelName(String val) => restaurantName = val;
  int restaurantLevel = 1;
  double restaurantXp = 0.0;
  int marketingLevel = 1;
  int unlockedStalls = 2;
  bool terraceUnlocked = true;
  Map<String, bool> unlockedTables = {
    'table_1': true,
    'table_2': true,
    'table_3': true,
    'table_4': true,
    'table_5': true,
    'table_6': true,
    'table_7': true,
    'table_8': true,
    'table_9': true,
    'table_10': true,
    'table_11': true,
    'table_12': true,
  };

  double get prestigeMultiplier => 1.0 + (prestigeLevel * 0.50) + (prestigeStars * 0.25);
  double get totalRevenueMultiplier => revenueMultiplier * prestigeMultiplier;
  double get cashPerSecond =>
      stations.fold(0.0, (sum, s) => sum + (s.actionDuration > 0 ? s.income / s.actionDuration : 0.0)) *
      totalRevenueMultiplier;
  void triggerVipEvent() => _triggerVipEvent();

  double getRestaurantValuation() {
    final earnedPart = totalEarned * 0.75;
    double stationPart = 0.0;
    for (final s in stations) {
      if (s.id.startsWith('table_')) {
        stationPart += s.level * 250.0;
      } else {
        stationPart += s.level * 500.0;
      }
    }
    final starMult = (starRating / 5.0).clamp(0.6, 1.25);
    final val = (earnedPart + stationPart * 1.5) * starMult;
    return max(500.0, val);
  }

  bool get areCoreStationsMaxLevel => stations.every((s) => s.level >= 50);
  bool get canPrestige => getRestaurantValuation() >= 25000.0 || areCoreStationsMaxLevel;
  int get keysToEarnOnPrestige => max(1, (getRestaurantValuation() / 15000.0).floor());
  int get diamondsToEarnOnPrestige => 25 + (keysToEarnOnPrestige * 15);

  int get starsToEarnOnPrestige {
    final potential = (sqrt(totalEarned / 4000.0)).floor();
    return max(1, potential - prestigeStars);
  }

  // ─── Characters ──────────────────────────────────────────────────────────
  final List<Character> characters = [];
  int _nextCharId = 0;

  // ─── Stations ─────────────────────────────────────────────────────────────
  late final List<Station> stations;

  // ─── Managers ─────────────────────────────────────────────────────────────
  final List<Manager> managers = allManagers.map((m) => Manager(
    id: m.id,
    name: m.name,
    emoji: m.emoji,
    rarity: m.rarity,
    affectsZone: m.affectsZone,
    description: m.description,
    incomeBoost: m.incomeBoost,
    speedBoost: m.speedBoost,
    guestBoost: m.guestBoost,
    isUnlocked: m.isUnlocked,
    isAssigned: m.isAssigned,
  )).toList();

  // ─── Particles & Labels ───────────────────────────────────────────────────
  final List<FloatingLabel> floatingLabels = [];
  final List<Particle> particles = [];
  int _nextParticleId = 0;

  // ─── Guest spawn timer ───────────────────────────────────────────────────
  double _guestSpawnTimer = 0.0;
  double get guestSpawnInterval =>
      max(3.0, 8.0 - reputation * 0.5); // faster with more rep

  // ─── Offline income ──────────────────────────────────────────────────────
  int? lastSaveTimestamp;
  double offlineEarnings = 0.0;

  // ─── Camera / viewport ───────────────────────────────────────────────────
  Offset cameraOffset = const Offset(0, 0);
  double cameraZoom = 1.0;
  static const double minZoom = 0.5;
  static const double maxZoom = 2.0;

  // ─── VIP event ────────────────────────────────────────────────────────────
  bool vipActive = false;
  double vipTimer = 0.0;
  double revenueMultiplier = 1.0;

  // ─── Random ───────────────────────────────────────────────────────────────
  final Random _rng = Random();

  // ─── Map grid dimensions ─────────────────────────────────────────────────
  static const int mapW = 18;
  static const int mapH = 18;

  GameState() {
    _buildStations();
    _spawnStaff();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STATION SETUP
  // ═══════════════════════════════════════════════════════════════════════════

  void _buildStations() {
    stations = [
      // ── Reception desks (Zone: reception) ──────────────────────────
      Station(
        id: 'reception_1',
        zone: ZoneType.reception,
        name: 'Reception Desk',
        gx: 4, gy: 3,
        maxLevel: 50,
        baseCostFn: (l) => (100 * pow(1.15, l - 1)).roundToDouble(),
        baseIncomeFn: (l) => (15 * pow(1.10, l - 1)).roundToDouble(),
        baseSpeedFn: (l) => max(1.5, 4.0 - l * 0.05),
        queuePoint: const Offset(2.5, 3.5),
      ),
      Station(
        id: 'reception_2',
        zone: ZoneType.reception,
        name: 'Reception Desk',
        gx: 4, gy: 5,
        maxLevel: 50,
        baseCostFn: (l) => (100 * pow(1.15, l - 1)).roundToDouble(),
        baseIncomeFn: (l) => (15 * pow(1.10, l - 1)).roundToDouble(),
        baseSpeedFn: (l) => max(1.5, 4.0 - l * 0.05),
        queuePoint: const Offset(2.5, 5.5),
      ),

      // ── Kitchen cook / stoves (Base Cost $80, Cost Mult 1.16, Base Rev $15, Rev Mult 1.12, Max 50) ────────────────────
      Station(
        id: 'kitchen_cook',
        zone: ZoneType.kitchen,
        name: 'Master Chef Stove',
        gx: 11, gy: 2,
        maxLevel: 50,
        baseCostFn: (l) => (80 * pow(1.16, l - 1)).roundToDouble(),
        baseIncomeFn: (l) => (15 * pow(1.12, l - 1)).roundToDouble(),
        baseSpeedFn: (l) => max(1.0, 5.0 - l * 0.08),
        queuePoint: const Offset(10.0, 2.5),
      ),
      Station(
        id: 'stove_1',
        zone: ZoneType.kitchen,
        name: 'Master Chef Stove',
        gx: 11, gy: 2,
        maxLevel: 50,
        baseCostFn: (l) => (80 * pow(1.16, l - 1)).roundToDouble(),
        baseIncomeFn: (l) => (15 * pow(1.12, l - 1)).roundToDouble(),
        baseSpeedFn: (l) => max(1.0, 5.0 - l * 0.08),
        queuePoint: const Offset(10.0, 2.5),
      ),
      Station(
        id: 'stove_2',
        zone: ZoneType.kitchen,
        name: 'Master Chef Stove',
        gx: 11, gy: 4,
        maxLevel: 50,
        baseCostFn: (l) => (80 * pow(1.16, l - 1)).roundToDouble(),
        baseIncomeFn: (l) => (15 * pow(1.12, l - 1)).roundToDouble(),
        baseSpeedFn: (l) => max(1.0, 5.0 - l * 0.08),
        queuePoint: const Offset(10.0, 4.5),
      ),

      // ── 50s Milkshake & Soda Bar (Base Cost $250, Cost Mult 1.17, Base Rev $45, Rev Mult 1.12, Max 50) ──
      Station(
        id: 'milkshake_bar',
        zone: ZoneType.milkshakeDiner,
        name: 'Soda Fountain Bar',
        gx: 6, gy: 3,
        maxLevel: 50,
        baseCost: 250.0,
        costMultiplier: 1.17,
        baseRevenue: 45.0,
        revenueMultiplier: 1.12,
        baseCostFn: (l) => (250 * pow(1.17, l - 1)).roundToDouble(),
        baseIncomeFn: (l) => (45 * pow(1.12, l - 1)).roundToDouble(),
        baseSpeedFn: (l) => max(1.2, 4.5 - l * 0.06),
        queuePoint: const Offset(5.0, 3.5),
      ),

      // ── Exterior Parking Lot (Base Cost $180, Cost Mult 1.19, +15% Spawn Rate, Mult 1.08, Max Level 25) ──
      Station(
        id: 'parking_lot',
        zone: ZoneType.parking,
        name: 'Parking Lot',
        gx: 1, gy: 14,
        widthTiles: 3,
        heightTiles: 2,
        maxLevel: 25,
        baseCost: 180.0,
        costMultiplier: 1.19,
        baseRevenue: 25.0,
        revenueMultiplier: 1.08,
        baseCostFn: (l) => (180 * pow(1.19, l - 1)).roundToDouble(),
        baseIncomeFn: (l) => (25 * pow(1.08, l - 1)).roundToDouble(),
        baseSpeedFn: (l) => max(2.0, 6.0 - (l - 1) * 0.15),
        queuePoint: const Offset(1.0, 13.0),
      ),

      // ── Cocktail Lounge Bar (Base Cost $350, Cost Mult 1.18, Base Rev $60, Rev Mult 1.12, Max 50) ──
      Station(
        id: 'cocktail_lounge',
        zone: ZoneType.lounge,
        name: 'Cocktail Lounge Bar',
        gx: 3, gy: 8,
        widthTiles: 2,
        heightTiles: 1,
        maxLevel: 50,
        baseCost: 350.0,
        costMultiplier: 1.18,
        baseRevenue: 60.0,
        revenueMultiplier: 1.12,
        baseCostFn: (l) => (350 * pow(1.18, l - 1)).roundToDouble(),
        baseIncomeFn: (l) => (60 * pow(1.12, l - 1)).roundToDouble(),
        baseSpeedFn: (l) => max(1.5, 4.8 - l * 0.06),
        queuePoint: const Offset(2.5, 8.5),
      ),

      // ── Restroom Hygiene (Base Cost $200, Cost Mult 1.16, Base Rev $20, Rev Mult 1.10, Max 50) ──
      Station(
        id: 'restroom',
        zone: ZoneType.restroom,
        name: 'Restroom Hygiene',
        gx: 1, gy: 6,
        widthTiles: 2,
        heightTiles: 2,
        maxLevel: 50,
        baseCost: 200.0,
        costMultiplier: 1.16,
        baseRevenue: 20.0,
        revenueMultiplier: 1.10,
        baseCostFn: (l) => (200 * pow(1.16, l - 1)).roundToDouble(),
        baseIncomeFn: (l) => (20 * pow(1.10, l - 1)).roundToDouble(),
        baseSpeedFn: (l) => max(2.0, 6.0 - l * 0.08),
        queuePoint: const Offset(2.0, 5.5),
      ),

      // ── Executive Manager's Office (Base Cost $500, Cost Mult 1.20, Base Rev $75, Rev Mult 1.12, Max 50) ──
      Station(
        id: 'manager_office',
        zone: ZoneType.managerOffice,
        name: "Manager's Office",
        gx: 13, gy: 2,
        widthTiles: 2,
        heightTiles: 2,
        maxLevel: 50,
        baseCost: 500.0,
        costMultiplier: 1.20,
        baseRevenue: 75.0,
        revenueMultiplier: 1.12,
        baseCostFn: (l) => (500 * pow(1.20, l - 1)).roundToDouble(),
        baseIncomeFn: (l) => (75 * pow(1.12, l - 1)).roundToDouble(),
        baseSpeedFn: (l) => max(2.5, 7.0 - l * 0.1),
        queuePoint: const Offset(12.5, 2.5),
      ),

      // ── Tables 1–3 (Base Cost $45, Cost Mult 1.15, Base Rev $12, Rev Mult 1.10, Max 50) ──
      Station(
        id: 'table_1',
        zone: ZoneType.diningRoom,
        name: 'Booth Table 1',
        gx: 8, gy: 7,
        maxLevel: 50,
        baseCostFn: (l) => (45 * pow(1.15, l - 1)).roundToDouble(),
        baseIncomeFn: (l) => (12 * pow(1.10, l - 1)).roundToDouble(),
        baseSpeedFn: (l) => max(3.0, 10.0 - l * 0.1),
        queuePoint: const Offset(7.0, 7.5),
      ),
      Station(
        id: 'table_2',
        zone: ZoneType.diningRoom,
        name: 'Booth Table 2',
        gx: 10, gy: 7,
        maxLevel: 50,
        baseCostFn: (l) => (45 * pow(1.15, l - 1)).roundToDouble(),
        baseIncomeFn: (l) => (12 * pow(1.10, l - 1)).roundToDouble(),
        baseSpeedFn: (l) => max(3.0, 10.0 - l * 0.1),
        queuePoint: const Offset(9.0, 7.5),
      ),
      Station(
        id: 'table_3',
        zone: ZoneType.diningRoom,
        name: 'Booth Table 3',
        gx: 12, gy: 7,
        maxLevel: 50,
        baseCostFn: (l) => (45 * pow(1.15, l - 1)).roundToDouble(),
        baseIncomeFn: (l) => (12 * pow(1.10, l - 1)).roundToDouble(),
        baseSpeedFn: (l) => max(3.0, 10.0 - l * 0.1),
        queuePoint: const Offset(11.0, 7.5),
      ),

      // ── Tables 4–6 (Base Cost $120, Cost Mult 1.16, Base Rev $28, Rev Mult 1.11, Max 50) ──
      Station(
        id: 'table_4',
        zone: ZoneType.diningRoom,
        name: 'Booth Table 4',
        gx: 8, gy: 9,
        maxLevel: 50,
        baseCostFn: (l) => (120 * pow(1.16, l - 1)).roundToDouble(),
        baseIncomeFn: (l) => (28 * pow(1.11, l - 1)).roundToDouble(),
        baseSpeedFn: (l) => max(3.0, 10.0 - l * 0.1),
        queuePoint: const Offset(7.0, 9.5),
      ),
      Station(
        id: 'table_5',
        zone: ZoneType.diningRoom,
        name: 'Booth Table 5',
        gx: 10, gy: 9,
        maxLevel: 50,
        baseCostFn: (l) => (120 * pow(1.16, l - 1)).roundToDouble(),
        baseIncomeFn: (l) => (28 * pow(1.11, l - 1)).roundToDouble(),
        baseSpeedFn: (l) => max(3.0, 10.0 - l * 0.1),
        queuePoint: const Offset(9.0, 9.5),
      ),
      Station(
        id: 'table_6',
        zone: ZoneType.diningRoom,
        name: 'Booth Table 6',
        gx: 12, gy: 9,
        maxLevel: 50,
        baseCostFn: (l) => (120 * pow(1.16, l - 1)).roundToDouble(),
        baseIncomeFn: (l) => (28 * pow(1.11, l - 1)).roundToDouble(),
        baseSpeedFn: (l) => max(3.0, 10.0 - l * 0.1),
        queuePoint: const Offset(11.0, 9.5),
      ),

      // ── Tables 7–9 (Base Cost $320, Cost Mult 1.18, Base Rev $65, Rev Mult 1.12, Max 50) ──
      Station(
        id: 'table_7',
        zone: ZoneType.diningRoom,
        name: 'Booth Table 7',
        gx: 8, gy: 11,
        maxLevel: 50,
        baseCostFn: (l) => (320 * pow(1.18, l - 1)).roundToDouble(),
        baseIncomeFn: (l) => (65 * pow(1.12, l - 1)).roundToDouble(),
        baseSpeedFn: (l) => max(3.0, 10.0 - l * 0.1),
        queuePoint: const Offset(7.0, 11.5),
      ),
      Station(
        id: 'table_8',
        zone: ZoneType.diningRoom,
        name: 'Booth Table 8',
        gx: 10, gy: 11,
        maxLevel: 50,
        baseCostFn: (l) => (320 * pow(1.18, l - 1)).roundToDouble(),
        baseIncomeFn: (l) => (65 * pow(1.12, l - 1)).roundToDouble(),
        baseSpeedFn: (l) => max(3.0, 10.0 - l * 0.1),
        queuePoint: const Offset(9.0, 11.5),
      ),
      Station(
        id: 'table_9',
        zone: ZoneType.diningRoom,
        name: 'Booth Table 9',
        gx: 12, gy: 11,
        maxLevel: 50,
        baseCostFn: (l) => (320 * pow(1.18, l - 1)).roundToDouble(),
        baseIncomeFn: (l) => (65 * pow(1.12, l - 1)).roundToDouble(),
        baseSpeedFn: (l) => max(3.0, 10.0 - l * 0.1),
        queuePoint: const Offset(11.0, 11.5),
      ),

      // ── Tables 10–12 Sunset Terrace (Base Cost $650, Cost Mult 1.20, Base Rev $140, Rev Mult 1.13, Max 50) ──
      Station(
        id: 'table_10',
        zone: ZoneType.diningRoom,
        name: 'Terrace Cabana 10',
        gx: 14, gy: 7,
        maxLevel: 50,
        baseCostFn: (l) => (650 * pow(1.20, l - 1)).roundToDouble(),
        baseIncomeFn: (l) => (140 * pow(1.13, l - 1)).roundToDouble(),
        baseSpeedFn: (l) => max(3.0, 10.0 - l * 0.1),
        queuePoint: const Offset(13.0, 7.5),
      ),
      Station(
        id: 'table_11',
        zone: ZoneType.diningRoom,
        name: 'Terrace Cabana 11',
        gx: 14, gy: 9,
        maxLevel: 50,
        baseCostFn: (l) => (650 * pow(1.20, l - 1)).roundToDouble(),
        baseIncomeFn: (l) => (140 * pow(1.13, l - 1)).roundToDouble(),
        baseSpeedFn: (l) => max(3.0, 10.0 - l * 0.1),
        queuePoint: const Offset(13.0, 9.5),
      ),
      Station(
        id: 'table_12',
        zone: ZoneType.diningRoom,
        name: 'Terrace Cabana 12',
        gx: 14, gy: 11,
        maxLevel: 50,
        baseCostFn: (l) => (650 * pow(1.20, l - 1)).roundToDouble(),
        baseIncomeFn: (l) => (140 * pow(1.13, l - 1)).roundToDouble(),
        baseSpeedFn: (l) => max(3.0, 10.0 - l * 0.1),
        queuePoint: const Offset(13.0, 11.5),
      ),

      // ── Hotel rooms ───────────────────────────────────────────────────────
      Station(
        id: 'room_1',
        zone: ZoneType.hotelRoom,
        name: 'Standard Room',
        gx: 2, gy: 10,
        widthTiles: 2,
        maxLevel: 50,
        baseCostFn: (l) => (500 * pow(1.18, l - 1)).roundToDouble(),
        baseIncomeFn: (l) => (120 * pow(1.12, l - 1)).roundToDouble(),
        baseSpeedFn: (l) => max(5.0, 15.0 - l * 0.25),
        queuePoint: const Offset(3.0, 9.0),
      ),
      Station(
        id: 'room_2',
        zone: ZoneType.hotelRoom,
        name: 'Standard Room',
        gx: 5, gy: 10,
        widthTiles: 2,
        maxLevel: 50,
        baseCostFn: (l) => (600 * pow(1.18, l - 1)).roundToDouble(),
        baseIncomeFn: (l) => (130 * pow(1.12, l - 1)).roundToDouble(),
        baseSpeedFn: (l) => max(5.0, 15.0 - l * 0.25),
        queuePoint: const Offset(6.0, 9.0),
      ),
      Station(
        id: 'room_3',
        zone: ZoneType.hotelRoom,
        name: 'Deluxe Suite',
        gx: 8, gy: 12,
        widthTiles: 2,
        maxLevel: 50,
        baseCostFn: (l) => (1200 * pow(1.20, l - 1)).roundToDouble(),
        baseIncomeFn: (l) => (250 * pow(1.13, l - 1)).roundToDouble(),
        baseSpeedFn: (l) => max(5.0, 18.0 - l * 0.3),
        queuePoint: const Offset(9.0, 11.0),
      ),
    ];
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STAFF SPAWNING
  // ═══════════════════════════════════════════════════════════════════════════

  void _spawnStaff() {
    // Receptionists
    _addCharacter(CharacterType.receptionist, gx: 4.5, gy: 3.5,
        state: CharacterState.idle);
    _addCharacter(CharacterType.receptionist, gx: 4.5, gy: 5.5,
        state: CharacterState.idle);

    // Chefs
    _addCharacter(CharacterType.chef, gx: 11.5, gy: 2.5,
        state: CharacterState.idle);
    _addCharacter(CharacterType.chef, gx: 11.5, gy: 4.5,
        state: CharacterState.idle);

    // Waiters
    _addCharacter(CharacterType.waiter, gx: 9.0, gy: 6.0,
        state: CharacterState.idle);
    _addCharacter(CharacterType.waiter, gx: 10.5, gy: 6.0,
        state: CharacterState.idle);

    // Maids
    _addCharacter(CharacterType.maid, gx: 3.0, gy: 11.0,
        state: CharacterState.idle);
  }

  Character _addCharacter(CharacterType type, {
    required double gx,
    required double gy,
    CharacterState state = CharacterState.arriving,
    bool isVip = false,
  }) {
    final c = Character(
      id: 'char_${_nextCharId++}',
      type: type,
      gx: gx,
      gy: gy,
      state: state,
      patience: type == CharacterType.guest ? (20 + _rng.nextDouble() * 20) : 999,
    );
    c.isVip = isVip;
    characters.add(c);
    return c;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MAIN TICK — called every frame from the game loop
  // ═══════════════════════════════════════════════════════════════════════════

  void tick(double dt) {
    _tickGuestSpawn(dt);
    _tickCharacters(dt);
    _tickStations(dt);
    _tickParticles(dt);
    _tickVip(dt);
    notifyListeners();
  }

  // ─── Guest spawning ──────────────────────────────────────────────────────
  void _tickGuestSpawn(double dt) {
    _guestSpawnTimer -= dt;
    if (_guestSpawnTimer <= 0) {
      _guestSpawnTimer = guestSpawnInterval;
      _spawnGuest();
    }
  }

  void _spawnGuest() {
    // Cap at 12 simultaneous guests
    final guestCount = characters.where((c) => c.isGuest).length;
    if (guestCount >= 12) return;

    final isVip = _rng.nextDouble() < 0.08; // 8% VIP chance
    final g = _addCharacter(
      CharacterType.guest,
      gx: 0.5,
      gy: 2.0 + _rng.nextDouble() * 0.5,
      state: CharacterState.arriving,
      isVip: isVip,
    );
    g.patience = isVip ? 40.0 : (15 + _rng.nextDouble() * 20);

    // Route to reception first
    final freeReception = _findFreeStation(ZoneType.reception);
    if (freeReception != null) {
      _routeGuestToReception(g, freeReception);
    } else {
      // No free reception — just send them to dining directly (impatient!)
      final freeTable = _findFreeStation(ZoneType.diningRoom);
      if (freeTable != null) {
        _routeGuestToDining(g, freeTable);
      } else {
        // Resort full — guest leaves
        g.state = CharacterState.leaving;
        _walkTo(g, -1.5, g.gy);
      }
    }
  }

  // ─── Routing helpers ─────────────────────────────────────────────────────
  void _setWaypointsAndWalk(Character c, List<Offset> points) {
    if (points.isEmpty) return;
    c.waypoints.clear();
    final first = points.first;
    _walkTo(c, first.dx, first.dy);
    if (points.length > 1) {
      c.waypoints.addAll(points.sublist(1));
    }
  }

  void _routeGuestToReception(Character g, Station s) {
    g.state = CharacterState.walkingToReception;
    g.assignedStationId = s.id;
    s.occupiedByCharacterId = g.id;
    _setWaypointsAndWalk(g, [
      const Offset(2.0, 2.5),
      s.queuePoint,
    ]);
  }

  void _routeGuestToDining(Character g, Station s) {
    g.state = CharacterState.walkingToDining;
    g.assignedStationId = s.id;
    s.occupiedByCharacterId = g.id;
    _setWaypointsAndWalk(g, [
      const Offset(5.5, 4.5),
      Offset(s.centerGrid.dx, 5.5),
      s.centerGrid,
    ]);
  }

  void _routeGuestToRoom(Character g, Station s) {
    g.state = CharacterState.walkingToRoom;
    g.assignedStationId = s.id;
    s.occupiedByCharacterId = g.id;
    _setWaypointsAndWalk(g, [
      const Offset(3.5, 6.5),
      Offset(s.centerGrid.dx, 8.5),
      s.centerGrid,
    ]);
  }

  void _walkTo(Character c, double tx, double ty) {
    c.targetGx = tx;
    c.targetGy = ty;
    // Update facing direction
    final dx = tx - c.gx;
    final dy = ty - c.gy;
    if (dx >= 0 && dy >= 0) {
      c.facing = FacingDirection.southEast;
    } else if (dx < 0 && dy >= 0) {
      c.facing = FacingDirection.southWest;
    } else if (dx >= 0 && dy < 0) {
      c.facing = FacingDirection.northEast;
    } else {
      c.facing = FacingDirection.northWest;
    }
  }

  Station? _findFreeStation(ZoneType zone) {
    final candidates =
        stations.where((s) => s.zone == zone && !s.isOccupied).toList();
    if (candidates.isEmpty) return null;
    candidates.sort((a, b) => a.level.compareTo(b.level));
    return candidates.last; // prefer higher-level stations
  }

  // ─── Character tick ───────────────────────────────────────────────────────
  void _tickCharacters(double dt) {
    final toRemove = <Character>[];

    for (final c in characters) {
      // Move towards target
      if (c.isMoving) {
        const speed = 2.0; // tiles per second
        final dx = c.targetGx - c.gx;
        final dy = c.targetGy - c.gy;
        final dist = sqrt(dx * dx + dy * dy);
        final step = speed * dt;
        if (dist <= step) {
          c.gx = c.targetGx;
          c.gy = c.targetGy;
        } else {
          c.gx += (dx / dist) * step;
          c.gy += (dy / dist) * step;
        }
        c.walkCycle += dt * 8.0;
      }

      // State machine
      switch (c.state) {
        case CharacterState.arriving:
        case CharacterState.walkingToReception:
        case CharacterState.walkingToDining:
        case CharacterState.walkingToRoom:
          if (!c.isMoving) {
            if (c.waypoints.isNotEmpty) {
              final next = c.waypoints.removeAt(0);
              _walkTo(c, next.dx, next.dy);
            } else {
              _onArrived(c);
            }
          } else {
            // Patience drain while walking
            if (c.isGuest) {
              c.patience -= dt * 0.5;
              if (c.patience <= 0) {
                _guestLeaves(c);
              }
            }
          }
          break;

        case CharacterState.checkingIn:
          c.stateTimer -= dt;
          // Find station and update progress
          final sId = c.assignedStationId;
          if (sId != null) {
            final s = _stationById(sId);
            if (s != null) {
              s.progressFraction = 1.0 - (c.stateTimer / s.actionDuration);
            }
          }
          if (c.stateTimer <= 0) {
            _checkInComplete(c);
          }
          break;

        case CharacterState.seated:
        case CharacterState.eating:
          c.stateTimer -= dt;
          if (c.stateTimer <= 0) {
            _mealComplete(c);
          }
          break;

        case CharacterState.inRoom:
          c.stateTimer -= dt;
          if (c.stateTimer <= 0) {
            _checkoutComplete(c);
          }
          break;

        case CharacterState.leaving:
          if (!c.isMoving) {
            if (c.waypoints.isNotEmpty) {
              final next = c.waypoints.removeAt(0);
              _walkTo(c, next.dx, next.dy);
            } else if (c.isGuest) {
              toRemove.add(c);
            }
          }
          break;

        case CharacterState.idle:
          if (c.isStaff) {
            _tickStaffIdle(c, dt);
          }
          break;

        case CharacterState.cooking:
          c.stateTimer -= dt;
          if (c.stateTimer <= 0) {
            _cookingDone(c);
          }
          break;

        case CharacterState.walkingToKitchen:
          if (!c.isMoving) {
            _startCooking(c);
          }
          break;

        case CharacterState.carryingFood:
          if (!c.isMoving) {
            _serveFood(c);
          }
          break;

        case CharacterState.serving:
          c.stateTimer -= dt;
          if (c.stateTimer <= 0) {
            c.state = CharacterState.idle;
          }
          break;

        case CharacterState.cleaning:
          c.stateTimer -= dt;
          if (c.stateTimer <= 0) {
            _cleaningDone(c);
          }
          break;

        case CharacterState.walkingToTable:
          if (!c.isMoving) {
            c.state = CharacterState.carryingFood;
          }
          break;

        default:
          break;
      }
    }

    for (final c in toRemove) {
      characters.remove(c);
    }
  }

  // ─── On-arrival state transitions ────────────────────────────────────────
  void _onArrived(Character c) {
    switch (c.state) {
      case CharacterState.arriving:
      case CharacterState.walkingToReception:
        c.state = CharacterState.checkingIn;
        final s = c.assignedStationId != null
            ? _stationById(c.assignedStationId!)
            : null;
        c.stateTimer = s?.actionDuration ?? 4.0;
        break;

      case CharacterState.walkingToDining:
        c.state = CharacterState.seated;
        c.stateTimer = 2.0; // wait for waiter
        // Notify a waiter
        _alertWaiterForTable(c.assignedStationId);
        break;

      case CharacterState.walkingToRoom:
        c.state = CharacterState.inRoom;
        final s = c.assignedStationId != null
            ? _stationById(c.assignedStationId!)
            : null;
        c.stateTimer = s?.actionDuration ?? 15.0;
        break;

      default:
        break;
    }
  }

  void _checkInComplete(Character c) {
    final s = c.assignedStationId != null
        ? _stationById(c.assignedStationId!)
        : null;
    if (s != null) {
      s.progressFraction = 0.0;
      s.occupiedByCharacterId = null;
    }
    c.assignedStationId = null;

    final checkInIncome = (s?.income ?? 25.0) * totalRevenueMultiplier * (c.isVip ? 2.0 : 1.0);
    _earnCash(checkInIncome, c.gx, c.gy);

    // After check-in: 50% go eat, 50% go to room
    if (_rng.nextBool()) {
      final table = _findFreeStation(ZoneType.diningRoom);
      if (table != null) {
        _routeGuestToDining(c, table);
        return;
      }
    }
    final room = _findFreeStation(ZoneType.hotelRoom);
    if (room != null) {
      _routeGuestToRoom(c, room);
    } else {
      _guestLeaves(c);
    }
  }

  void _mealComplete(Character c) {
    final s = c.assignedStationId != null
        ? _stationById(c.assignedStationId!)
        : null;
    if (s != null) s.occupiedByCharacterId = null;
    c.assignedStationId = null;

    // Collect meal payment
    final mealIncome = (s?.income ?? 60.0) * totalRevenueMultiplier * (c.isVip ? 1.5 : 1.0);
    _earnCash(mealIncome, c.gx, c.gy);

    // After dining: go rest or leave
    final room = _findFreeStation(ZoneType.hotelRoom);
    if (room != null && _rng.nextDouble() < 0.6) {
      _routeGuestToRoom(c, room);
    } else {
      _guestLeaves(c);
    }
  }

  void _checkoutComplete(Character c) {
    final s = c.assignedStationId != null
        ? _stationById(c.assignedStationId!)
        : null;
    if (s != null) {
      s.isDirty = true;
      s.occupiedByCharacterId = null;
      // Alert maid
      _alertMaidForRoom(s.id);
    }
    c.assignedStationId = null;

    final roomIncome = (s?.income ?? 120.0) * totalRevenueMultiplier * (c.isVip ? 2.0 : 1.0);
    _earnCash(roomIncome, c.gx, c.gy);

    _guestLeaves(c);
  }

  void _guestLeaves(Character c) {
    // Free any occupied station
    if (c.assignedStationId != null) {
      final s = _stationById(c.assignedStationId!);
      if (s?.occupiedByCharacterId == c.id) {
        s?.occupiedByCharacterId = null;
      }
      c.assignedStationId = null;
    }
    c.state = CharacterState.leaving;
    _setWaypointsAndWalk(c, [
      const Offset(3.5, 4.5),
      const Offset(1.0, 2.5),
      const Offset(-2.0, 2.5),
    ]);
  }

  // ─── Staff idle AI ────────────────────────────────────────────────────────
  void _tickStaffIdle(Character c, double dt) {
    switch (c.type) {
      case CharacterType.chef:
        // Find a stove that needs cooking
        final stove = stations.where((s) =>
            s.zone == ZoneType.kitchen && !s.foodReady &&
            s.occupiedByCharacterId == null).firstOrNull;
        if (stove != null) {
          stove.occupiedByCharacterId = c.id;
          c.assignedStationId = stove.id;
          c.state = CharacterState.walkingToKitchen;
          _walkTo(c, stove.centerGrid.dx, stove.centerGrid.dy);
        }
        break;

      case CharacterType.maid:
        // Find a dirty room
        final dirtyRoom = stations.where(
            (s) => s.zone == ZoneType.hotelRoom && s.isDirty).firstOrNull;
        if (dirtyRoom != null) {
          dirtyRoom.occupiedByCharacterId = c.id;
          c.assignedStationId = dirtyRoom.id;
          c.state = CharacterState.cleaning;
          final s = dirtyRoom;
          c.stateTimer = s.actionDuration * 0.5;
          _walkTo(c, s.centerGrid.dx, s.centerGrid.dy);
        }
        break;

      default:
        break;
    }
  }

  void _alertWaiterForTable(String? tableId) {
    if (tableId == null) return;
    final waiter = characters.where(
        (c) => c.type == CharacterType.waiter && c.state == CharacterState.idle
    ).firstOrNull;
    if (waiter == null) return;

    // Send waiter to kitchen first
    final freeStove = stations.where(
        (s) => s.zone == ZoneType.kitchen && s.foodReady).firstOrNull
      ?? stations.where(
        (s) => s.zone == ZoneType.kitchen).firstOrNull;

    if (freeStove == null) return;
    waiter.assignedStationId = tableId; // remember where to deliver
    waiter.state = CharacterState.walkingToKitchen;
    _walkTo(waiter, freeStove.centerGrid.dx, freeStove.centerGrid.dy);
  }

  void _alertMaidForRoom(String roomId) {
    final maid = characters.where(
        (c) => c.type == CharacterType.maid && c.state == CharacterState.idle
    ).firstOrNull;
    if (maid == null) return;

    final room = _stationById(roomId);
    if (room == null) return;

    room.occupiedByCharacterId = maid.id;
    maid.assignedStationId = roomId;
    maid.state = CharacterState.cleaning;
    maid.stateTimer = room.actionDuration * 0.5;
    _walkTo(maid, room.centerGrid.dx, room.centerGrid.dy);
  }

  void _startCooking(Character c) {
    final stoveId = c.type == CharacterType.chef
        ? c.assignedStationId
        // waiter walking to kitchen to pick up food
        : null;

    if (c.type == CharacterType.chef) {
      final stove = stoveId != null ? _stationById(stoveId) : null;
      if (stove == null) {
        c.state = CharacterState.idle;
        return;
      }
      c.state = CharacterState.cooking;
      c.stateTimer = stove.actionDuration;
    } else {
      // Waiter picking up food from kitchen to deliver
      c.state = CharacterState.carryingFood;
    }
  }

  void _cookingDone(Character c) {
    final stove = c.assignedStationId != null
        ? _stationById(c.assignedStationId!)
        : null;
    if (stove != null) {
      stove.foodReady = true;
      stove.occupiedByCharacterId = null;
    }
    c.assignedStationId = null;
    c.state = CharacterState.idle;
    _spawnSteamParticle(stove?.centerGrid ?? Offset(c.gx, c.gy));
  }

  void _serveFood(Character c) {
    // Waiter delivers to table
    final tableId = c.assignedStationId;
    final table = tableId != null ? _stationById(tableId) : null;

    if (table == null) {
      c.state = CharacterState.idle;
      return;
    }

    // Mark stove food as consumed
    final stove = stations.where(
        (s) => s.zone == ZoneType.kitchen && s.foodReady).firstOrNull;
    if (stove != null) stove.foodReady = false;

    // Find the seated guest
    final guest = characters.where((ch) =>
        ch.isGuest &&
        ch.assignedStationId == tableId &&
        (ch.state == CharacterState.seated || ch.state == CharacterState.eating)
    ).firstOrNull;

    if (guest != null) {
      guest.state = CharacterState.eating;
      guest.stateTimer = table.actionDuration;
    }

    c.state = CharacterState.serving;
    c.stateTimer = 1.0;
    c.assignedStationId = null;
  }

  void _cleaningDone(Character c) {
    final room = c.assignedStationId != null
        ? _stationById(c.assignedStationId!)
        : null;
    if (room != null) {
      room.isDirty = false;
      room.occupiedByCharacterId = null;
    }
    c.assignedStationId = null;
    c.state = CharacterState.idle;
  }

  // ─── Stations tick ────────────────────────────────────────────────────────
  void _tickStations(double dt) {
    for (final s in stations) {
      // Stove auto-cook if no chef assigned & food not ready
      if (s.zone == ZoneType.kitchen && !s.foodReady &&
          s.occupiedByCharacterId == null) {
        s.cookTimer += dt;
        s.progressFraction = (s.cookTimer / s.actionDuration).clamp(0, 1);
        if (s.cookTimer >= s.actionDuration) {
          s.foodReady = true;
          s.cookTimer = 0;
          s.progressFraction = 1.0;
          _spawnSteamParticle(s.centerGrid);
        }
      }
    }
  }

  // ─── Particles ────────────────────────────────────────────────────────────
  void _tickParticles(double dt) {
    floatingLabels.removeWhere((l) => l.life <= 0);
    for (final l in floatingLabels) {
      l.life -= dt * 0.7;
      l.opacity = l.life;
      l.screenPos = l.screenPos.translate(0, -30 * dt);
    }

    particles.removeWhere((p) => p.life <= 0);
    for (final p in particles) {
      p.life -= dt * 1.5;
      p.pos = p.pos + p.velocity * dt;
      p.velocity = p.velocity.scale(0.95, 0.95);
    }
  }

  void _tickVip(double dt) {
    if (vipActive) {
      vipTimer -= dt;
      if (vipTimer <= 0) {
        vipActive = false;
        revenueMultiplier = 1.0;
      }
    } else {
      // Chance of VIP event every 90 seconds
      if (_rng.nextDouble() < dt / 90.0) {
        _triggerVipEvent();
      }
    }
  }

  void _triggerVipEvent() {
    vipActive = true;
    vipTimer = 30.0;
    revenueMultiplier = 3.0;
  }

  // ─── Cash & particles ─────────────────────────────────────────────────────
  void _earnCash(double amount, double gx, double gy) {
    cash += amount;
    totalEarned += amount;

    final screenPos = _gridToViewport(gx, gy);
    floatingLabels.add(FloatingLabel(
      id: 'lbl_${_nextParticleId++}',
      text: '+\$${amount.toStringAsFixed(0)}',
      screenPos: screenPos,
      color: const Color(0xFF4CAF50),
    ));

    // Spawn confetti particles
    _spawnCashParticles(screenPos);
  }

  void _spawnCashParticles(Offset pos) {
    for (int i = 0; i < 5; i++) {
      particles.add(Particle(
        id: 'p_${_nextParticleId++}',
        pos: pos,
        velocity: Offset(
          (_rng.nextDouble() - 0.5) * 60,
          -30 - _rng.nextDouble() * 50,
        ),
        color: [
          const Color(0xFF4CAF50),
          const Color(0xFFFFC107),
          const Color(0xFF8BC34A),
        ][_rng.nextInt(3)],
        size: 4 + _rng.nextDouble() * 4,
      ));
    }
  }

  void _spawnSteamParticle(Offset gridPos) {
    final pos = _gridToViewport(gridPos.dx, gridPos.dy);
    for (int i = 0; i < 3; i++) {
      particles.add(Particle(
        id: 'steam_${_nextParticleId++}',
        pos: pos,
        velocity: Offset(
          (_rng.nextDouble() - 0.5) * 20,
          -20 - _rng.nextDouble() * 30,
        ),
        color: const Color(0xAAFFFFFF),
        size: 6 + _rng.nextDouble() * 6,
      ));
    }
  }

  void spawnTapParticle(Offset screenPos) {
    particles.add(Particle(
      id: 'tap_${_nextParticleId++}',
      pos: screenPos,
      velocity: const Offset(0, -25),
      color: const Color(0xFF81D4FA),
      size: 5,
      life: 0.6,
    ));
    notifyListeners();
  }

  // ─── Camera transform ─────────────────────────────────────────────────────
  Offset _gridToViewport(double gx, double gy) {
    final iso = IsoMath.gridToScreen(gx, gy);
    return iso.scale(cameraZoom, cameraZoom) + cameraOffset;
  }

  // ─── Station lookup ───────────────────────────────────────────────────────
  Station? _stationById(String id) {
    try {
      return stations.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PUBLIC ACTIONS (called from UI)
  // ═══════════════════════════════════════════════════════════════════════════

  bool upgradeStation(String stationId) {
    return upgradeStationBulk(stationId, 1);
  }

  bool upgradeStationBulk(String stationId, int levelsToBuy) {
    final s = _stationById(stationId);
    if (s == null || levelsToBuy <= 0) return false;
    int bought = 0;
    while (bought < levelsToBuy && s.level < s.maxLevel && cash >= s.upgradeCost) {
      cash -= s.upgradeCost;
      s.level++;
      bought++;
    }
    if (bought > 0) {
      final pos = _gridToViewport(s.gx, s.gy);
      _spawnCashParticles(pos);
      _spawnCashParticles(pos.translate(20, -20));
      notifyListeners();
      return true;
    }
    return false;
  }

  Map<String, dynamic> getSectorBottleneckStatus() {
    final lobbyQueue = characters.where((c) => c.isGuest && (c.state == CharacterState.queuingAtReception || c.state == CharacterState.arriving)).length;
    if (lobbyQueue >= 3) {
      return {
        'text': 'Lobby Queue Full',
        'color': const Color(0xFFEF4444),
        'code': 'LOBBY_FULL',
        'icon': '🔴',
      };
    }

    final foodWaiting = stations.where((s) => s.zone == ZoneType.kitchen && s.foodReady).length;
    final queueDining = characters.where((c) => c.isGuest && c.state == CharacterState.queuingAtTable).length;
    if (foodWaiting >= 2 || queueDining >= 3) {
      return {
        'text': 'Kitchen Backlogged',
        'color': const Color(0xFFEF4444),
        'code': 'KITCHEN_BACKLOGGED',
        'icon': '🔴',
      };
    }

    final waiters = characters.where((c) => c.type == CharacterType.waiter).toList();
    final busyWaiters = waiters.where((w) => w.state != CharacterState.idle).length;
    final pendingTables = stations.where((s) => s.isDirty || s.foodReady).length;
    if (waiters.isNotEmpty && busyWaiters == waiters.length && pendingTables > 0) {
      return {
        'text': 'Waiters Busy',
        'color': const Color(0xFFF59E0B),
        'code': 'WAITERS_BUSY',
        'icon': '🟡',
      };
    }

    return {
      'text': 'Optimal Flow',
      'color': const Color(0xFF22C55E),
      'code': 'OPTIMAL',
      'icon': '🟢',
    };
  }

  double claimOfflineEarnings([double multiplier = 1.0]) {
    final payout = offlineEarnings * multiplier;
    cash += payout;
    totalEarned += payout;
    offlineEarnings = 0.0;
    notifyListeners();
    return payout;
  }

  void setAllStationsMaxLevel([bool enable = true]) {
    for (final s in stations) {
      s.level = enable ? s.maxLevel : 1;
    }
    notifyListeners();
  }

  bool assignManager(String managerId) {
    final m = managers.firstWhere((m) => m.id == managerId,
        orElse: () => managers.first);
    if (!m.isUnlocked || m.isAssigned) return false;

    for (final other in managers.where((other) => other.affectsZone == m.affectsZone)) {
      other.isAssigned = false;
    }

    m.isAssigned = true;
    _applyManagerBoosts();
    notifyListeners();
    return true;
  }

  void _applyManagerBoosts() {
    // Reset all multipliers
    for (final s in stations) {
      s.incomeMultiplier = 1.0;
      s.speedMultiplier = 1.0;
    }

    // Apply each assigned manager
    for (final m in managers.where((m) => m.isAssigned)) {
      for (final s in stations.where((s) => s.zone == m.affectsZone)) {
        s.incomeMultiplier *= m.incomeBoost;
        s.speedMultiplier *= m.speedBoost;
      }
    }
  }

  /// Unlock a manager by spending cash (gacha pull, price scales with rarity).
  bool recruitManager(String managerId) {
    final m = managers.firstWhere((m) => m.id == managerId,
        orElse: () => managers.first);
    if (m.isUnlocked) return false;
    final cost = _managerCost(m.rarity);
    if (cash < cost) return false;

    cash -= cost;
    m.isUnlocked = true;
    notifyListeners();
    return true;
  }

  double _managerCost(ManagerRarity r) {
    switch (r) {
      case ManagerRarity.common:
        return 500;
      case ManagerRarity.rare:
        return 2000;
      case ManagerRarity.epic:
        return 8000;
      case ManagerRarity.legendary:
        return 25000;
    }
  }

  double get managerRecruitCost => _managerCost(ManagerRarity.common);

  // ─── Camera controls ─────────────────────────────────────────────────────
  void panCamera(Offset delta) {
    cameraOffset += delta;
    notifyListeners();
  }

  void zoomCamera(double factor, Offset focalPoint) {
    final newZoom = (cameraZoom * factor).clamp(minZoom, maxZoom);
    // Zoom towards focal point
    cameraOffset = focalPoint - (focalPoint - cameraOffset) * (newZoom / cameraZoom);
    cameraZoom = newZoom;
    notifyListeners();
  }

  void setZoom(double newZoom, Offset focalPoint) {
    final clamped = newZoom.clamp(minZoom, maxZoom);
    cameraOffset = focalPoint - (focalPoint - cameraOffset) * (clamped / cameraZoom);
    cameraZoom = clamped;
    notifyListeners();
  }

  void resetCamera() {
    cameraOffset = const Offset(400, 200);
    cameraZoom = 1.0;
    notifyListeners();
  }

  /// Prestige / Franchise Reset:
  /// Resets cash and stations in exchange for permanent franchise keys, diamonds and +50% profit
  bool prestigeReset() {
    if (!canPrestige) return false;
    final newKeys = keysToEarnOnPrestige;
    final newDiamonds = diamondsToEarnOnPrestige;
    prestigeLevel += 1;
    franchiseKeys += newKeys;
    gems += newDiamonds;
    reputation += 1;

    // Reset station levels
    for (final s in stations) {
      s.level = 1;
      s.isDirty = false;
      s.foodReady = false;
      s.cookTimer = 0;
      s.cleanTimer = 0;
      s.progressFraction = 0;
      s.occupiedByCharacterId = null;
    }

    // Starting cash bonus based on prestige level
    cash = 500.0 * (1.0 + prestigeLevel);

    // Remove existing guests so resort starts fresh
    characters.removeWhere((c) => c.isGuest);

    // Spawn massive celebratory gold burst
    final center = _gridToViewport(mapW / 2.0, mapH / 2.0);
    for (int i = 0; i < 20; i++) {
      _spawnCashParticles(center);
    }
    floatingLabels.add(FloatingLabel(
      id: 'lbl_${_nextParticleId++}',
      text: '👑 PRESTIGE UP! +$newKeys 🔑 (+50% PROFIT) 👑',
      screenPos: center.translate(0, -50),
      color: const Color(0xFFFFD700),
      scale: 1.3,
    ));

    notifyListeners();
    return true;
  }

  /// Active Rush Action when player taps on a station or guest
  bool rushActionAt(Offset gridPos) {
    // 1. Check if tapped near a cooking stove
    final stove = stations.where((s) => s.zone == ZoneType.kitchen &&
        (s.centerGrid - gridPos).distance <= 2.0).firstOrNull;
    if (stove != null && !stove.foodReady) {
      stove.cookTimer += 2.0; // speed up cooking by 2 seconds
      final pos = _gridToViewport(stove.centerGrid.dx, stove.centerGrid.dy);
      _spawnSteamParticle(stove.centerGrid);
      floatingLabels.add(FloatingLabel(
        id: 'lbl_${_nextParticleId++}',
        text: '⚡ CHEF RUSH!',
        screenPos: pos,
        color: const Color(0xFFFF9800),
      ));
      notifyListeners();
      return true;
    }

    // 2. Check if tapped near a dirty hotel room
    final dirtyRoom = stations.where((s) => s.zone == ZoneType.hotelRoom && s.isDirty &&
        (s.centerGrid - gridPos).distance <= 2.5).firstOrNull;
    if (dirtyRoom != null) {
      final maid = characters.where((c) => c.type == CharacterType.maid &&
          c.assignedStationId == dirtyRoom.id).firstOrNull;
      if (maid != null) {
        maid.stateTimer = max(0.0, maid.stateTimer - 2.5);
      } else {
        dirtyRoom.cleanTimer += 3.0;
        if (dirtyRoom.cleanTimer >= dirtyRoom.actionDuration * 0.5) {
          dirtyRoom.isDirty = false;
        }
      }
      final pos = _gridToViewport(dirtyRoom.centerGrid.dx, dirtyRoom.centerGrid.dy);
      _spawnCashParticles(pos);
      floatingLabels.add(FloatingLabel(
        id: 'lbl_${_nextParticleId++}',
        text: '✨ QUICK CLEAN!',
        screenPos: pos,
        color: const Color(0xFF00E5FF),
      ));
      notifyListeners();
      return true;
    }

    // 3. Check if tapped near a seated guest
    final guest = characters.where((c) => c.isGuest &&
        (Offset(c.gx, c.gy) - gridPos).distance <= 1.5).firstOrNull;
    if (guest != null) {
      guest.patience = min(50.0, guest.patience + 8.0);
      if (guest.state == CharacterState.eating) {
        guest.stateTimer = max(0.2, guest.stateTimer - 1.5);
      }
      final pos = _gridToViewport(guest.gx, guest.gy);
      floatingLabels.add(FloatingLabel(
        id: 'lbl_${_nextParticleId++}',
        text: '❤️ VIP SERVICE!',
        screenPos: pos,
        color: const Color(0xFFFF4081),
      ));
      notifyListeners();
      return true;
    }

    return false;
  }
}
