import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../logic/game_state.dart';
import '../../models/character.dart';
import '../../models/enums.dart';
import '../../models/station.dart';
import '../../services/sprite_cache.dart';
import '../../utils/iso_math.dart';

/// Renders the full 2.5D isometric Idle Diner using pre-rendered 3D sprites,
/// textured floors, 3D-extruded cutaway walls, and zero placeholder emojis.
class ResortPainter extends CustomPainter {
  final GameState gs;
  final double time; // for animations

  ResortPainter({required this.gs, required this.time});

  // ─── Time-of-Day Lighting ────────────────────────────────────────────────
  // 120-second day/night cycle: 0.0–0.45 day, 0.45–0.65 sunset, 0.65–0.90 night, 0.90–1.0 dawn
  double get cyclePhase => (time % 120.0) / 120.0;

  Color _ambientTint(Color baseColor) {
    final p = cyclePhase;
    if (p < 0.45) {
      return baseColor;
    } else if (p < 0.65) {
      final t = (p - 0.45) / 0.20;
      return Color.lerp(baseColor, const Color(0xFFFFB366), t * 0.35)!;
    } else if (p < 0.90) {
      final t = (p < 0.75) ? (p - 0.65) / 0.10 : (0.90 - p) / 0.15;
      return Color.lerp(baseColor, const Color(0xFF1A2750), t * 0.45)!;
    } else {
      final t = (p - 0.90) / 0.10;
      return Color.lerp(const Color(0xFF1A2750), baseColor, t)!;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(gs.cameraOffset.dx, gs.cameraOffset.dy);
    canvas.scale(gs.cameraZoom, gs.cameraZoom);

    // 1. Exterior Ground (Emerald lawn, asphalt parking, zebra crosswalk, roadside sign)
    _drawExterior(canvas);

    // 2. Interior Diner Room Floors (4 Rooms with textured tiles)
    _drawDinerFloors(canvas);

    // 3. 3D-Extruded Cutaway Walls with Wood / White Top Trim
    _drawCutawayWalls(canvas);

    // 4. Room Fixtures & Architectural Decors
    _drawRoomFixtures(canvas);

    // 5. Unified Depth-Sorted Entities (Stations, Cars, and Characters)
    _drawDepthSortedWorld(canvas);

    // 6. Night Lighting & Neon Glows
    _drawNightLighting(canvas);

    // 7. Zone Architecture Badges
    _drawZoneLabels(canvas);

    canvas.restore();

    // 8. Screen-Space Floating Labels & Particle Trails (Clean text and numbers, no emojis)
    _drawFloatingLabels(canvas);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. EXTERIOR GROUND & PARKING LOT
  // ═══════════════════════════════════════════════════════════════════════════

  void _drawExterior(Canvas canvas) {
    // 1a. Emerald Grass Lawn surrounding the diner
    final lawnPath = _roomPolygon(-2.0, 11.5, 18.0, 6.0);
    final lawnPaint = Paint()
      ..color = _ambientTint(const Color(0xFF2E7D32));
    canvas.drawPath(lawnPath, lawnPaint);

    // Subtle turf stripe shading on the lawn
    final lawnStripePaint = Paint()
      ..color = _ambientTint(const Color(0xFF388E3C)).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    for (double gy = 12.0; gy < 17.5; gy += 1.0) {
      final p1 = IsoMath.gridToScreen(-2.0, gy);
      final p2 = IsoMath.gridToScreen(16.0, gy);
      canvas.drawLine(p1, p2, lawnStripePaint);
    }

    // 1b. Asphalt Parking Lot
    final asphaltPath = _roomPolygon(-1.0, 13.0, 7.5, 4.5);
    final asphaltPaint = Paint()
      ..color = _ambientTint(const Color(0xFF212529));
    canvas.drawPath(asphaltPath, asphaltPaint);

    // Concrete curb border around asphalt
    final curbPaint = Paint()
      ..color = _ambientTint(const Color(0xFF90A4AE))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawPath(asphaltPath, curbPaint);

    // 1c. 5 Angled Parking Stalls
    final stallPaint = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int i = 0; i <= 5; i++) {
      final gx = 0.0 + i * 1.1;
      final gyStart = 13.6 + i * 0.25;
      final p1 = IsoMath.gridToScreen(gx, gyStart);
      final p2 = IsoMath.gridToScreen(gx + 1.2, gyStart + 1.6);
      canvas.drawLine(p1, p2, stallPaint);
    }

    // 1d. Zebra Crosswalk leading from parking lot to diner front entrance
    final crosswalkPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    for (double offset = 0.0; offset < 2.5; offset += 0.5) {
      final p1 = IsoMath.gridToScreen(2.5 + offset, 12.2);
      final p2 = IsoMath.gridToScreen(2.5 + offset, 13.2);
      canvas.drawLine(p1, p2, crosswalkPaint);
    }

    // 1e. Roadside "Idle Diner" Neon Sign on the lawn verge
    final signPos = IsoMath.gridToScreen(-1.2, 13.2);
    final neonImg = SpriteCache.get('idle_diner_neon');
    if (neonImg != null) {
      _drawSprite(canvas, signPos.translate(0, -32), 64, 48, neonImg);
    } else {
      // Procedural neon sign billboard fallback
      _drawIsoBox(canvas, signPos.translate(0, -20), 40, 20, 16, const Color(0xFFB71C1C));
      final polePaint = Paint()..color = const Color(0xFF455A64)..strokeWidth = 3.0;
      canvas.drawLine(signPos, signPos.translate(0, -20), polePaint);
    }

    // Soft neon glow under sign
    final signGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFF5252).withValues(alpha: 0.35),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: signPos.translate(0, -25), radius: 36));
    canvas.drawCircle(signPos.translate(0, -25), 36, signGlow);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. DINER FLOORS (4 ROOMS WITH TEXTURED TILES)
  // ═══════════════════════════════════════════════════════════════════════════

  void _drawDinerFloors(Canvas canvas) {
    // ── Room 1: Cocktail Lounge & Reception (gx: 1..5, gy: 0..10) ────────────
    final loungePath = _roomPolygon(1.0, 0.0, 4.0, 10.0);
    final loungeImg = SpriteCache.get('reception_tiles') ?? SpriteCache.get('wood_parquet');
    _drawTexturedRoom(canvas, loungePath, loungeImg, const Color(0xFF6D4C41));

    // Red hostess carpet runner leading to host / reception
    final runnerImg = SpriteCache.get('red_carpet_runner');
    final carpetPath = _roomPolygon(2.2, 1.5, 1.6, 8.5);
    if (runnerImg != null) {
      _drawTexturedRoom(canvas, carpetPath, runnerImg, const Color(0xFFB71C1C));
    } else {
      final carpetPaint = Paint()..color = _ambientTint(const Color(0xFFC62828));
      canvas.drawPath(carpetPath, carpetPaint);
    }

    // ── Room 2: 50s Milkshake Cafe (gx: 5..9, gy: 0..6) ─────────────────────
    final cafePath = _roomPolygon(5.0, 0.0, 4.0, 6.0);
    // Mint-green & cream diamond checkerboard
    _drawCheckerboardRoom(canvas, 5, 0, 4, 6, const Color(0xFF80CBC4), const Color(0xFFFFF9C4));

    // ── Room 3: Commercial Kitchen (gx: 9..15, gy: 0..6) ────────────────────
    final kitchenPath = _roomPolygon(9.0, 0.0, 6.0, 6.0);
    final kitchenImg = SpriteCache.get('kitchen_slate_tiles');
    _drawTexturedRoom(canvas, kitchenPath, kitchenImg, const Color(0xFF37474F));

    // Crimson pass rug along the kitchen pass counter
    final passRugImg = SpriteCache.get('kitchen_pass_rug');
    final passRugPath = _roomPolygon(9.5, 5.0, 4.5, 0.9);
    if (passRugImg != null) {
      _drawTexturedRoom(canvas, passRugPath, passRugImg, const Color(0xFF880E4F));
    } else {
      final rugPaint = Paint()..color = _ambientTint(const Color(0xFF880E4F));
      canvas.drawPath(passRugPath, rugPaint);
    }

    // ── Room 4: Main 9-Booth Dining Hall (gx: 5..15, gy: 6..12) ─────────────
    final diningPath = _roomPolygon(5.0, 6.0, 10.0, 6.0);
    final dinerImg = SpriteCache.get('diner_diamond_tiles');
    _drawTexturedRoom(canvas, diningPath, dinerImg, const Color(0xFFD32F2F));

    // Fine isometric tile grid lines for crisp diamond seams
    _drawTileGridLines(canvas, 1, 0, 14, 12);
  }

  void _drawTexturedRoom(Canvas canvas, Path roomPath, ui.Image? img, Color fallbackColor) {
    if (img != null) {
      canvas.save();
      canvas.clipPath(roomPath);
      final matrix = Float64List.fromList([
        0.35, 0, 0, 0,
        0, 0.35, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1,
      ]);
      final p = Paint()
        ..shader = ImageShader(img, TileMode.repeated, TileMode.repeated, matrix);
      canvas.drawPath(roomPath, p);

      // Apply ambient lighting tint over texture
      final tint = _ambientTint(Colors.transparent);
      if (tint.alpha > 0) {
        canvas.drawPath(roomPath, Paint()..color = tint);
      }
      canvas.restore();
    } else {
      final p = Paint()..color = _ambientTint(fallbackColor);
      canvas.drawPath(roomPath, p);
    }
  }

  void _drawCheckerboardRoom(Canvas canvas, int gx, int gy, int w, int h, Color colorA, Color colorB) {
    for (int x = gx; x < gx + w; x++) {
      for (int y = gy; y < gy + h; y++) {
        final isEven = (x + y) % 2 == 0;
        final tileColor = _ambientTint(isEven ? colorA : colorB);
        final path = _tilePath(x.toDouble(), y.toDouble());
        canvas.drawPath(path, Paint()..color = tileColor);
      }
    }
  }

  void _drawTileGridLines(Canvas canvas, int minGx, int minGy, int w, int h) {
    final edgePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    for (int x = minGx; x < minGx + w; x++) {
      for (int y = minGy; y < minGy + h; y++) {
        final path = _tilePath(x.toDouble(), y.toDouble());
        canvas.drawPath(path, edgePaint);
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. 3D-EXTRUDED CUTAWAY WALLS WITH WOOD & WHITE TOP TRIMS
  // ═══════════════════════════════════════════════════════════════════════════

  void _drawCutawayWalls(Canvas canvas) {
    const wallHeight = 42.0;

    // North-West back wall (gy = 0, gx from 1 to 15)
    _drawWallSegment(
      canvas,
      gxStart: 1.0, gyStart: 0.0,
      gxEnd: 15.0, gyEnd: 0.0,
      height: wallHeight,
      wallColor: const Color(0xFFECEFF1),
      trimColor: const Color(0xFF6D4C41),
      isLeftFacing: false,
    );

    // North-East back wall (gx = 1, gy from 0 to 10)
    _drawWallSegment(
      canvas,
      gxStart: 1.0, gyStart: 0.0,
      gxEnd: 1.0, gyEnd: 10.0,
      height: wallHeight,
      wallColor: const Color(0xFFCFD8DC),
      trimColor: const Color(0xFF5D4037),
      isLeftFacing: true,
    );

    // Partition wall between Kitchen & Dining Hall (gy = 6, gx from 9 to 15)
    _drawWallSegment(
      canvas,
      gxStart: 9.0, gyStart: 6.0,
      gxEnd: 15.0, gyEnd: 6.0,
      height: 24.0, // Low cutaway pass wall
      wallColor: const Color(0xFFB0BEC5),
      trimColor: const Color(0xFFECEFF1),
      isLeftFacing: false,
    );

    // Partition wall between Lounge/Cafe & Dining Hall (gx = 5, gy from 0 to 6)
    _drawWallSegment(
      canvas,
      gxStart: 5.0, gyStart: 0.0,
      gxEnd: 5.0, gyEnd: 6.0,
      height: 28.0,
      wallColor: const Color(0xFF80CBC4),
      trimColor: const Color(0xFFFFF9C4),
      isLeftFacing: true,
    );
  }

  void _drawWallSegment(
    Canvas canvas, {
    required double gxStart,
    required double gyStart,
    required double gxEnd,
    required double gyEnd,
    required double height,
    required Color wallColor,
    required Color trimColor,
    required bool isLeftFacing,
  }) {
    final pStart = IsoMath.gridToScreen(gxStart, gyStart);
    final pEnd = IsoMath.gridToScreen(gxEnd, gyEnd);

    final topStart = pStart.translate(0, -height);
    final topEnd = pEnd.translate(0, -height);

    // Wall face
    final wallPath = Path()
      ..moveTo(pStart.dx, pStart.dy)
      ..lineTo(pEnd.dx, pEnd.dy)
      ..lineTo(topEnd.dx, topEnd.dy)
      ..lineTo(topStart.dx, topStart.dy)
      ..close();

    final shadedWall = isLeftFacing
        ? Color.lerp(wallColor, Colors.black, 0.15)!
        : Color.lerp(wallColor, Colors.white, 0.08)!;

    canvas.drawPath(wallPath, Paint()..color = _ambientTint(shadedWall));

    // Wooden wainscot baseboard trim along the bottom edge
    final baseStart = pStart.translate(0, -5.0);
    final baseEnd = pEnd.translate(0, -5.0);
    final basePath = Path()
      ..moveTo(pStart.dx, pStart.dy)
      ..lineTo(pEnd.dx, pEnd.dy)
      ..lineTo(baseEnd.dx, baseEnd.dy)
      ..lineTo(baseStart.dx, baseStart.dy)
      ..close();
    canvas.drawPath(basePath, Paint()..color = _ambientTint(const Color(0xFF4E342E)));

    // 3D Top Trim Cap (White or warm wood ledge)
    final trimPaint = Paint()
      ..color = _ambientTint(trimColor)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(topStart, topEnd, trimPaint);

    // Specular highlight on top trim
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(topStart.translate(0, -1.5), topEnd.translate(0, -1.5), highlightPaint);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. ROOM FIXTURES & ARCHITECTURAL DECORS
  // ═══════════════════════════════════════════════════════════════════════════

  void _drawRoomFixtures(Canvas canvas) {
    // ── Kitchen Pass Counter & Silver Heat Lamps ────────────────────────────
    final passStart = IsoMath.gridToScreen(9.2, 5.9);
    final passEnd = IsoMath.gridToScreen(13.8, 5.9);

    // Stainless steel pass counter shelf
    final counterPaint = Paint()
      ..color = _ambientTint(const Color(0xFFCFD8DC))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.square;
    canvas.drawLine(passStart, passEnd, counterPaint);

    // Silver heat lamps hanging above pass counter
    final lampPaint = Paint()..color = const Color(0xFFB0BEC5);
    final glowPaint = Paint()
      ..color = const Color(0xFFFFAB40).withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    for (double f = 0.2; f <= 0.8; f += 0.3) {
      final lampBase = Offset.lerp(passStart, passEnd, f)!;
      final lampTop = lampBase.translate(0, -22);
      canvas.drawLine(lampTop, lampBase.translate(0, -12), Paint()..color = const Color(0xFF546E7A)..strokeWidth = 1.2);
      canvas.drawCircle(lampBase.translate(0, -12), 4.5, lampPaint);
      canvas.drawCircle(lampBase.translate(0, -6), 9.0, glowPaint);
    }

    // ── 50s Milkshake Cafe Neon Sign & Soda Fountain Counter ────────────────
    final cafeNeonPos = IsoMath.gridToScreen(7.0, 0.4).translate(0, -32);
    final shakeNeonImg = SpriteCache.get('the_milk_shake_neon');
    if (shakeNeonImg != null) {
      _drawSprite(canvas, cafeNeonPos, 48, 32, shakeNeonImg);
    }
    // Neon magenta/cyan glow
    final shakeGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFE040FB).withValues(alpha: 0.32),
          const Color(0xFF00E5FF).withValues(alpha: 0.12),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: cafeNeonPos, radius: 28));
    canvas.drawCircle(cafeNeonPos, 28, shakeGlow);

    // Retro Soda fountain counter with 4 mint tables
    final sodaCounterPos = IsoMath.gridToScreen(6.5, 2.5);
    _drawIsoBox(canvas, sodaCounterPos, 34, 17, 14, const Color(0xFF80CBC4));

    // ── Cocktail Lounge Bar, Bottle Shelf & Jukebox ─────────────────────────
    // Backlit liquor shelf mounted on back wall
    final shelfPos = IsoMath.gridToScreen(1.6, 7.0).translate(0, -22);
    final shelfImg = SpriteCache.get('lounge_shelf_bottles');
    if (shelfImg != null) {
      _drawSprite(canvas, shelfPos, 44, 30, shelfImg);
    }

    // Wurlitzer Jukebox in the corner with pulsing color arcs
    final jukePos = IsoMath.gridToScreen(1.8, 4.0);
    final jukeImg = SpriteCache.get('jukebox_facade');
    if (jukeImg != null) {
      _drawSprite(canvas, jukePos.translate(0, -16), 34, 40, jukeImg);
    } else {
      _drawIsoBox(canvas, jukePos.translate(0, -12), 22, 14, 26, const Color(0xFFC62828));
    }
    // Jukebox chromatic light pulse
    final pulseColor = HSVColor.fromAHSV(0.35, (time * 60) % 360, 0.85, 1.0).toColor();
    final jukePulse = Paint()
      ..shader = RadialGradient(
        colors: [pulseColor, Colors.transparent],
      ).createShader(Rect.fromCircle(center: jukePos.translate(0, -16), radius: 26));
    canvas.drawCircle(jukePos.translate(0, -16), 26, jukePulse);

    // Cherry mahogany cocktail bar
    final barPos = IsoMath.gridToScreen(3.2, 7.8);
    _drawIsoBox(canvas, barPos, 38, 19, 15, const Color(0xFF4E342E));
    // Brass footrail
    final railPaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..strokeWidth = 2.0;
    canvas.drawLine(barPos.translate(-16, 12), barPos.translate(16, 12), railPaint);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 5. UNIFIED DEPTH-SORTED ENTITIES (STATIONS, CARS, CHARACTERS)
  // ═══════════════════════════════════════════════════════════════════════════

  void _drawDepthSortedWorld(Canvas canvas) {
    // Collect all renderable entities with their depth keys
    final renderables = <_RenderableItem>[];

    // 5a. Parked Cars in Parking Lot
    final carKeys = ['car_taxi', 'car_sedan', 'car_suv', 'car_delivery', 'car_sport'];
    for (int i = 0; i < 5; i++) {
      final gx = 0.5 + i * 1.0;
      final gy = 14.0 + i * 0.35;
      renderables.add(_RenderableItem(
        depth: IsoMath.depthKey(gx, gy),
        type: _RenderableType.car,
        gx: gx,
        gy: gy,
        data: carKeys[i % carKeys.length],
      ));
    }

    // 5b. Stations
    for (final s in gs.stations) {
      renderables.add(_RenderableItem(
        depth: IsoMath.depthKey(s.gx, s.gy),
        type: _RenderableType.station,
        gx: s.gx,
        gy: s.gy,
        data: s,
      ));
    }

    // 5c. Characters
    for (final c in gs.characters) {
      renderables.add(_RenderableItem(
        depth: IsoMath.depthKey(c.gx, c.gy),
        type: _RenderableType.character,
        gx: c.gx,
        gy: c.gy,
        data: c,
      ));
    }

    // Sort strictly by isometric depth (lower = background, higher = foreground)
    renderables.sort((a, b) => a.depth.compareTo(b.depth));

    // Render in sorted order
    for (final item in renderables) {
      switch (item.type) {
        case _RenderableType.car:
          _drawCar(canvas, item.gx, item.gy, item.data as String);
          break;
        case _RenderableType.station:
          _drawStation(canvas, item.data as Station);
          break;
        case _RenderableType.character:
          _drawCharacter(canvas, item.data as Character);
          break;
      }
    }
  }

  void _drawCar(Canvas canvas, double gx, double gy, String spriteKey) {
    final pos = IsoMath.gridToScreen(gx, gy);

    // Contact shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.32)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawOval(Rect.fromCenter(center: pos.translate(0, 4), width: 56, height: 26), shadowPaint);

    final carImg = SpriteCache.get(spriteKey);
    if (carImg != null) {
      _drawSprite(canvas, pos.translate(0, -18), 64, 48, carImg);
    } else {
      // Procedural car fallback
      _drawIsoBox(canvas, pos.translate(0, -10), 44, 22, 16, const Color(0xFF1976D2));
    }
  }

  void _drawStation(Canvas canvas, Station s) {
    final pos = IsoMath.gridToScreen(s.gx, s.gy);

    // Main 9-Booth Dining Hall tables or Terrace cabanas
    if (s.zone == ZoneType.diningRoom || s.id.startsWith('table')) {
      _drawBoothTable(canvas, pos, s);
      return;
    }

    // Commercial Kitchen Stoves
    if (s.zone == ZoneType.kitchen || s.id.contains('stove') || s.id == 'kitchen_cook') {
      _drawKitchenStove(canvas, pos, s);
      return;
    }

    // Reception Desks
    if (s.zone == ZoneType.reception || s.id.startsWith('reception')) {
      _drawReceptionDesk(canvas, pos, s);
      return;
    }

    // 50s Milkshake Bar
    if (s.id == 'milkshake_bar') {
      _drawSodaFountainStation(canvas, pos, s);
      return;
    }

    // Cocktail Lounge
    if (s.id == 'cocktail_lounge') {
      _drawLoungeStation(canvas, pos, s);
      return;
    }
  }

  void _drawBoothTable(Canvas canvas, Offset pos, Station s) {
    // Soft contact shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.30)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawOval(Rect.fromCenter(center: pos.translate(0, 4), width: 54, height: 26), shadowPaint);

    final boothImg = SpriteCache.get('booth');
    if (boothImg != null) {
      _drawSprite(canvas, pos.translate(0, -18), 68, 64, boothImg);
    } else {
      // Procedural booth fallback (red vinyl seats, polished wood table)
      _drawIsoBox(canvas, pos.translate(0, -6), 34, 18, 10, const Color(0xFFC62828));
      _drawIsoBox(canvas, pos.translate(0, -10), 22, 12, 12, const Color(0xFFFFF8E1));
    }

    // Dining progress indicator
    if (s.progressFraction > 0 && s.progressFraction < 1) {
      _drawProgressBar(canvas, pos.translate(0, -38), s.progressFraction, color: const Color(0xFFEF5350));
    }

    // Level badge
    _drawLevelBadge(canvas, pos.translate(14, -34), s.level);
  }

  void _drawKitchenStove(Canvas canvas, Offset pos, Station s) {
    // Contact shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.32)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawOval(Rect.fromCenter(center: pos.translate(0, 3), width: 44, height: 22), shadowPaint);

    final stoveImg = SpriteCache.get('stove');
    if (stoveImg != null) {
      _drawSprite(canvas, pos.translate(0, -16), 56, 52, stoveImg);
    } else {
      // Procedural stainless steel stove fallback
      _drawIsoBox(canvas, pos.translate(0, -8), 36, 18, 18, const Color(0xFF607D8B));
    }

    // Glowing burners (animated heat flicker)
    final burnerPulse = 0.85 + sin(time * 10) * 0.15;
    final burnerPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Color.lerp(const Color(0xFFFF6D00), const Color(0xFFFFD600), burnerPulse)!,
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: pos.translate(-6, -18), radius: 6));
    canvas.drawCircle(pos.translate(-6, -18), 6, burnerPaint);
    canvas.drawCircle(pos.translate(6, -15), 5, burnerPaint);

    // Cooking progress bar
    if (s.progressFraction > 0 && s.progressFraction < 1) {
      _drawProgressBar(canvas, pos.translate(0, -38), s.progressFraction, color: const Color(0xFFFF9800));
    }

    // Food ready notification badge
    if (s.foodReady) {
      _drawStatusPill(canvas, pos.translate(0, -42), 'bubble_fork_knife');
    }

    // Level badge
    _drawLevelBadge(canvas, pos.translate(14, -32), s.level);
  }

  void _drawReceptionDesk(Canvas canvas, Offset pos, Station s) {
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.28)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawOval(Rect.fromCenter(center: pos.translate(0, 3), width: 46, height: 22), shadowPaint);

    // Polished mahogany reception counter
    _drawIsoBox(canvas, pos.translate(0, -6), 38, 19, 14, const Color(0xFF5D4037));

    // Golden brass service bell (vector drawn, no emojis)
    final bellBase = pos.translate(10, -20);
    final bellPaint = Paint()..color = const Color(0xFFFFD54F);
    canvas.drawCircle(bellBase, 4.0, bellPaint);
    canvas.drawLine(bellBase.translate(0, -4), bellBase.translate(0, -6), Paint()..color = const Color(0xFFFFB300)..strokeWidth = 1.5);

    // Level badge
    _drawLevelBadge(canvas, pos.translate(0, -28), s.level);
  }

  void _drawSodaFountainStation(Canvas canvas, Offset pos, Station s) {
    _drawLevelBadge(canvas, pos.translate(0, -28), s.level);
  }

  void _drawLoungeStation(Canvas canvas, Offset pos, Station s) {
    _drawLevelBadge(canvas, pos.translate(0, -28), s.level);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 5d. CHARACTERS (PRE-RENDERED 3D SPRITES & ZERO EMOJIS)
  // ═══════════════════════════════════════════════════════════════════════════

  void _drawCharacter(Canvas canvas, Character c) {
    final pos = IsoMath.gridToScreen(c.gx, c.gy);
    final bounce = c.isMoving ? sin(c.walkCycle) * 2.5 : 0.0;
    final charCenter = pos.translate(0, -20 + bounce);

    // Soft contact shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.26)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawOval(Rect.fromCenter(center: pos.translate(0, 2), width: 20, height: 9), shadowPaint);

    // VIP gold particle shimmer ring
    if (c.isVip) {
      final vipRing = Paint()
        ..color = const Color(0xFFFFD700).withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawOval(Rect.fromCenter(center: pos.translate(0, 1), width: 26, height: 12), vipRing);
    }

    // Select pre-rendered 3D isometric sprite
    String spriteKey;
    switch (c.type) {
      case CharacterType.waiter:
        spriteKey = 'waiter';
        break;
      case CharacterType.chef:
        spriteKey = 'chef';
        break;
      case CharacterType.guest:
        spriteKey = c.isVip ? 'customer_vip' : 'customer';
        break;
      default:
        spriteKey = 'customer';
    }

    final charImg = SpriteCache.get(spriteKey);
    if (charImg != null) {
      _drawSprite(canvas, charCenter, 36, 48, charImg);
    } else {
      // Procedural stylized silhouette fallback
      final bodyColor = (c.type == CharacterType.chef)
          ? const Color(0xFFECEFF1)
          : (c.type == CharacterType.waiter)
              ? const Color(0xFF263238)
              : const Color(0xFF1E88E5);
      canvas.drawCircle(charCenter.translate(0, -10), 6.5, Paint()..color = const Color(0xFFFFCC80));
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: charCenter.translate(0, 4), width: 14, height: 18), const Radius.circular(4)),
        Paint()..color = bodyColor,
      );
    }

    // Guest Patience Bar
    if (c.isGuest && c.patience < 28) {
      final fraction = (c.patience / 40.0).clamp(0.0, 1.0);
      final pColor = Color.lerp(Colors.red, const Color(0xFF4CAF50), fraction)!;
      _drawProgressBar(canvas, charCenter.translate(0, 16), fraction, color: pColor);
    }

    // Status bubble with high-res sprite icon
    final bubbleKey = _bubbleKeyForState(c.state);
    if (bubbleKey != null) {
      _drawStatusPill(canvas, charCenter.translate(14, -18), bubbleKey);
    }
  }

  String? _bubbleKeyForState(CharacterState state) {
    switch (state) {
      case CharacterState.queuingAtReception:
      case CharacterState.checkingIn:
      case CharacterState.seated:
        return 'bubble_hourglass';
      case CharacterState.eating:
      case CharacterState.carryingFood:
      case CharacterState.cooking:
        return 'bubble_fork_knife';
      case CharacterState.leaving:
        return 'bubble_cash_stack';
      default:
        return null;
    }
  }

  void _drawStatusPill(Canvas canvas, Offset pos, String bubbleKey) {
    // Sleek white rounded pill container
    final pillRect = Rect.fromCenter(center: pos, width: 22, height: 22);
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawRRect(RRect.fromRectAndRadius(pillRect.translate(0, 1), const Radius.circular(11)), shadowPaint);

    final bgPaint = Paint()..color = Colors.white;
    canvas.drawRRect(RRect.fromRectAndRadius(pillRect, const Radius.circular(11)), bgPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFFFFB300)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRRect(RRect.fromRectAndRadius(pillRect, const Radius.circular(11)), borderPaint);

    // Sprite icon inside bubble
    final iconImg = SpriteCache.get(bubbleKey);
    if (iconImg != null) {
      _drawSprite(canvas, pos, 15, 15, iconImg);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 6. NIGHT LIGHTING & WARM AMBIENT GLOWS (NO POOL)
  // ═══════════════════════════════════════════════════════════════════════════

  void _drawNightLighting(Canvas canvas) {
    final p = cyclePhase;
    if (p < 0.60 || p > 0.95) return;
    final nightAlpha = (p < 0.70)
        ? (p - 0.60) / 0.10
        : (p > 0.88)
            ? (0.95 - p) / 0.07
            : 1.0;

    // Warm golden lantern halos around dining booths and stations
    for (final s in gs.stations) {
      final center = IsoMath.gridToScreen(s.gx, s.gy);
      final lampPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFE082).withValues(alpha: 0.38 * nightAlpha),
            const Color(0xFFFFD54F).withValues(alpha: 0.14 * nightAlpha),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: 48));
      canvas.drawCircle(center, 48, lampPaint);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 7. SLEEK ARCHITECTURAL ZONE BADGES (NO EMOJIS, NO HOTEL/POOL)
  // ═══════════════════════════════════════════════════════════════════════════

  void _drawZoneLabels(Canvas canvas) {
    final labels = <Map<String, dynamic>>[
      {'text': '50s MILKSHAKE CAFE', 'gx': 7.0, 'gy': 0.8},
      {'text': 'COMMERCIAL KITCHEN', 'gx': 12.0, 'gy': 0.8},
      {'text': 'COCKTAIL LOUNGE', 'gx': 2.8, 'gy': 5.8},
      {'text': 'MAIN DINING HALL', 'gx': 10.0, 'gy': 6.8},
      {'text': 'PARKING & DRIVE-IN', 'gx': 3.0, 'gy': 13.4},
    ];

    final tp = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (final l in labels) {
      final pos = IsoMath.gridToScreen((l['gx'] as double), (l['gy'] as double));
      final text = l['text'] as String;

      tp.text = TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 8.5,
          color: Color(0xFFFFF8E1),
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      );
      tp.layout();

      // Rounded background pill
      final pillRect = Rect.fromCenter(center: pos, width: tp.width + 12, height: tp.height + 6);
      final pillPaint = Paint()
        ..color = const Color(0xCC212121)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(RRect.fromRectAndRadius(pillRect, const Radius.circular(8)), pillPaint);

      final pillBorder = Paint()
        ..color = const Color(0x66FFD54F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;
      canvas.drawRRect(RRect.fromRectAndRadius(pillRect, const Radius.circular(8)), pillBorder);

      tp.paint(canvas, pos.translate(-tp.width / 2, -tp.height / 2));
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 8. SCREEN-SPACE FLOATING LABELS & PARTICLES
  // ═══════════════════════════════════════════════════════════════════════════

  void _drawFloatingLabels(Canvas canvas) {
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (final l in gs.floatingLabels) {
      tp.text = TextSpan(
        text: l.text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: l.color.withValues(alpha: l.opacity),
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: l.opacity * 0.6),
              offset: const Offset(1, 1),
              blurRadius: 3,
            ),
          ],
        ),
      );
      tp.layout();
      tp.paint(canvas, l.screenPos.translate(-tp.width / 2, -tp.height / 2));
    }

    for (final p in gs.particles) {
      final paint = Paint()
        ..color = p.color.withValues(alpha: p.life)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(p.pos, p.size * p.life, paint);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  Path _tilePath(double gx, double gy) {
    final c = IsoMath.gridToScreen(gx, gy);
    final r = IsoMath.gridToScreen(gx + 1, gy);
    final b = IsoMath.gridToScreen(gx + 1, gy + 1);
    final l = IsoMath.gridToScreen(gx, gy + 1);
    return Path()
      ..moveTo(c.dx, c.dy)
      ..lineTo(r.dx, r.dy)
      ..lineTo(b.dx, b.dy)
      ..lineTo(l.dx, l.dy)
      ..close();
  }

  Path _roomPolygon(double gx, double gy, double w, double h) {
    final top = IsoMath.gridToScreen(gx, gy);
    final right = IsoMath.gridToScreen(gx + w, gy);
    final bottom = IsoMath.gridToScreen(gx + w, gy + h);
    final left = IsoMath.gridToScreen(gx, gy + h);
    return Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(right.dx, right.dy)
      ..lineTo(bottom.dx, bottom.dy)
      ..lineTo(left.dx, left.dy)
      ..close();
  }

  void _drawSprite(Canvas canvas, Offset center, double width, double height, ui.Image img) {
    final srcRect = Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble());
    final dstRect = Rect.fromCenter(center: center, width: width, height: height);
    canvas.drawImageRect(img, srcRect, dstRect, Paint()..filterQuality = FilterQuality.medium);
  }

  void _drawIsoBox(Canvas canvas, Offset topCenter, double w, double h, double depth, Color color) {
    final topPaint = Paint()..color = _ambientTint(color);
    final leftPaint = Paint()..color = _ambientTint(Color.lerp(color, Colors.black, 0.25)!);
    final rightPaint = Paint()..color = _ambientTint(Color.lerp(color, Colors.black, 0.40)!);

    final tl = topCenter.translate(-w / 2, 0);
    final tr = topCenter.translate(w / 2, 0);
    final tc = topCenter.translate(0, -h / 2);
    final bc = topCenter.translate(0, h / 2);

    final topPath = Path()
      ..moveTo(tc.dx, tc.dy)
      ..lineTo(tr.dx, tr.dy)
      ..lineTo(bc.dx, bc.dy)
      ..lineTo(tl.dx, tl.dy)
      ..close();
    canvas.drawPath(topPath, topPaint);

    final leftPath = Path()
      ..moveTo(tl.dx, tl.dy)
      ..lineTo(bc.dx, bc.dy)
      ..lineTo(bc.dx, bc.dy + depth)
      ..lineTo(tl.dx, tl.dy + depth)
      ..close();
    canvas.drawPath(leftPath, leftPaint);

    final rightPath = Path()
      ..moveTo(tr.dx, tr.dy)
      ..lineTo(bc.dx, bc.dy)
      ..lineTo(bc.dx, bc.dy + depth)
      ..lineTo(tr.dx, tr.dy + depth)
      ..close();
    canvas.drawPath(rightPath, rightPaint);

    final edgePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawPath(topPath, edgePaint);
  }

  void _drawProgressBar(Canvas canvas, Offset pos, double fraction, {Color color = const Color(0xFF4CAF50)}) {
    const w = 32.0;
    const h = 5.0;

    final bgPaint = Paint()
      ..color = Colors.black38
      ..style = PaintingStyle.fill;
    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final rect = Rect.fromCenter(center: pos, width: w, height: h);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(3)), bgPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rect.left, rect.top, w * fraction.clamp(0.0, 1.0), h),
        const Radius.circular(3),
      ),
      fgPaint,
    );
  }

  void _drawLevelBadge(Canvas canvas, Offset pos, int level) {
    final bgPaint = Paint()..color = const Color(0xFFFF9800);
    canvas.drawCircle(pos, 8, bgPaint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(pos, 8, borderPaint);

    final tp = TextPainter(
      text: TextSpan(
        text: '$level',
        style: const TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, pos.translate(-tp.width / 2, -tp.height / 2));
  }

  @override
  bool shouldRepaint(ResortPainter old) => true;
}

enum _RenderableType { car, station, character }

class _RenderableItem {
  final double depth;
  final _RenderableType type;
  final double gx;
  final double gy;
  final Object data;

  _RenderableItem({
    required this.depth,
    required this.type,
    required this.gx,
    required this.gy,
    required this.data,
  });
}
