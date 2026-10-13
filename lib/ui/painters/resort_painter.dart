import 'dart:math';
import 'package:flutter/material.dart';
import '../../logic/game_state.dart';
import '../../models/character.dart';
import '../../models/enums.dart';
import '../../models/station.dart';
import '../../utils/iso_math.dart';

/// Renders the full 2.5D isometric resort using CustomPainter.
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

    _drawGround(canvas, size);
    _drawZoneLabels(canvas);
    _drawStations(canvas);
    _drawNightLighting(canvas);
    _drawCharacters(canvas);
    _drawParticles(canvas);

    canvas.restore();

    // Draw floating labels in screen space (after restore)
    _drawFloatingLabels(canvas);
  }

  void _drawNightLighting(Canvas canvas) {
    final p = cyclePhase;
    if (p < 0.60 || p > 0.95) return;
    final nightAlpha = (p < 0.70)
        ? (p - 0.60) / 0.10
        : (p > 0.88)
            ? (0.95 - p) / 0.07
            : 1.0;

    // Draw warm lantern halos around stations
    for (final s in gs.stations) {
      final center = IsoMath.gridToScreen(s.centerGrid.dx, s.centerGrid.dy);
      final lampPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFE082).withValues(alpha: 0.35 * nightAlpha),
            const Color(0xFFFFD54F).withValues(alpha: 0.12 * nightAlpha),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: 45));
      canvas.drawCircle(center, 45, lampPaint);
    }

    // Pool glowing luminescence
    final poolCenter = IsoMath.gridToScreen(14.0, 13.0);
    final poolGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF00E5FF).withValues(alpha: 0.30 * nightAlpha),
          const Color(0xFF00B0FF).withValues(alpha: 0.10 * nightAlpha),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: poolCenter, radius: 90));
    canvas.drawCircle(poolCenter, 90, poolGlow);
  }

  // ─── Ground tiles ─────────────────────────────────────────────────────────
  void _drawGround(Canvas canvas, Size size) {
    final floorColors = {
      ZoneType.entrance: const Color(0xFFD4E6B5),
      ZoneType.lobby: const Color(0xFFF5E6C8),
      ZoneType.reception: const Color(0xFFE3F2FD),
      ZoneType.kitchen: const Color(0xFFFFF3E0),
      ZoneType.diningRoom: const Color(0xFFFCE4EC),
      ZoneType.hotelRoom: const Color(0xFFE8EAF6),
      ZoneType.pool: const Color(0xFFB3E5FC),
    };

    // Zone boundaries (grid rectangles [x, y, w, h])
    final zones = <Map<String, dynamic>>[
      {'zone': ZoneType.entrance,   'x': -1, 'y': 0,  'w': 3,  'h': 6},
      {'zone': ZoneType.lobby,      'x': 2,  'y': 0,  'w': 4,  'h': 8},
      {'zone': ZoneType.reception,  'x': 3,  'y': 2,  'w': 3,  'h': 5},
      {'zone': ZoneType.kitchen,    'x': 9,  'y': 0,  'w': 6,  'h': 6},
      {'zone': ZoneType.diningRoom, 'x': 6,  'y': 5,  'w': 9,  'h': 7},
      {'zone': ZoneType.hotelRoom,  'x': 0,  'y': 8,  'w': 9,  'h': 7},
      {'zone': ZoneType.pool,       'x': 11, 'y': 10, 'w': 6,  'h': 6},
    ];

    for (final z in zones) {
      final zone = z['zone'] as ZoneType;
      final x = z['x'] as int;
      final y = z['y'] as int;
      final w = z['w'] as int;
      final h = z['h'] as int;
      final color = _ambientTint(floorColors[zone]!);

      _drawZone(canvas, x, y, w, h, color);
    }
  }

  void _drawZone(Canvas canvas, int gx, int gy, int w, int h, Color color) {
    // Draw each tile in the zone
    final paintFloor = Paint()..color = color;
    final paintEdge = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int x = gx; x < gx + w; x++) {
      for (int y = gy; y < gy + h; y++) {
        final path = _tilePath(x.toDouble(), y.toDouble());
        canvas.drawPath(path, paintFloor);
        canvas.drawPath(path, paintEdge);
      }
    }
  }

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

  // ─── Zone Labels ─────────────────────────────────────────────────────────
  void _drawZoneLabels(Canvas canvas) {
    final labels = <Map<String, dynamic>>[
      {'text': '🏨 LOBBY', 'gx': 3.5, 'gy': 1.5},
      {'text': '🛎 RECEPTION', 'gx': 5.5, 'gy': 3.5},
      {'text': '🍳 KITCHEN', 'gx': 12.0, 'gy': 1.5},
      {'text': '🍽 RESTAURANT', 'gx': 10.5, 'gy': 6.5},
      {'text': '🛏 ROOMS', 'gx': 4.5, 'gy': 11.5},
      {'text': '🏊 POOL', 'gx': 13.5, 'gy': 12.0},
    ];

    final tp = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (final l in labels) {
      final pos = IsoMath.gridToScreen(
          (l['gx'] as double), (l['gy'] as double));
      tp.text = TextSpan(
        text: l['text'] as String,
        style: const TextStyle(
          fontSize: 9,
          color: Color(0x99333333),
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      );
      tp.layout();
      tp.paint(canvas, pos.translate(-tp.width / 2, -tp.height / 2));
    }
  }

  // ─── Stations ─────────────────────────────────────────────────────────────
  void _drawStations(Canvas canvas) {
    // Sort by depth
    final sorted = List<Station>.from(gs.stations)
      ..sort((a, b) => IsoMath.depthKey(a.gx, a.gy)
          .compareTo(IsoMath.depthKey(b.gx, b.gy)));

    for (final s in sorted) {
      _drawStation(canvas, s);
    }
  }

  void _drawStation(Canvas canvas, Station s) {
    final pos = IsoMath.gridToScreen(s.gx, s.gy);
    final levelFraction = s.level / s.maxLevel;

    switch (s.zone) {
      case ZoneType.reception:
        _drawReceptionDesk(canvas, pos, s, levelFraction);
        break;
      case ZoneType.kitchen:
        _drawStove(canvas, pos, s, levelFraction);
        break;
      case ZoneType.diningRoom:
        _drawTable(canvas, pos, s, levelFraction);
        break;
      case ZoneType.hotelRoom:
        _drawHotelRoom(canvas, pos, s, levelFraction);
        break;
      default:
        break;
    }

    // Progress bar above station
    if (s.progressFraction > 0 && s.progressFraction < 1) {
      _drawProgressBar(canvas, pos.translate(0, -32), s.progressFraction);
    }
    // Food ready indicator
    if (s.zone == ZoneType.kitchen && s.foodReady) {
      _drawFoodReady(canvas, pos.translate(0, -40));
    }
    // Dirty room indicator
    if (s.zone == ZoneType.hotelRoom && s.isDirty) {
      _drawDirtyIndicator(canvas, pos.translate(0, -38));
    }
  }

  void _drawReceptionDesk(Canvas canvas, Offset pos, Station s, double lvl) {
    // Desk body (isometric box)
    final deskColor = Color.lerp(
        const Color(0xFF8D6E63), const Color(0xFFE0C39E), lvl)!;
    _drawIsoBox(canvas, pos, 36, 18, 14, deskColor);

    // Computer screen on top
    final screenPaint = Paint()..color = const Color(0xFF37474F);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: pos.translate(-4, -18), width: 12, height: 10),
        const Radius.circular(2),
      ),
      screenPaint,
    );
    // Screen glow
    final screenGlowPaint = Paint()
      ..color = const Color(0x8837BDF5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(pos.translate(-4, -18), 3, screenGlowPaint);

    // Golden bell
    _drawEmoji(canvas, pos.translate(10, -24), '🔔', 14);

    // Level badge
    _drawLevelBadge(canvas, pos.translate(0, -28), s.level);
  }

  void _drawStove(Canvas canvas, Offset pos, Station s, double lvl) {
    final stoveColor = Color.lerp(
        const Color(0xFF78909C), const Color(0xFF546E7A), lvl)!;
    _drawIsoBox(canvas, pos, 34, 17, 20, stoveColor);

    // Burner circles
    final burnerPaint = Paint()..color = const Color(0xFF37474F);
    canvas.drawCircle(pos.translate(-8, -16), 5, burnerPaint);
    canvas.drawCircle(pos.translate(6, -14), 4, burnerPaint);

    // Flames if cooking
    if (s.occupiedByCharacterId != null || s.foodReady) {
      final flameOffset = sin(time * 8) * 1.5;
      _drawEmoji(canvas, pos.translate(-8, -20 + flameOffset), '🔥', 12);
    }

    // Steam if food ready
    if (s.foodReady) {
      _drawEmoji(canvas, pos.translate(0, -32), '♨️', 14);
    }

    _drawLevelBadge(canvas, pos.translate(0, -32), s.level);
  }

  void _drawTable(Canvas canvas, Offset pos, Station s, double lvl) {
    final tableColor = Color.lerp(
        const Color(0xFF795548), const Color(0xFFFFECB3), lvl)!;
    _drawIsoBox(canvas, pos, 30, 15, 8, tableColor);

    // Tablecloth (red)
    final clothPaint = Paint()..color = const Color(0xFFEF5350).withValues(alpha: 0.8);
    canvas.drawOval(
      Rect.fromCenter(center: pos.translate(0, -6), width: 24, height: 10),
      clothPaint,
    );

    // Place settings (plates)
    final platePaint = Paint()..color = Colors.white;
    canvas.drawCircle(pos.translate(-6, -4), 3, platePaint);
    canvas.drawCircle(pos.translate(6, -4), 3, platePaint);

    // Candle
    _drawEmoji(canvas, pos.translate(0, -16), '🕯', 10);

    // Dining progress
    if (s.progressFraction > 0) {
      _drawProgressBar(canvas, pos.translate(0, -26), s.progressFraction,
          color: const Color(0xFFEF5350));
    }
  }

  void _drawHotelRoom(Canvas canvas, Offset pos, Station s, double lvl) {
    final wallColor = Color.lerp(
        const Color(0xFFB0BEC5), const Color(0xFFE1F5FE), lvl)!;

    // Room walls (isometric box, tall)
    _drawIsoBox(canvas, pos, 52, 26, 40, wallColor);

    // Window
    final winPaint = Paint()..color = const Color(0xFF81D4FA).withValues(alpha: 0.7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: pos.translate(-14, -38), width: 12, height: 14),
        const Radius.circular(2),
      ),
      winPaint,
    );
    // Window cross
    final crossPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0;
    canvas.drawLine(pos.translate(-14, -45), pos.translate(-14, -31), crossPaint);
    canvas.drawLine(pos.translate(-20, -38), pos.translate(-8, -38), crossPaint);

    // Bed
    _drawEmoji(canvas, pos.translate(6, -32), '🛏', 20);

    // Dirty overlay
    if (s.isDirty) {
      final dirtyPaint = Paint()
        ..color = const Color(0x44FF5722);
      canvas.drawOval(
        Rect.fromCenter(center: pos.translate(0, -20), width: 40, height: 20),
        dirtyPaint,
      );
      _drawEmoji(canvas, pos.translate(0, -28), '🧹', 14);
    }

    _drawLevelBadge(canvas, pos.translate(18, -44), s.level);
  }

  void _drawProgressBar(Canvas canvas, Offset pos, double fraction,
      {Color color = const Color(0xFF4CAF50)}) {
    const w = 32.0;
    const h = 5.0;

    final bgPaint = Paint()
      ..color = Colors.black26
      ..style = PaintingStyle.fill;
    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final rect = Rect.fromCenter(center: pos, width: w, height: h);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(3)),
        bgPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rect.left, rect.top, w * fraction, h),
        const Radius.circular(3),
      ),
      fgPaint,
    );
  }

  void _drawFoodReady(Canvas canvas, Offset pos) {
    _drawEmoji(canvas, pos, '✅', 12);
  }

  void _drawDirtyIndicator(Canvas canvas, Offset pos) {
    _drawEmoji(canvas, pos, '💦', 12);
  }

  // ─── Characters ───────────────────────────────────────────────────────────
  void _drawCharacters(Canvas canvas) {
    final sorted = List<Character>.from(gs.characters)
      ..sort((a, b) =>
          IsoMath.depthKey(a.gx, a.gy).compareTo(IsoMath.depthKey(b.gx, b.gy)));

    for (final c in sorted) {
      _drawCharacter(canvas, c);
    }
  }

  void _drawCharacter(Canvas canvas, Character c) {
    final pos = IsoMath.gridToScreen(c.gx, c.gy);
    final bounce = c.isMoving ? sin(c.walkCycle) * 2.0 : 0.0;
    final charPos = pos.translate(0, -20 + bounce);

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawOval(
      Rect.fromCenter(center: pos, width: 16, height: 6),
      shadowPaint,
    );

    // VIP glow
    if (c.isVip) {
      final vipGlow = Paint()
        ..color = const Color(0x88FFD700)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(charPos, 12, vipGlow);
    }

    // Character body by type
    final emoji = _emojiForCharacter(c);
    final size = c.type == CharacterType.guest ? 22.0 : 20.0;
    _drawEmoji(canvas, charPos, emoji, size);

    // Patience bar for guests
    if (c.isGuest && c.patience < 25) {
      final fraction = (c.patience / 40.0).clamp(0.0, 1.0);
      final pColor = Color.lerp(
          Colors.red, const Color(0xFF4CAF50), fraction)!;
      _drawProgressBar(
          canvas, charPos.translate(0, 14), fraction, color: pColor);
    }

    // State indicator bubble
    final indicator = _indicatorForState(c.state);
    if (indicator != null) {
      _drawBubble(canvas, charPos.translate(10, -12), indicator);
    }
  }

  String _emojiForCharacter(Character c) {
    if (c.isVip && c.type == CharacterType.guest) return '🤴';
    switch (c.type) {
      case CharacterType.guest:
        return ['👨‍💼', '👩‍💼', '👨‍👩‍👦', '👴', '👩‍🦰'][c.id.hashCode.abs() % 5];
      case CharacterType.receptionist:
        return '💁';
      case CharacterType.chef:
        return '👨‍🍳';
      case CharacterType.waiter:
        return '🤵';
      case CharacterType.maid:
        return '🧹';
      // ignore: unreachable_switch_default
      default:
        return '🧑';
    }
  }

  String? _indicatorForState(CharacterState state) {
    switch (state) {
      case CharacterState.queuingAtReception:
      case CharacterState.checkingIn:
        return '💬';
      case CharacterState.eating:
      case CharacterState.seated:
        return '🍽';
      case CharacterState.inRoom:
        return '😴';
      case CharacterState.cooking:
        return '🔥';
      case CharacterState.cleaning:
        return '🧹';
      case CharacterState.carryingFood:
        return '🍱';
      default:
        return null;
    }
  }

  void _drawBubble(Canvas canvas, Offset pos, String emoji) {
    final bgPaint = Paint()..color = Colors.white.withValues(alpha: 0.9);
    canvas.drawCircle(pos, 9, bgPaint);
    _drawEmoji(canvas, pos, emoji, 10);
  }

  // ─── Particles ────────────────────────────────────────────────────────────
  void _drawParticles(Canvas canvas) {
    // Particles are in screen space already — drawn before restore()
    // But since they're positioned using _gridToViewport which already applies
    // camera transform, we need to inverse here.
    // Instead, draw them after canvas.restore() directly.
    // We handle this by drawing them separately in _drawFloatingLabels.
  }

  // ─── Floating labels (screen space) ──────────────────────────────────────
  void _drawFloatingLabels(Canvas canvas) {
    // Floating cash labels
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
              color: Colors.black.withValues(alpha: l.opacity * 0.5),
              offset: const Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      );
      tp.layout();
      tp.paint(canvas, l.screenPos.translate(-tp.width / 2, -tp.height / 2));
    }

    // Particles
    for (final p in gs.particles) {
      final paint = Paint()
        ..color = p.color.withValues(alpha: p.life)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(p.pos, p.size * p.life, paint);
    }
  }

  // ─── Drawing helpers ──────────────────────────────────────────────────────

  /// Draw an isometric box (top face + left face + right face).
  void _drawIsoBox(Canvas canvas, Offset topCenter, double w, double h,
      double depth, Color color) {
    // Top face
    final topPaint = Paint()..color = color;
    final leftPaint = Paint()..color = Color.lerp(color, Colors.black, 0.25)!;
    final rightPaint = Paint()..color = Color.lerp(color, Colors.black, 0.40)!;

    final tl = topCenter.translate(-w / 2, 0);
    final tr = topCenter.translate(w / 2, 0);
    final tc = topCenter.translate(0, -h / 2);
    final bc = topCenter.translate(0, h / 2);

    // Top face (diamond)
    final topPath = Path()
      ..moveTo(tc.dx, tc.dy)
      ..lineTo(tr.dx, tr.dy)
      ..lineTo(bc.dx, bc.dy)
      ..lineTo(tl.dx, tl.dy)
      ..close();
    canvas.drawPath(topPath, topPaint);

    // Left face
    final leftPath = Path()
      ..moveTo(tl.dx, tl.dy)
      ..lineTo(bc.dx, bc.dy)
      ..lineTo(bc.dx, bc.dy + depth)
      ..lineTo(tl.dx, tl.dy + depth)
      ..close();
    canvas.drawPath(leftPath, leftPaint);

    // Right face
    final rightPath = Path()
      ..moveTo(tr.dx, tr.dy)
      ..lineTo(bc.dx, bc.dy)
      ..lineTo(bc.dx, bc.dy + depth)
      ..lineTo(tr.dx, tr.dy + depth)
      ..close();
    canvas.drawPath(rightPath, rightPaint);

    // Edge highlights
    final edgePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawPath(topPath, edgePaint);
  }

  void _drawEmoji(Canvas canvas, Offset pos, String emoji, double size) {
    final tp = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(fontSize: size, height: 1.0),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, pos.translate(-tp.width / 2, -tp.height / 2));
  }

  void _drawLevelBadge(Canvas canvas, Offset pos, int level) {
    final bgPaint = Paint()..color = const Color(0xFFFF9800);
    canvas.drawCircle(pos, 8, bgPaint);

    final tp = TextPainter(
      text: TextSpan(
        text: '$level',
        style: const TextStyle(
          fontSize: 9,
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
