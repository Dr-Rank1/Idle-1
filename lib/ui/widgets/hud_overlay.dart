import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../logic/game_state.dart';

final _fmt = NumberFormat.compactCurrency(symbol: '\$', decimalDigits: 0);

/// Top HUD bar: cash, hotel name, VIP event banner.
class HudOverlay extends StatelessWidget {
  final VoidCallback onManagersTap;
  final VoidCallback onStatsTap;

  const HudOverlay({
    super.key,
    required this.onManagersTap,
    required this.onStatsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gs, _) {
        return SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Row(
                  children: [
                    // Cash pill
                    _CashPill(cash: gs.cash),
                    const Spacer(),
                    // Hotel name
                    Flexible(
                      child: Text(
                        gs.hotelName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 4,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    // Buttons
                    _HudButton(
                        emoji: '⭐',
                        label: 'Staff',
                        onTap: onManagersTap),
                    const SizedBox(width: 6),
                    _HudButton(
                        emoji: '📊',
                        label: 'Stats',
                        onTap: onStatsTap),
                  ],
                ),
              ),

              // VIP event banner
              if (gs.vipActive) ...[
                const SizedBox(height: 8),
                _VipBanner(timer: gs.vipTimer),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _CashPill extends StatelessWidget {
  final double cash;
  const _CashPill({required this.cash});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('💵', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 5),
          Text(
            _fmt.format(cash),
            style: const TextStyle(
              color: Color(0xFF69F0AE),
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _HudButton extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;

  const _HudButton(
      {required this.emoji, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            Text(label,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 9,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _VipBanner extends StatelessWidget {
  final double timer;
  const _VipBanner({required this.timer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFF9800)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.5),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('👑 VIP EVENT!  ×3 REVENUE  ',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                color: Colors.white,
                letterSpacing: 0.5,
              )),
          Text('${timer.toInt()}s',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: Colors.white,
              )),
        ],
      ),
    );
  }
}

/// Offline earnings dialog — shown on resume after save.
class OfflineEarningsDialog extends StatelessWidget {
  final double earnings;
  final VoidCallback onClaim;

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
            const Text('Welcome Back!',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(
              'Your resort earned while you were away:',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.5)),
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onClaim,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 8,
                  shadowColor:
                      const Color(0xFF4CAF50).withValues(alpha: 0.5),
                ),
                child: const Text('✅ Claim Earnings',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16)),
              ),
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
        final guestCount =
            gs.characters.where((c) => c.isGuest).length;
        final staffCount =
            gs.characters.where((c) => c.isStaff).length;
        final assignedManagers =
            gs.managers.where((m) => m.isAssigned).length;

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
                  const Text('📊 Resort Stats',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16)),
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
              _statRow('🏨 Hotel', gs.hotelName),
              if (gs.vipActive)
                _statRow('👑 VIP Multiplier', '×${gs.revenueMultiplier.toStringAsFixed(0)}'),
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
          Text(label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13)),
        ],
      ),
    );
  }
}
