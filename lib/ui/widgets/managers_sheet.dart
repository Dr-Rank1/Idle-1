import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../logic/game_state.dart';
import '../../models/manager.dart';
import '../../models/enums.dart';

final _fmt = NumberFormat.compactCurrency(symbol: '\$', decimalDigits: 0);

class ManagersSheet extends StatelessWidget {
  const ManagersSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gs, _) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.72,
          decoration: BoxDecoration(
            color: const Color(0xFF0D0D2B),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            children: [
              // Handle
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text('⭐ Staff Managers',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        )),
                  ],
                ),
              ),

              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Hire specialists to turbocharge your resort.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Manager cards grid
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: gs.managers.length,
                  itemBuilder: (context, i) {
                    return _ManagerCard(
                        manager: gs.managers[i], gs: gs);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ManagerCard extends StatelessWidget {
  final Manager manager;
  final GameState gs;

  const _ManagerCard({required this.manager, required this.gs});

  @override
  Widget build(BuildContext context) {
    final cost = gs.managerRecruitCostFor(manager.rarity);
    final canAfford = gs.cash >= cost;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            manager.rarityColor.withValues(alpha: 0.15),
            manager.rarityColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: manager.isUnlocked
              ? manager.rarityColor.withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.08),
          width: manager.isUnlocked ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Emoji avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: manager.rarityColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: manager.rarityColor.withValues(alpha: 0.4)),
              ),
              child: Center(
                child: Text(manager.emoji,
                    style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(manager.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          )),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: manager.rarityColor.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(manager.rarityLabel,
                            style: TextStyle(
                              color: manager.rarityColor,
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(manager.description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 11,
                      )),
                  const SizedBox(height: 6),
                  // Boost chips
                  Wrap(
                    spacing: 4,
                    children: [
                      if (manager.incomeBoost > 1.0)
                        _boostChip(
                            '💰 ×${manager.incomeBoost.toStringAsFixed(1)}',
                            const Color(0xFF4CAF50)),
                      if (manager.speedBoost > 1.0)
                        _boostChip(
                            '⚡ ×${manager.speedBoost.toStringAsFixed(1)}',
                            const Color(0xFF2196F3)),
                      if (manager.guestBoost > 1.0)
                        _boostChip(
                            '😊 ×${manager.guestBoost.toStringAsFixed(1)}',
                            const Color(0xFFFF9800)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Action
            if (manager.isUnlocked)
              Column(
                children: [
                  const Icon(Icons.check_circle,
                      color: Color(0xFF4CAF50), size: 20),
                  const SizedBox(height: 4),
                  if (!manager.isAssigned)
                    GestureDetector(
                      onTap: () => gs.assignManager(manager.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: const Color(0xFF4CAF50)
                                  .withValues(alpha: 0.5)),
                        ),
                        child: const Text('Assign',
                            style: TextStyle(
                                color: Color(0xFF4CAF50),
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ),
                    )
                  else
                    const Text('Active',
                        style: TextStyle(
                            color: Color(0xFF4CAF50),
                            fontSize: 10,
                            fontWeight: FontWeight.w600)),
                ],
              )
            else
              GestureDetector(
                onTap: canAfford
                    ? () {
                        gs.recruitManager(manager.id);
                      }
                    : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: canAfford
                        ? manager.rarityColor.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: canAfford
                          ? manager.rarityColor.withValues(alpha: 0.7)
                          : Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text('🔒 Hire',
                          style: TextStyle(
                            color: canAfford
                                ? Colors.white
                                : Colors.white38,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          )),
                      const SizedBox(height: 2),
                      Text(_fmt.format(cost),
                          style: TextStyle(
                            color: canAfford
                                ? manager.rarityColor
                                : Colors.white24,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          )),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _boostChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(text,
          style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w700)),
    );
  }
}

// Public accessor extension
extension GameStateManagerExt on GameState {
  double managerRecruitCostFor(ManagerRarity r) {
    switch (r) {
      case ManagerRarity.common:
        return 500;
      case ManagerRarity.rare:
        return 2000;
      case ManagerRarity.epic:
        return 8000;
      case ManagerRarity.legendary:
        return 25000;
    }
  }
}
