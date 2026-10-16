import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../logic/game_state.dart';

final _fmt = NumberFormat.compactCurrency(symbol: '\$', decimalDigits: 0);

/// Tycoon HUD Overlay matching reference video & screenshot HUD
class HudOverlay extends StatefulWidget {
  final VoidCallback onManagersTap;
  final VoidCallback onStatsTap;
  final VoidCallback? onWorldMapTap;
  final VoidCallback? onShopTap;
  final VoidCallback? onBoostTap;
  final VoidCallback? onPiggyBankTap;
  final VoidCallback? onRecipeBookTap;

  const HudOverlay({
    super.key,
    required this.onManagersTap,
    required this.onStatsTap,
    this.onWorldMapTap,
    this.onShopTap,
    this.onBoostTap,
    this.onPiggyBankTap,
    this.onRecipeBookTap,
  });

  @override
  State<HudOverlay> createState() => _HudOverlayState();
}

class _HudOverlayState extends State<HudOverlay> {
  bool _ribbonsExpanded = true;
  Timer? _clockTimer;
  DateTime _gameClock = DateTime(2026, 10, 14, 8, 34);

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted) {
        setState(() {
          _gameClock = _gameClock.add(const Duration(minutes: 1));
        });
      }
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gs, _) {
        final timeStr = DateFormat('hh:mm a').format(_gameClock);

        return SafeArea(
          child: Stack(
            children: [
              // ── 1. Top Milestone Star Bar & Status Cluster ─────────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Full-width dark grey progress bar across the very top edge with 5 silver stars
                  GestureDetector(
                    onTap: widget.onRecipeBookTap,
                    child: _TopMilestoneStarBar(
                      progress: (gs.starRating / 5.0).clamp(0.0, 1.0),
                      starRating: gs.starRating,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Top-left status cluster
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          // Manager avatar in purple border with level badge
                          _ManagerAvatarBadge(level: gs.restaurantLevel),
                          const SizedBox(width: 8),

                          // Green cash total + /s rate
                          _CashPanel(cash: gs.cash, ratePerSec: gs.cashPerSecond),
                          const SizedBox(width: 8),

                          // Lightning energy counter
                          _EnergyPill(energy: 833, maxEnergy: 880),
                          const SizedBox(width: 8),

                          // Gem counter
                          _GemPill(gems: gs.gems),
                          const SizedBox(width: 8),

                          // Digital clock
                          _ClockPill(time: timeStr),
                          const SizedBox(width: 8),

                          // Green "Live" pill
                          _LivePill(),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Collapsible red/green status ribbons below top-left cluster
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: GestureDetector(
                      onTap: () => setState(() => _ribbonsExpanded = !_ribbonsExpanded),
                      child: AnimatedCrossFade(
                        duration: const Duration(milliseconds: 200),
                        crossFadeState: _ribbonsExpanded
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        firstChild: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Builder(
                              builder: (context) {
                                final b = gs.getSectorBottleneckStatus();
                                final col = b['color'] as Color;
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 3),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E2430).withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border(left: BorderSide(color: col, width: 3)),
                                  ),
                                  child: Text(
                                    '${b['icon']} ${b['text']}',
                                    style: TextStyle(
                                      color: col,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const _StatusRibbon(
                              text: '📉 - 50 Marketing',
                              isPositive: false,
                            ),
                            const SizedBox(height: 3),
                            const _StatusRibbon(
                              text: '📈 + 25,830 Parking',
                              isPositive: true,
                            ),
                            const SizedBox(height: 3),
                            const _StatusRibbon(
                              text: '🧹 - 300 Cleaning',
                              isPositive: false,
                            ),
                          ],
                        ),
                        secondChild: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            '📊 Status Ribbons ▼',
                            style: TextStyle(color: Colors.white70, fontSize: 10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ── 2. Floating Action Buttons ─────────────────────────────────────
              // Bottom-left: circular orange shopping cart button
              Positioned(
                left: 16,
                bottom: 16,
                child: _CircleOrangeButton(
                  emoji: '🛒',
                  size: 52,
                  onTap: widget.onShopTap ??
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🛒 Tycoon Superstore opening...'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                ),
              ),

              // Bottom-center: white rounded pill button with orange play triangle and green "x2 BOOST!" text
              Positioned(
                left: 0,
                right: 0,
                bottom: 16,
                child: Center(
                  child: _FloatingBoostPill(
                    isBoosted: gs.vipActive,
                    timer: gs.vipTimer,
                    onTap: widget.onBoostTap ??
                        () {
                          gs.triggerVipEvent();
                        },
                  ),
                ),
              ),

              // Right edge: vertical column of circular buttons
              Positioned(
                right: 12,
                top: 90,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Golden Piggy Bank
                    _PiggyBankButton(
                      balance: gs.piggyBankBalance,
                      cap: GameState.piggyBankCap,
                      onTap: widget.onPiggyBankTap,
                    ),
                    const SizedBox(height: 10),

                    // 5-Star Recipe Book
                    _CircleOrangeButton(
                      emoji: '📖',
                      onTap: widget.onRecipeBookTap ?? () {},
                    ),
                    const SizedBox(height: 8),

                    // World Map
                    _CircleOrangeButton(
                      emoji: '🌍',
                      onTap: widget.onWorldMapTap ??
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('🌍 World Restaurant Empire Map'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                    ),
                    const SizedBox(height: 8),
                    // TV Ad
                    _CircleOrangeButton(
                      emoji: '📺',
                      onTap: () {
                        gs.triggerVipEvent();
                      },
                    ),
                    const SizedBox(height: 8),
                    // Settings Gear
                    _CircleOrangeButton(
                      emoji: '⚙️',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('⚙️ Diner Settings'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    // Lightbulb (Quests / Tips)
                    _CircleOrangeButton(
                      emoji: '💡',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('💡 Chef Tips & Objectives'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    // Bar Chart
                    _CircleOrangeButton(
                      emoji: '📊',
                      onTap: widget.onStatsTap,
                    ),
                    const SizedBox(height: 8),
                    // Staff / Build
                    _CircleOrangeButton(
                      emoji: '🔨',
                      onTap: widget.onManagersTap,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Top Milestone Star Bar ────────────────────────────────────────────────────
class _TopMilestoneStarBar extends StatelessWidget {
  final double progress;
  final num starRating;

  const _TopMilestoneStarBar({
    required this.progress,
    this.starRating = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 22,
      decoration: const BoxDecoration(
        color: Color(0xFF1E2430),
        border: Border(
          bottom: BorderSide(color: Color(0xFF12161F), width: 1.5),
        ),
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Blue progress bar fill
          FractionallySizedBox(
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF29B6F6), Color(0xFF0288D1)],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          // 5 silver/gold milestone stars
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(5, (index) {
              final active = (index + 1) <= starRating;
              final label = index == 4 ? '★ Grand Diner' : '★ Star ${index + 1}';
              return _StarItem(label: label, isActive: active);
            }),
          ),
        ],
      ),
    );
  }
}

class _StarItem extends StatelessWidget {
  final String label;
  final bool isActive;

  const _StarItem({required this.label, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: isActive ? const Color(0xFFFFD54F) : const Color(0xFFD6DBE5),
        fontWeight: FontWeight.w700,
        fontSize: 10,
        shadows: const [
          Shadow(color: Colors.black87, blurRadius: 3),
        ],
      ),
    );
  }
}

// ── Top-Left Cluster Components ──────────────────────────────────────────────
class _ManagerAvatarBadge extends StatelessWidget {
  final int level;

  const _ManagerAvatarBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1544),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFB854F6), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66B854F6),
            blurRadius: 6,
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('👩‍🍳', style: TextStyle(fontSize: 16, height: 1.1)),
            Text(
              'Lv. $level',
              style: const TextStyle(
                color: Color(0xFFFFE082),
                fontSize: 9,
                fontWeight: FontWeight.w800,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CashPanel extends StatelessWidget {
  final double cash;
  final double ratePerSec;

  const _CashPanel({required this.cash, required this.ratePerSec});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF132F20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00E676), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3300E676),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('💵', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _fmt.format(cash),
                style: const TextStyle(
                  color: Color(0xFF69F0AE),
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
              Text(
                '📈 +${_fmt.format(ratePerSec > 0 ? ratePerSec : 6220)}/s',
                style: const TextStyle(
                  color: Color(0xFFA7F3D0),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EnergyPill extends StatelessWidget {
  final int energy;
  final int maxEnergy;

  const _EnergyPill({required this.energy, required this.maxEnergy});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF102438),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF40C4FF), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3340C4FF),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⚡', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            '$energy/$maxEnergy',
            style: const TextStyle(
              color: Color(0xFFB3E5FC),
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: const Color(0xFF0091EA),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.add, size: 11, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _GemPill extends StatelessWidget {
  final int gems;

  const _GemPill({required this.gems});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2A153A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCE93D8), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33CE93D8),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('💎', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            NumberFormat('#,###').format(gems),
            style: const TextStyle(
              color: Color(0xFFF3E5F5),
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: const Color(0xFFAB47BC),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.add, size: 11, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _ClockPill extends StatelessWidget {
  final String time;

  const _ClockPill({required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF181E28),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF5A6678), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🕒', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            time,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _LivePill extends StatelessWidget {
  const _LivePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF10281C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF00E676), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            '●',
            style: TextStyle(
              color: Color(0xFF00E676),
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(width: 4),
          Text(
            'Live',
            style: TextStyle(
              color: Color(0xFFD7FFE7),
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Collapsible Status Ribbon ────────────────────────────────────────────────
class _StatusRibbon extends StatelessWidget {
  final String text;
  final bool isPositive;

  const _StatusRibbon({required this.text, required this.isPositive});

  @override
  Widget build(BuildContext context) {
    final bg = isPositive ? const Color(0xFF155427) : const Color(0xFF6B1818);
    final border = isPositive ? const Color(0xFF00E676) : const Color(0xFFFF5252);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border(left: BorderSide(color: border, width: 3)),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 4),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isPositive ? const Color(0xFFB9F6CA) : const Color(0xFFFFCDD2),
          fontWeight: FontWeight.w800,
          fontSize: 10,
        ),
      ),
    );
  }
}

// ── Circular Orange Action Button ────────────────────────────────────────────
class _CircleOrangeButton extends StatelessWidget {
  final String emoji;
  final VoidCallback onTap;
  final double size;

  const _CircleOrangeButton({
    required this.emoji,
    required this.onTap,
    this.size = 46,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFA726), Color(0xFFF57C00)],
          ),
          border: Border.all(color: const Color(0xFFFFE082), width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            emoji,
            style: TextStyle(fontSize: size * 0.44),
          ),
        ),
      ),
    );
  }
}

// ── Golden Piggy Bank Button ────────────────────────────────────────────────
class _PiggyBankButton extends StatelessWidget {
  final int balance;
  final int cap;
  final VoidCallback? onTap;

  const _PiggyBankButton({
    required this.balance,
    required this.cap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
              ),
              border: Border.all(color: const Color(0xFFFFF9C4), width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '🐷',
                style: TextStyle(fontSize: 22),
              ),
            ),
          ),
          Positioned(
            bottom: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1220),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFD54F), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('💎', style: TextStyle(fontSize: 8)),
                  const SizedBox(width: 2),
                  Text(
                    '$balance',
                    style: const TextStyle(
                      color: Color(0xFFFFD54F),
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Floating White Boost Pill ────────────────────────────────────────────────
class _FloatingBoostPill extends StatelessWidget {
  final bool isBoosted;
  final double timer;
  final VoidCallback onTap;

  const _FloatingBoostPill({
    required this.isBoosted,
    required this.timer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFFFF8F00),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow, color: Colors.white, size: 14),
            ),
            const SizedBox(width: 8),
            Text(
              isBoosted ? '🔥 ACTIVE (${timer.toInt()}s)' : 'x2 BOOST!',
              style: const TextStyle(
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Welcome Back Modal (offline earnings) matching Godot's WelcomeBackModal
class WelcomeBackModal extends StatelessWidget {
  final double earnings;
  final void Function(double multiplier) onClaim;

  const WelcomeBackModal({
    super.key,
    required this.earnings,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        decoration: BoxDecoration(
          color: const Color(0xFF181C28),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF5B025), width: 2.5),
          boxShadow: const [
            BoxShadow(
              color: Colors.black87,
              blurRadius: 28,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Orange-to-Golden-Yellow Gradient Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE65100), Color(0xFFFFA000), Color(0xFFFFD54F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(17)),
              ),
              child: Column(
                children: const [
                  Text(
                    '✨ WELCOME BACK, CHEF! ✨',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 1)),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Your diner staff kept cooking while you were away!',
                    style: TextStyle(
                      color: Color(0xFFFFF8E1),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Red / Green status income & expense pills
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 6,
                    children: const [
                      _StatusRibbon(text: '📈 + 85% Offline Earnings', isPositive: true),
                      _StatusRibbon(text: '🕒 Max 8h Capped', isPositive: true),
                      _StatusRibbon(text: '📉 - 0 Idle Penalties', isPositive: false),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Big Currency Vault Card with emerald formatting
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1E16),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF00E676), width: 1.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x3300E676),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'TOTAL OFFLINE EARNINGS',
                          style: TextStyle(
                            color: Color(0xFFA7F3D0),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '+${_fmt.format(earnings)}',
                          style: const TextStyle(
                            color: Color(0xFF00E676),
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Action Buttons: Collect (1X) & 2X Promo Boost
                  Row(
                    children: [
                      // Collect 1X
                      Expanded(
                        child: GestureDetector(
                          onTap: () => onClaim(1.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF4CAF50), width: 1.5),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x661B5E20),
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'COLLECT (1X)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 2X Promo Boost
                      Expanded(
                        child: GestureDetector(
                          onTap: () => onClaim(2.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFA000), Color(0xFFFF6F00)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x66FF6F00),
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                '⚡ 2X PROMO BOOST!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Backwards compatibility alias
typedef OfflineEarningsDialog = WelcomeBackModal;

/// Stats overlay panel.
class StatsPanel extends StatelessWidget {
  final VoidCallback onClose;

  const StatsPanel({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gs, _) {
        final guestCount = gs.characters.where((c) => c.isGuest).length;
        final staffCount = gs.characters.where((c) => c.isStaff).length;
        final assignedManagers = gs.managers.where((m) => m.isAssigned).length;

        return Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    '📊 Restaurant Stats',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onClose,
                    child: const Icon(Icons.close, color: Colors.white54, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Sector Bottleneck Status Pill
              Builder(
                builder: (context) {
                  final b = gs.getSectorBottleneckStatus();
                  final col = b['color'] as Color;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: col.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: col, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Text(b['icon'] as String, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'OPERATIONAL STATUS',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              b['text'] as String,
                              style: TextStyle(
                                color: col,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              _statRow('💵 Total Earned', _fmt.format(gs.totalEarned)),
              _statRow('👥 Guests On-Site', '$guestCount'),
              _statRow('👔 Staff Members', '$staffCount'),
              _statRow('⭐ Managers Active', '$assignedManagers'),
              _statRow('📈 Reputation', 'Level ${gs.reputation}'),
              _statRow('🏛️ Valuation', _fmt.format(gs.getRestaurantValuation())),
              _statRow(
                '👑 Franchise Prestige',
                'Lv. ${gs.prestigeLevel} (+${(gs.prestigeLevel * 50)}%)',
              ),
              _statRow('🔑 Golden Keys', '${gs.franchiseKeys} Keys'),
              _statRow('🏨 Restaurant', gs.hotelName),
              if (gs.vipActive)
                _statRow(
                  '👑 VIP Multiplier',
                  '×${gs.revenueMultiplier.toStringAsFixed(0)}',
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
