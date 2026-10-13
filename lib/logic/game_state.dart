import 'dart:math';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import '../models/character.dart';
import '../models/enums.dart';
import '../models/manager.dart';
import '../models/particles.dart';
import '../models/station.dart';
import '../utils/iso_math.dart';

/// Central game state — all simulation data lives here.
/// Extends ChangeNotifier so the UI rebuilds on every tick.
class GameState extends ChangeNotifier {
  // ─── Economy ─────────────────────────────────────────────────────────────
  double cash = 500.0;
  double totalEarned = 0.0;
  int reputation = 1;          // prestige multiplier level
  String hotelName = 'Sunny Palms Resort';

  // ─── Characters ──────────────────────────────────────────────────────────
  final List<Character> characters = [];
  int _nextCharId = 0;

  // ─── Stations ─────────────────────────────────────────────────────────────
  late final List<Station> stations;

  // ─── Managers ─────────────────────────────────────────────────────────────
  final List<Manager> managers = List.from(allManagers);

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
      // ── Reception desks (Zone: reception, row 3) ──────────────────────────
      Station(
        id: 'reception_1',
        zone: ZoneType.reception,
        name: 'Reception Desk',
        gx: 4, gy: 3,
        baseCostFn: (l) => 150 * pow(1.15, l).toDouble(),
        baseIncomeFn: (l) => 25 + l * 10.0,
        baseSpeedFn: (l) => max(1.5, 4.0 - l * 0.12),
        queuePoint: const Offset(2.5, 3.5),
      ),
      Station(
        id: 'reception_2',
        zone: ZoneType.reception,
        name: 'Reception Desk',
        gx: 4, gy: 5,
        baseCostFn: (l) => 300 * pow(1.15, l).toDouble(),
        baseIncomeFn: (l) => 30 + l * 12.0,
        baseSpeedFn: (l) => max(1.5, 4.0 - l * 0.12),
        queuePoint: const Offset(2.5, 5.5),
      ),

      // ── Kitchen stoves ────────────────────────────────────────────────────
      Station(
        id: 'stove_1',
        zone: ZoneType.kitchen,
        name: 'Chef\'s Stove',
        gx: 11, gy: 2,
        baseCostFn: (l) => 200 * pow(1.15, l).toDouble(),
        baseIncomeFn: (l) => 40 + l * 15.0,
        baseSpeedFn: (l) => max(1.0, 5.0 - l * 0.15),
        queuePoint: const Offset(10.0, 2.5),
      ),
      Station(
        id: 'stove_2',
        zone: ZoneType.kitchen,
        name: 'Chef\'s Stove',
        gx: 11, gy: 4,
        baseCostFn: (l) => 400 * pow(1.15, l).toDouble(),
        baseIncomeFn: (l) => 50 + l * 18.0,
        baseSpeedFn: (l) => max(1.0, 5.0 - l * 0.15),
        queuePoint: const Offset(10.0, 4.5),
      ),

      // ── Dining tables ─────────────────────────────────────────────────────
      Station(
        id: 'table_1',
        zone: ZoneType.diningRoom,
        name: 'Dining Table',
        gx: 8, gy: 7,
        baseCostFn: (l) => 100 * pow(1.12, l).toDouble(),
        baseIncomeFn: (l) => 60 + l * 20.0,
        baseSpeedFn: (l) => max(3.0, 10.0 - l * 0.2),
        queuePoint: const Offset(7.0, 7.5),
      ),
      Station(
        id: 'table_2',
        zone: ZoneType.diningRoom,
        name: 'Dining Table',
        gx: 10, gy: 7,
        baseCostFn: (l) => 100 * pow(1.12, l).toDouble(),
        baseIncomeFn: (l) => 60 + l * 20.0,
        baseSpeedFn: (l) => max(3.0, 10.0 - l * 0.2),
        queuePoint: const Offset(9.0, 7.5),
      ),
      Station(
        id: 'table_3',
        zone: ZoneType.diningRoom,
        name: 'Dining Table',
        gx: 12, gy: 7,
        baseCostFn: (l) => 150 * pow(1.12, l).toDouble(),
        baseIncomeFn: (l) => 70 + l * 22.0,
        baseSpeedFn: (l) => max(3.0, 10.0 - l * 0.2),
        queuePoint: const Offset(11.0, 7.5),
      ),
      Station(
        id: 'table_4',
        zone: ZoneType.diningRoom,
        name: 'Dining Table',
        gx: 8, gy: 9,
        baseCostFn: (l) => 200 * pow(1.12, l).toDouble(),
        baseIncomeFn: (l) => 80 + l * 25.0,
        baseSpeedFn: (l) => max(3.0, 10.0 - l * 0.2),
        queuePoint: const Offset(7.0, 9.5),
      ),

