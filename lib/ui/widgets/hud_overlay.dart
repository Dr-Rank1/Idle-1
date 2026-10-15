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

  const HudOverlay({
    super.key,
    required this.onManagersTap,
    required this.onStatsTap,
    this.onWorldMapTap,
    this.onShopTap,
    this.onBoostTap,
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
                  _TopMilestoneStarBar(progress: 0.65),

                  const SizedBox(height: 6),

                  // Top-left status cluster
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          // Manager avatar in purple border with level badge
                          _ManagerAvatarBadge(level: 12),
                          const SizedBox(width: 8),

                          // Green cash total + /s rate
                          _CashPanel(cash: gs.cash, ratePerSec: gs.cashPerSecond),
                          const SizedBox(width: 8),

                          // Lightning energy counter
                          _EnergyPill(energy: 833, maxEnergy: 880),
                          const SizedBox(width: 8),

                          // Gem counter
                          _GemPill(gems: 20141),
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
                          children: const [
                            _StatusRibbon(
                              text: '📉 - 50 Marketing',
                              isPositive: false,
                            ),
                            SizedBox(height: 3),
                            _StatusRibbon(
                              text: '📈 + 25,830 Parking',
                              isPositive: true,
                            ),
                            SizedBox(height: 3),
                            _StatusRibbon(
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

  const _TopMilestoneStarBar({required this.progress});

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
                color: const Color(0xFF3DA3E8),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          // 5 silver milestone stars
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _StarItem(label: '★ Star 1'),
              _StarItem(label: '★ Star 2'),
              _StarItem(label: '★ Star 3'),
              _StarItem(label: '★ Star 4'),
              _StarItem(label: '★ Grand Diner'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StarItem extends StatelessWidget {
  final String label;

  const _StarItem({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFFD6DBE5),
        fontWeight: FontWeight.w700,
        fontSize: 10,
        shadows: [
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

/// Offline earnings dialog — shown on resume after save.
class OfflineEarningsDialog extends StatelessWidget {
  final double earnings;
  final void Function(double multiplier) onClaim;

  const OfflineEarningsDialog({
    super.key,
    required this.earnings,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1A237E),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 32,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌙', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            const Text(
              'Welcome Back!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your staff kept cooking while you were away\n(capped at 8h, 85% offline rate):',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                _fmt.format(earnings),
                style: const TextStyle(
                  color: Color(0xFF69F0AE),
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => onClaim(1.0),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 6,
                    ),
                    child: const Text(
                      'COLLECT (1X)',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => onClaim(2.0),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFA000),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 6,
                    ),
                    child: const Text(
                      '⚡ 2X PROMO BOOST!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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
              _statRow('💵 Total Earned', _fmt.format(gs.totalEarned)),
              _statRow('👥 Guests On-Site', '$guestCount'),
              _statRow('👔 Staff Members', '$staffCount'),
              _statRow('⭐ Managers Active', '$assignedManagers'),
              _statRow('📈 Reputation', 'Level ${gs.reputation}'),
              _statRow(
                '👑 Prestige Stars',
                '${gs.prestigeStars} ★ (+${(gs.prestigeStars * 25)}%)',
              ),
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
