import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../logic/game_state.dart';

/// Modal dialog for the Golden Piggy Bank matching Play Store design.
class PiggyBankModal extends StatelessWidget {
  const PiggyBankModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gs, _) {
        final balance = gs.piggyBankBalance;
        final cap = GameState.piggyBankCap;
        final progress = (balance / cap).clamp(0.0, 1.0);
        final isFull = gs.isPiggyBankFull;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 380),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E1906), Color(0xFF140D07)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFFFD54F), width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB300).withValues(alpha: 0.35),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Top Header with Close ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 12, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Text('👑 ', style: TextStyle(fontSize: 20)),
                          Text(
                            'GOLDEN PIGGY BANK',
                            style: TextStyle(
                              color: Color(0xFFFFD54F),
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white70),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                const Divider(color: Color(0x33FFD54F), height: 1),

                // ── Piggy Illustration & Shine ─────────────────────────────────
                const SizedBox(height: 18),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFFE082).withValues(alpha: 0.4),
                        const Color(0xFFFFB300).withValues(alpha: 0.05),
                      ],
                    ),
                    border: Border.all(color: const Color(0xFFFFCA28), width: 2),
                  ),
                  child: const Center(
                    child: Text('🐷', style: TextStyle(fontSize: 64)),
                  ),
                ),

                const SizedBox(height: 14),

                // ── Current Balance Counter ────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('💎 ', style: TextStyle(fontSize: 24)),
                    Text(
                      '$balance',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      ' / $cap',
                      style: const TextStyle(
                        color: Color(0xFFFFD54F),
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                if (isFull)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '⚡ PIGGY BANK FULL! SMASH NOW!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),

                const SizedBox(height: 14),

                // ── Progress Bar ───────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Container(
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F0A06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF5D4037)),
                    ),
                    child: Stack(
                      children: [
                        FractionallySizedBox(
                          widthFactor: progress,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFB300), Color(0xFFFFD54F)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            '${(progress * 100).toInt()}%',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ── Description Info Card ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: const Text(
                      'Every station upgrade and completed diner meal order deposits +1 💎 into your Piggy Bank!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFD7CCC8),
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Smash Open Action Button ───────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: balance > 0
                            ? const Color(0xFF10B981)
                            : const Color(0xFF424242),
                        foregroundColor: Colors.white,
                        elevation: balance > 0 ? 6 : 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: balance > 0
                          ? () {
                              HapticFeedback.heavyImpact();
                              final claimed = gs.smashPiggyBank();
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: const Color(0xFF10B981),
                                  content: Text(
                                    '🎉 Smashed Piggy Bank! Claimed +$claimed Diamonds! 💎',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          : null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🔨 ', style: TextStyle(fontSize: 20)),
                          Text(
                            balance > 0 ? 'SMASH OPEN (+$balance 💎)' : 'PIGGY BANK EMPTY',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
