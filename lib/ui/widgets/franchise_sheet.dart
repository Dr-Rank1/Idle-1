import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../logic/game_state.dart';
import '../../services/save_service.dart';

final _fmt = NumberFormat.compactCurrency(symbol: '\$', decimalDigits: 1);

class FranchiseSheet extends StatelessWidget {
  const FranchiseSheet({super.key});

  void _showPrestigeConfirmation(BuildContext context, GameState gs) {
    final keysReward = gs.keysToEarnOnPrestige;
    final diamondsReward = gs.diamondsToEarnOnPrestige;
    final nextMult = 1.0 + ((gs.prestigeLevel + 1) * 0.50);

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFF59E0B), width: 2),
          ),
          title: const Row(
            children: [
              Text('👑 ', style: TextStyle(fontSize: 22)),
              Expanded(
                child: Text(
                  'Sell & Renovate Diner?',
                  style: TextStyle(
                    color: Color(0xFFFDE68A),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Are you ready to sell this diner location and expand your franchise empire?',
                style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 13),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚠️ WHAT RESETS:',
                      style: TextStyle(
                        color: Color(0xFFF87171),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '• Cash resets to starting \$500 (+ prestige bonus)\n• Station levels reset back to Level 1',
                      style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '✨ PERMANENT PRESTIGE REWARDS:',
                      style: TextStyle(
                        color: Color(0xFF34D399),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• +$keysReward 🔑 Franchise Golden Keys\n'
                      '• +$diamondsReward 💎 Diamonds\n'
                      '• +50% Permanent Global Profit (New: ${nextMult.toStringAsFixed(1)}x)\n'
                      '• ALL Manager Cards & Shop Boosters KEPT!',
                      style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Keep Operating', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: const Color(0xFF1E1B4B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                gs.prestigeReset();
                SaveService.save(gs);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF10B981),
                    content: Text(
                      '👑 Franchise Prestige Lv. ${gs.prestigeLevel} Unlocked! +$keysReward Keys, +$diamondsReward Diamonds!',
                    ),
                  ),
                );
              },
              child: const Text('✨ CONFIRM PRESTIGE ✨', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gs, _) {
        final valuation = gs.getRestaurantValuation();
        final canP = gs.canPrestige;
        final keysReward = gs.keysToEarnOnPrestige;
        final diamondsReward = gs.diamondsToEarnOnPrestige;
        final pMult = gs.prestigeMultiplier;

        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: const Color(0xFF0D1322),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              // Handle
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Title Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Text('🌍', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Franchise World Map',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Expand across restaurant empire locations & prestige',
                            style: TextStyle(color: Colors.white54, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Scrollable Content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Franchise Prestige & Valuation Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E1B4B), Color(0xFF172554)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header stats
                          Row(
                            children: [
                              const Text('👑', style: TextStyle(fontSize: 22)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'VALUATION: ${_fmt.format(valuation)}',
                                  style: const TextStyle(
                                    color: Color(0xFFFDE68A),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '🔑 ${gs.franchiseKeys} Keys',
                                  style: const TextStyle(
                                    color: Color(0xFFFCD34D),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                '⭐ Prestige Level ${gs.prestigeLevel}',
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              const Spacer(),
                              Text(
                                '+${((pMult - 1.0) * 100).round()}% Global Profit',
                                style: const TextStyle(color: Color(0xFF34D399), fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: (valuation / 25000.0).clamp(0.0, 1.0),
                              backgroundColor: Colors.white.withValues(alpha: 0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                canP ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                              ),
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 8),

                          Text(
                            canP
                                ? '✨ Valuation threshold met! Ready to Sell & Renovate.'
                                : 'Target Valuation: \$25.0K • Reach \$25K or max level stations to Prestige.',
                            style: TextStyle(
                              color: canP ? const Color(0xFF6EE7B7) : Colors.white60,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Reward preview & action button
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Sale Rewards: +$keysReward 🔑  •  +$diamondsReward 💎  •  +50% Profit',
                                    style: const TextStyle(color: Color(0xFFFDE68A), fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          SizedBox(
                            width: double.infinity,
                            height: 40,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: canP ? const Color(0xFFF59E0B) : const Color(0xFF334155),
                                foregroundColor: canP ? const Color(0xFF1E1B4B) : Colors.white38,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: canP ? () => _showPrestigeConfirmation(context, gs) : null,
                              child: Text(
                                canP ? '⭐ SELL & RENOVATE (+$keysReward 🔑)' : '🔒 SELL & RENOVATE (REACH \$25K)',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Section: Franchise Locations
                    const Text(
                      '🌍 Empire Franchise Locations',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    ...gs.worldRestaurants.map((r) {
                      final isActive = r.id == gs.activeRestaurantId;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isActive ? const Color(0xFF10B981) : Colors.white.withValues(alpha: 0.08),
                            width: isActive ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(r.icon, style: const TextStyle(fontSize: 28)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        r.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '★' * r.stars,
                                        style: const TextStyle(color: Color(0xFFFCD34D), fontSize: 11),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    r.tagline,
                                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '⚡ ${r.multiplier.toStringAsFixed(1)}x Revenue Multiplier',
                                    style: const TextStyle(
                                      color: Color(0xFF34D399),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            if (isActive)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'ACTIVE',
                                  style: TextStyle(
                                    color: Color(0xFF34D399),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            else if (r.unlocked)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3B82F6),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () {
                                  gs.activeRestaurantId = r.id;
                                  gs.restaurantName = r.name;
                                  SaveService.save(gs);
                                },
                                child: const Text('SWITCH', style: TextStyle(fontSize: 11)),
                              )
                            else
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: gs.cash >= r.cost
                                      ? const Color(0xFFF59E0B)
                                      : const Color(0xFF334155),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: gs.cash >= r.cost
                                    ? () {
                                        gs.cash -= r.cost;
                                        r.unlocked = true;
                                        gs.activeRestaurantId = r.id;
                                        gs.restaurantName = r.name;
                                        SaveService.save(gs);
                                      }
                                    : null,
                                child: Text(
                                  'UNLOCK\n${_fmt.format(r.cost)}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 20),
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
