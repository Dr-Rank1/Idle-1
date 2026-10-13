import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../logic/game_state.dart';
import '../../models/station.dart';
import '../../models/enums.dart';

final _fmt = NumberFormat.compactCurrency(symbol: '\$', decimalDigits: 0);

class UpgradeSheet extends StatelessWidget {
  final Station station;

  const UpgradeSheet({super.key, required this.station});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gs, _) {
        final canAfford = gs.cash >= station.upgradeCost;
        final isMaxed = station.level >= station.maxLevel;
        final levelFraction = station.level / station.maxLevel;

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A237E).withValues(alpha: 0.97),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _zoneColor(station.zone).withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: _zoneColor(station.zone).withValues(alpha: 0.5)),
                    ),
                    child: Center(
                      child: Text(_zoneEmoji(station.zone),
                          style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(station.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            )),
                        Text('Level ${station.level} / ${station.maxLevel}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 13,
                            )),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9800).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: const Color(0xFFFF9800).withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      'Lv ${station.level}',
                      style: const TextStyle(
                        color: Color(0xFFFF9800),
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Level progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: levelFraction,
                  minHeight: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                      _zoneColor(station.zone)),
                ),
              ),

              const SizedBox(height: 20),

              // Stats grid
              Row(
                children: [
                  _statCard('💰 Income', _fmt.format(station.income),
                      'per guest'),
                  const SizedBox(width: 10),
                  _statCard('⚡ Speed',
                      '${station.actionDuration.toStringAsFixed(1)}s',
                      'per action'),
                  const SizedBox(width: 10),
                  _statCard('📈 Boost',
                      '${((station.incomeMultiplier - 1) * 100).toStringAsFixed(0)}%',
                      'manager bonus'),
                ],
              ),

              const SizedBox(height: 20),

              // Upgrade button
              if (!isMaxed) ...[
                Row(
                  children: [
                    Expanded(
                      child: _UpgradeButton(
                        cost: station.upgradeCost,
                        canAfford: canAfford,
                        onTap: () {
                          final success = gs.upgradeStation(station.id);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    '${station.name} upgraded to Level ${station.level}! ⭐'),
                                backgroundColor: const Color(0xFF4CAF50),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Not enough cash! 💸'),
                                backgroundColor: Colors.redAccent,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Your balance: ${_fmt.format(gs.cash)}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFFFF9800).withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🏆', style: TextStyle(fontSize: 20)),
                      SizedBox(width: 8),
                      Text('MAX LEVEL REACHED!',
                          style: TextStyle(
                            color: Color(0xFFFF9800),
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            letterSpacing: 1,
                          )),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _statCard(String label, String value, String sub) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5), fontSize: 10)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14)),
            Text(sub,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4), fontSize: 9)),
          ],
        ),
      ),
    );
  }

  Color _zoneColor(ZoneType zone) {
    switch (zone) {
      case ZoneType.reception:
        return const Color(0xFF42A5F5);
      case ZoneType.kitchen:
        return const Color(0xFFFF7043);
      case ZoneType.diningRoom:
        return const Color(0xFFEC407A);
      case ZoneType.hotelRoom:
        return const Color(0xFF7E57C2);
      default:
        return const Color(0xFF4CAF50);
    }
  }

  String _zoneEmoji(ZoneType zone) {
    switch (zone) {
      case ZoneType.reception:
        return '🛎';
      case ZoneType.kitchen:
        return '🍳';
      case ZoneType.diningRoom:
        return '🍽';
      case ZoneType.hotelRoom:
        return '🛏';
      default:
        return '⭐';
    }
  }
}

class _UpgradeButton extends StatelessWidget {
  final double cost;
  final bool canAfford;
  final VoidCallback onTap;

  const _UpgradeButton({
    required this.cost,
    required this.canAfford,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: canAfford
            ? const LinearGradient(
                colors: [Color(0xFF00C853), Color(0xFF69F0AE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: canAfford ? null : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        boxShadow: canAfford
            ? [
                BoxShadow(
                  color: const Color(0xFF00C853).withValues(alpha: 0.5),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canAfford ? onTap : null,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  canAfford ? '⬆️ UPGRADE' : '🔒 UPGRADE',
                  style: TextStyle(
                    color: canAfford ? Colors.white : Colors.white38,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _fmt.format(cost),
                    style: TextStyle(
                      color: canAfford ? Colors.white : Colors.white38,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
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
