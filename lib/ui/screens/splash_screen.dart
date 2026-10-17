import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../services/sprite_cache.dart';
import 'game_screen.dart';

/// Two-stage mobile startup sequence for Restaurant Tycoon 3D / Idle Diner:
/// Stage 1: "DR RANK" Studio Splash with scale-and-fade entrance, radial glow,
///          and specular light sheen sweep.
/// Stage 2: Mobile Game Loading Screen with vibrant sunburst bg, floating title,
///          chunky 3D-beveled golden loading bar, and pulsing "TAP TO START" button.
class DrRankSplashScreen extends StatefulWidget {
  const DrRankSplashScreen({super.key});

  @override
  State<DrRankSplashScreen> createState() => _DrRankSplashScreenState();
}

class _DrRankSplashScreenState extends State<DrRankSplashScreen>
    with TickerProviderStateMixin {
  // Stage 1 Controllers
  late final AnimationController _stage1Controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _sheenProgress;

  // Stage 2 Controllers
  late final AnimationController _crossFadeController;
  late final AnimationController _loadingController;
  late final AnimationController _floatController;
  late final AnimationController _pulseController;

  bool _isStage2 = false;
  bool _loadingComplete = false;
  bool _navigated = false;
  Timer? _fallbackTimer;

  static const List<String> _statusTexts = [
    'Prepping Kitchen Stoves...',
    'Polishing Mahogany Bar...',
    'Chilling Milkshakes...',
    'Opening Idle Diner...',
  ];

  @override
  void initState() {
    super.initState();
    SpriteCache.preload();

    // 1. Stage 1 — DR RANK Studio Logo animation (0.0s to 1.9s)
    _stage1Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    );

    // Elastic bounce scale (0.4 -> 1.08 -> 1.0)
    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.4, end: 1.08)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 65,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.08, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 35,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _stage1Controller,
        curve: const Interval(0.0, 0.45),
      ),
    );

    _logoOpacity = CurvedAnimation(
      parent: _stage1Controller,
      curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
    );

    // Additive light sheen sweep across emblem
    _sheenProgress = CurvedAnimation(
      parent: _stage1Controller,
      curve: const Interval(0.38, 0.72, curve: Curves.easeInOutQuad),
    );

    // 2. Cross-fade controller (Stage 1 -> Stage 2)
    _crossFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // 3. Stage 2 Loading bar (fills over 1.8s)
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _loadingController.addListener(() {
      if (mounted) setState(() {});
    });

    _loadingController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _loadingComplete = true;
        });
        _pulseController.repeat(reverse: true);
        // Auto-start fallback timer (1.5s)
        _fallbackTimer = Timer(const Duration(milliseconds: 1500), () {
          _navigateToGame();
        });
      }
    });

    // 4. Floating bobbing title animation
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    // 5. Button pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    // Sequence start
    _startStartupSequence();
  }

  void _startStartupSequence() async {
    await _stage1Controller.forward();
    if (!mounted) return;

    setState(() {
      _isStage2 = true;
    });
    await _crossFadeController.forward();
    if (!mounted) return;

    _loadingController.forward();
  }

  void _navigateToGame() {
    if (_navigated) return;
    _navigated = true;
    _fallbackTimer?.cancel();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const GameScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _stage1Controller.dispose();
    _crossFadeController.dispose();
    _loadingController.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1322),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (_isStage2 && _loadingComplete) {
            _navigateToGame();
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // STAGE 1: DR RANK Studio Splash
            if (!_isStage2 || _crossFadeController.value < 1.0)
              FadeTransition(
                opacity: Tween<double>(begin: 1.0, end: 0.0)
                    .animate(_crossFadeController),
                child: _buildStage1Studio(),
              ),

            // STAGE 2: IDLE DINER Loading Screen
            if (_isStage2)
              FadeTransition(
                opacity: _crossFadeController,
                child: _buildStage2Loading(),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Stage 1: DR RANK Studio Splash ──────────────────────────────────────
  Widget _buildStage1Studio() {
    return Container(
      color: const Color(0xFF0D1322),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Centered radial cyan/royal glow
          Container(
            width: 650,
            height: 650,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Color(0x661E88E5), // Vivid cyan/royal core
                  Color(0x280D47A1), // Mid deep blue
                  Color(0x000D1322), // Fades out to navy
                ],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),

          // Scaling & Fading Logo Emblem
          FadeTransition(
            opacity: _logoOpacity,
            child: ScaleTransition(
              scale: _logoScale,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Studio Logo image with vector fallback
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'restaurant_tycoon_3d/assets/textures/dr_rank_logo.png',
                      width: 290,
                      height: 290,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const _DrRankFallbackEmblem(),
                    ),
                  ),

                  // Additive Specular Light Sheen Sweep
                  AnimatedBuilder(
                    animation: _sheenProgress,
                    builder: (context, child) {
                      final progress = _sheenProgress.value;
                      if (progress <= 0.0 || progress >= 1.0) {
                        return const SizedBox.shrink();
                      }
                      final xOffset = -220.0 + progress * 440.0;
                      return Positioned(
                        left: 145.0 + xOffset - 40,
                        top: -40,
                        bottom: -40,
                        width: 80,
                        child: Transform.rotate(
                          angle: -25 * math.pi / 180,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0x00FFFFFF),
                                  Color(0xAAFFFFFF),
                                  Color(0x00FFFFFF),
                                ],
                                stops: [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Stage 2: IDLE DINER Loading Screen ──────────────────────────────────
  Widget _buildStage2Loading() {
    final progress = _loadingController.value;
    final pct = (progress * 100).toInt();
    final statusIdx = (progress < 0.25)
        ? 0
        : (progress < 0.55)
            ? 1
            : (progress < 0.85)
                ? 2
                : 3;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE65100), // Sunshine orange
            Color(0xFFBF360C), // Deep crimson amber
            Color(0xFF4A148C), // Midnight plum base
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Sunburst Rays
          CustomPaint(
            size: Size.infinite,
            painter: const _SunburstPainter(),
          ),

          // Central Column: Title Logo + Golden Loading Bar
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),

                // Floating Game Title Logo
                AnimatedBuilder(
                  animation: _floatController,
                  builder: (context, child) {
                    final floatY = math.sin(_floatController.value * math.pi) * 8.0;
                    return Transform.translate(
                      offset: Offset(0, -floatY),
                      child: child,
                    );
                  },
                  child: Image.asset(
                    'restaurant_tycoon_3d/assets/textures/idle_diner_title_logo.png',
                    width: 310,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const _IdleDinerTitleFallback(),
                  ),
                ),

                const Spacer(flex: 4),

                // Bottom Loading or TAP TO START Controls
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: !_loadingComplete
                      ? _buildGoldenLoadingBar(progress, pct, statusIdx)
                      : _buildTapToStartButton(),
                ),

                const SizedBox(height: 24),

                // Small Watermark
                Text(
                  'POWERED BY DR RANK',
                  style: TextStyle(
                    color: const Color(0xFFFFE082).withValues(alpha: 0.75),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    shadows: const [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Golden Loading Bar ──────────────────────────────────────────────────
  Widget _buildGoldenLoadingBar(double progress, int pct, int statusIdx) {
    return Container(
      width: 440,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF261408),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF3E2210),
          width: 3.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Dark track fill
            Container(color: const Color(0xFF1E0E05)),

            // Golden Progress Fill
            FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFFD54F), // Bright honey yellow
                      Color(0xFFFF8F00), // Rich amber gold
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Top glossy highlight strip
                    Positioned(
                      top: 3,
                      left: 6,
                      right: 6,
                      height: 14,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Centered Status Label
            Center(
              child: Text(
                '${_statusTexts[statusIdx]} $pct%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Color(0xFF1A0A02),
                      blurRadius: 6,
                      offset: Offset(0, 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Pulsing "TAP TO START" Button ───────────────────────────────────────
  Widget _buildTapToStartButton() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1.0 + _pulseController.value * 0.055;
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: _navigateToGame,
        child: Container(
          width: 280,
          height: 54,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF2ECC71), // Vivid emerald green
                Color(0xFF27AE60), // Deep green
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: const Border(
              top: BorderSide(color: Color(0xFF82E0AA), width: 2),
              left: BorderSide(color: Color(0xFF1E8449), width: 3),
              right: BorderSide(color: Color(0xFF1E8449), width: 3),
              bottom: BorderSide(color: Color(0xFF145A32), width: 6), // 3D bevel
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 12,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                SizedBox(width: 8),
                Text(
                  'TAP TO START',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        color: Color(0xFF0E3D1F),
                        blurRadius: 4,
                        offset: Offset(0, 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Sunburst Background Painter ───────────────────────────────────────────
class _SunburstPainter extends CustomPainter {
  const _SunburstPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.45);
    final radius = math.max(size.width, size.height) * 1.2;
    const rayCount = 28;
    const step = (2 * math.pi) / rayCount;

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.065)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < rayCount; i += 2) {
      final path = Path();
      path.moveTo(center.dx, center.dy);
      path.lineTo(
        center.dx + radius * math.cos(i * step),
        center.dy + radius * math.sin(i * step),
      );
      path.lineTo(
        center.dx + radius * math.cos((i + 1) * step),
        center.dy + radius * math.sin((i + 1) * step),
      );
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Fallback Widgets ──────────────────────────────────────────────────────
class _DrRankFallbackEmblem extends StatelessWidget {
  const _DrRankFallbackEmblem();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: 260,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF0F1E33)],
        ),
        border: Border.all(color: const Color(0xFFFFD700), width: 4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66FFD700),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.workspace_premium, color: Color(0xFFFFD700), size: 84),
          SizedBox(height: 8),
          Text(
            'DR RANK',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          Text(
            'GAMES STUDIO',
            style: TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
        ],
      ),
    );
  }
}

class _IdleDinerTitleFallback extends StatelessWidget {
  const _IdleDinerTitleFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFD84315),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFE082), width: 3),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'IDLE DINER',
            style: TextStyle(
              color: Color(0xFFFFE082),
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          Text(
            'RESTAURANT TYCOON',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