      // ── Hotel rooms ───────────────────────────────────────────────────────
      Station(
        id: 'room_1',
        zone: ZoneType.hotelRoom,
        name: 'Standard Room',
        gx: 2, gy: 10,
        widthTiles: 2,
        baseCostFn: (l) => 500 * pow(1.18, l).toDouble(),
        baseIncomeFn: (l) => 120 + l * 30.0,
        baseSpeedFn: (l) => max(5.0, 15.0 - l * 0.25),
        queuePoint: const Offset(3.0, 9.0),
      ),
      Station(
        id: 'room_2',
        zone: ZoneType.hotelRoom,
        name: 'Standard Room',
        gx: 5, gy: 10,
        widthTiles: 2,
        baseCostFn: (l) => 600 * pow(1.18, l).toDouble(),
        baseIncomeFn: (l) => 130 + l * 32.0,
        baseSpeedFn: (l) => max(5.0, 15.0 - l * 0.25),
        queuePoint: const Offset(6.0, 9.0),
      ),
      Station(
        id: 'room_3',
        zone: ZoneType.hotelRoom,
        name: 'Deluxe Suite',
        gx: 8, gy: 12,
        widthTiles: 2,
        baseCostFn: (l) => 1200 * pow(1.20, l).toDouble(),
        baseIncomeFn: (l) => 250 + l * 60.0,
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
  void _routeGuestToReception(Character g, Station s) {
    g.state = CharacterState.walkingToReception;
    g.assignedStationId = s.id;
    s.occupiedByCharacterId = g.id;
    _walkTo(g, s.queuePoint.dx, s.queuePoint.dy);
  }

  void _routeGuestToDining(Character g, Station s) {
    g.state = CharacterState.walkingToDining;
    g.assignedStationId = s.id;
    s.occupiedByCharacterId = g.id;
    _walkTo(g, s.centerGrid.dx, s.centerGrid.dy);
  }

  void _routeGuestToRoom(Character g, Station s) {
    g.state = CharacterState.walkingToRoom;
    g.assignedStationId = s.id;
    s.occupiedByCharacterId = g.id;
    _walkTo(g, s.centerGrid.dx, s.centerGrid.dy);
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
            _onArrived(c);
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
            if (c.isGuest) {
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

    final checkInIncome = (s?.income ?? 25.0) * revenueMultiplier * (c.isVip ? 2.0 : 1.0);
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
    final mealIncome = (s?.income ?? 60.0) * revenueMultiplier * (c.isVip ? 1.5 : 1.0);
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

    final roomIncome = (s?.income ?? 120.0) * revenueMultiplier * (c.isVip ? 2.0 : 1.0);
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
    _walkTo(c, -2.0, c.gy);
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
    final s = _stationById(stationId);
    if (s == null) return false;
    if (s.level >= s.maxLevel) return false;
    if (cash < s.upgradeCost) return false;

    cash -= s.upgradeCost;
    s.level++;

    // Confetti burst at station
    final pos = _gridToViewport(s.gx, s.gy);
    _spawnCashParticles(pos);
    _spawnCashParticles(pos.translate(20, -20));

    notifyListeners();
    return true;
  }

  bool assignManager(String managerId) {
    final m = managers.firstWhere((m) => m.id == managerId,
        orElse: () => managers.first);
    if (!m.isUnlocked || m.isAssigned) return false;

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
}
