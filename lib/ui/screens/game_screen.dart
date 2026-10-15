import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../logic/game_state.dart';
import '../../models/station.dart';
import '../../services/save_service.dart';
import '../../ui/painters/resort_painter.dart';
import '../../ui/widgets/hud_overlay.dart';
import '../../ui/widgets/managers_sheet.dart';
import '../../ui/widgets/upgrade_sheet.dart';
import '../../utils/iso_math.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  late final AnimationController _ticker;
  double _lastTime = 0.0;
  double _gameTime = 0.0;

  bool _showStats = false;

  // Touch / gesture state
  Offset _lastFocalPoint = Offset.zero;
  double _baseZoom = 1.0;
  Timer? _autosaveTimer;
  late GameState _gameState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _gameState = context.read<GameState>();
  }

  @override
  void initState() {
    super.initState();

    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(days: 999),
    )..addListener(_onTick)..forward();

    // Load save & show offline earnings
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final gs = _gameState;
      await SaveService.load(gs);

      // Default camera centered on the resort
      if (!mounted) return;
      gs.cameraOffset = Offset(
        MediaQuery.of(context).size.width / 2,
        MediaQuery.of(context).size.height * 0.38,
      );
      gs.tick(0); // trigger a single notify

      if (gs.offlineEarnings > 0) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) _showOfflineDialog(gs);
      }
    });

    // Autosave every 30 seconds
    _autosaveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      SaveService.save(_gameState);
    });
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    _ticker.dispose();
    SaveService.save(_gameState);
    super.dispose();
  }

  void _onTick() {
    final gs = _gameState;
    final now = _ticker.value * (const Duration(days: 999).inMilliseconds / 1000);
    final dt = (now - _lastTime).clamp(0, 0.1).toDouble();
    _lastTime = now;
    _gameTime += dt;
    gs.tick(dt);
  }

  // ─── Station tap hit-testing ───────────────────────────────────────────────
  Station? _stationAtScreenPos(Offset screenPos, GameState gs) {
    // Convert screen pos to grid
    final local = (screenPos - gs.cameraOffset) / gs.cameraZoom;
    final grid = IsoMath.screenToGrid(local.dx, local.dy);

    Station? best;
    double bestDepth = -999;

    for (final s in gs.stations) {
      // Station occupies gx..gx+w, gy..gy+h
      if (grid.dx >= s.gx - 1.5 &&
          grid.dx <= s.gx + s.widthTiles + 0.5 &&
          grid.dy >= s.gy - 1.5 &&
          grid.dy <= s.gy + s.heightTiles + 0.5) {
        final depth = IsoMath.depthKey(s.gx, s.gy);
        if (depth > bestDepth) {
          bestDepth = depth;
          best = s;
        }
      }
    }
    return best;
  }

  void _onTapUp(TapUpDetails details, GameState gs) {
    HapticFeedback.lightImpact();
    final local = (details.localPosition - gs.cameraOffset) / gs.cameraZoom;
    final grid = IsoMath.screenToGrid(local.dx, local.dy);

    // 1. Try interactive rush action (tapping stoves to cook faster, maids to clean, guests to cheer up)
    final rushed = gs.rushActionAt(grid);
    if (rushed) {
      HapticFeedback.mediumImpact();
      return;
    }

    // 2. Hit-test station to open upgrade sheet
    final station = _stationAtScreenPos(details.localPosition, gs);
    if (station != null) {
      _showUpgradeSheet(station);
    } else {
      // 3. Tap on open ground: spawn quick sparkle particle
      gs.spawnTapParticle(details.localPosition);
    }
  }

  void _showUpgradeSheet(Station station) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => UpgradeSheet(station: station),
    );
  }

  void _showOfflineDialog(GameState gs) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => OfflineEarningsDialog(
        earnings: gs.offlineEarnings,
        onClaim: (mult) {
          gs.claimOfflineEarnings(mult);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gs, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF1A2744),
          body: Stack(
            children: [
              // ── Sky gradient background ──────────────────────────────────
              _buildSkyBackground(),

              // ── Isometric resort canvas ──────────────────────────────────
              Listener(
                onPointerSignal: (pointerSignal) {
                  if (pointerSignal is PointerScrollEvent) {
                    final zoomFactor = pointerSignal.scrollDelta.dy < 0 ? 1.1 : 0.9;
                    gs.zoomCamera(zoomFactor, pointerSignal.localPosition);
                  }
                },
                child: GestureDetector(
                  onTapUp: (d) => _onTapUp(d, gs),
                  onScaleStart: (d) {
                    _lastFocalPoint = d.focalPoint;
                    _baseZoom = gs.cameraZoom;
                  },
                  onScaleUpdate: (d) {
                    // Pan (handles touch drag, mouse drag, and pinch-drag)
                    final delta = d.focalPoint - _lastFocalPoint;
                    _lastFocalPoint = d.focalPoint;
                    gs.panCamera(delta);

                    // Multi-touch pinch zoom
                    if (d.scale != 1.0) {
                      final targetZoom = (_baseZoom * d.scale)
                          .clamp(GameState.minZoom, GameState.maxZoom);
                      gs.setZoom(targetZoom, d.localFocalPoint);
                    }
                  },
                  child: AnimatedBuilder(
                    animation: _ticker,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: ResortPainter(gs: gs, time: _gameTime),
                        size: Size.infinite,
                        child: const SizedBox.expand(),
                      );
                    },
                  ),
                ),
              ),

              // ── HUD ───────────────────────────────────────────────────────
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: HudOverlay(
                  onManagersTap: () => showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (_) => const ManagersSheet(),
                  ),
                  onStatsTap: () => setState(() => _showStats = !_showStats),
                ),
              ),

              // ── Stats panel ───────────────────────────────────────────────
              if (_showStats)
                Positioned(
                  top: 100,
                  right: 12,
                  child: StatsPanel(
                    onClose: () => setState(() => _showStats = false),
                  ),
                ),

              // ── Camera reset button ───────────────────────────────────────
              Positioned(
                bottom: 24,
                right: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _FabButton(
                      emoji: '🏠',
                      onTap: gs.resetCamera,
                      tooltip: 'Reset camera',
                    ),
                    const SizedBox(height: 8),
                    _FabButton(
                      emoji: '💾',
                      onTap: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await SaveService.save(gs);
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Game saved! ✅'),
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      tooltip: 'Save game',
                    ),
                  ],
                ),
              ),

              // ── Tap hint ──────────────────────────────────────────────────
              Positioned(
                bottom: 24,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '👆 Tap stations to upgrade',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkyBackground() {
    return AnimatedBuilder(
      animation: _ticker,
      builder: (context, _) {
        // Slowly cycle day/night sky
        final t = (_gameTime / 120.0) % 1.0;
        final skyColor = Color.lerp(
          const Color(0xFF0D1B4B), // night
          const Color(0xFF4A90D9), // day
          (t < 0.5 ? t * 2 : (1 - t) * 2),
        )!;
        final horizonColor = Color.lerp(
          const Color(0xFF1A2744),
          const Color(0xFFF5A623),
          (t < 0.5 ? t * 2 : (1 - t) * 2) * 0.5,
        )!;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [skyColor, horizonColor, const Color(0xFF1A2744)],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
        );
      },
    );
  }
}

class _FabButton extends StatelessWidget {
  final String emoji;
  final VoidCallback onTap;
  final String tooltip;

  const _FabButton({
    required this.emoji,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
        ),
      ),
    );
  }
}
