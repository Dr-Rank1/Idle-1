import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../logic/game_state.dart';
import '../../models/recipe.dart';

/// Modal dialog for the 5-Star Recipe Progression Book matching Play Store design.
class RecipeBookModal extends StatelessWidget {
  const RecipeBookModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gs, _) {
        final allTiers = defaultStarDishTiers.values.toList()
          ..sort((a, b) => a.star.compareTo(b.star));

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420, maxHeight: 600),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF161E30), Color(0xFF0D1220)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFF4A90E2), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E88E5).withValues(alpha: 0.35),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                // ── Header ───────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 12, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('⭐ ', style: TextStyle(fontSize: 22)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '5-STAR RECIPE BOOK',
                                style: TextStyle(
                                  color: Color(0xFFFFD54F),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              Text(
                                'Active Tier Multiplier: x${gs.activeRecipeMultiplier.toStringAsFixed(1)}',
                                style: const TextStyle(
                                  color: Color(0xFF81C784),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
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

                const Divider(color: Color(0x334A90E2), height: 1),

                // ── Recipe Cards List ─────────────────────────────────────────
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    itemCount: allTiers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final tier = allTiers[index];
                      final isUnlocked = gs.isStarDishUnlocked(tier.star);
                      final isClaimed = gs.isStarRewardClaimed(tier.star);

                      return _RecipeCard(
                        tier: tier,
                        isUnlocked: isUnlocked,
                        isClaimed: isClaimed,
                        onClaim: () {
                          HapticFeedback.mediumImpact();
                          final claimed = gs.claimStarDishReward(tier.star);
                          if (claimed) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: const Color(0xFF10B981),
                                content: Text(
                                  '🎉 Claimed Star ${tier.star} Recipe Reward: +25 Diamonds! 💎',
                                  style: const TextStyle(fontWeight: FontWeight.w800),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final StarDishTier tier;
  final bool isUnlocked;
  final bool isClaimed;
  final VoidCallback onClaim;

  const _RecipeCard({
    required this.tier,
    required this.isUnlocked,
    required this.isClaimed,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isUnlocked
            ? const Color(0xFF1A233A)
            : const Color(0xFF131826).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isUnlocked
              ? const Color(0xFFFFD54F).withValues(alpha: 0.7)
              : Colors.white.withValues(alpha: 0.08),
          width: isUnlocked ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Dish Icon Box
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? const Color(0xFF26324D)
                      : Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isUnlocked ? const Color(0xFFFFD54F) : Colors.white12,
                  ),
                ),
                child: Center(
                  child: Text(
                    tier.icon,
                    style: TextStyle(
                      fontSize: 26,
                      color: isUnlocked ? null : Colors.grey,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Title, Stars & Multiplier
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(
                        tier.star,
                        (_) => const Text('⭐', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tier.name,
                      style: TextStyle(
                        color: isUnlocked ? Colors.white : Colors.white54,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              // Multiplier badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? const Color(0xFF10B981).withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isUnlocked ? const Color(0xFF10B981) : Colors.white12,
                  ),
                ),
                child: Text(
                  'x${tier.multiplier.toStringAsFixed(1)}',
                  style: TextStyle(
                    color: isUnlocked ? const Color(0xFF34D399) : Colors.white38,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            tier.description,
            style: TextStyle(
              color: Colors.white.withValues(alpha: isUnlocked ? 0.7 : 0.4),
              fontSize: 11,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 10),

          // Bottom Bar: Price & Claim button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Base Price: \$${tier.price.toInt()}',
                style: TextStyle(
                  color: const Color(0xFFFFCA28).withValues(alpha: isUnlocked ? 0.9 : 0.4),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (!isUnlocked)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock, size: 12, color: Colors.white54),
                      const SizedBox(width: 4),
                      Text(
                        'Req Level ${tier.requiredLevel}',
                        style: const TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                )
              else if (isClaimed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '✓ CLAIMED',
                    style: TextStyle(
                      color: Color(0xFF9E9E9E),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: onClaim,
                    child: const Text(
                      'CLAIM +25 💎',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
