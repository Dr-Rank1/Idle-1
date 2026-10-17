import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../logic/game_state.dart';
import '../../models/manager.dart';
import '../../models/enums.dart';
import '../../models/gear.dart';
import '../../models/sector_manager.dart';

final _fmt = NumberFormat.compactCurrency(symbol: '\$', decimalDigits: 0);

class ManagersSheet extends StatelessWidget {
  const ManagersSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gs, _) {
        final readyCount = gs.readyManagerSkillsCount;

        return DefaultTabController(
          length: 3,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.78,
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
                const SizedBox(height: 12),

                // Title & Activate All Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '⭐ Managers & Staff',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (readyCount > 0)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFB300),
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Text('⚡', style: TextStyle(fontSize: 14)),
                          label: Text(
                            'ACTIVATE ALL ($readyCount)',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
                          ),
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            final activated = gs.activateAllManagerSkills();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: const Color(0xFFFFB300),
                                content: Text(
                                  '⚡ Activated $activated Sector Manager Skills!',
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Tab Bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    indicator: BoxDecoration(
                      color: const Color(0xFF1E88E5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white54,
                    labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                    tabs: const [
                      Tab(text: '⚡ Sector Skills'),
                      Tab(text: '👥 Staff Roster'),
                      Tab(text: '🦺 Gear Wardrobe'),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    children: [
                      // ── Tab 1: Sector Skills ────────────────────────────────
                      ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: gs.sectorManagers.values.map((sm) {
                          return _SectorManagerCard(sectorManager: sm, gs: gs);
                        }).toList(),
                      ),

                      // ── Tab 2: Staff Roster ─────────────────────────────────
                      ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: gs.managers.length,
                        itemBuilder: (context, i) {
                          return _ManagerCard(manager: gs.managers[i], gs: gs);
                        },
                      ),

                      // ── Tab 3: Gear Wardrobe ────────────────────────────────
                      _GearWardrobeView(gs: gs),
                    ],
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

class _SectorManagerCard extends StatelessWidget {
  final SectorManager sectorManager;
  final GameState gs;

  const _SectorManagerCard({
    required this.sectorManager,
    required this.gs,
  });

  @override
  Widget build(BuildContext context) {
    final sm = sectorManager;
    final isActive = sm.isActive;
    final canActivate = sm.canActivate;
    final onCooldown = !isActive && sm.cooldownTimer > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF161E34),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActive
              ? const Color(0xFF10B981)
              : (canActivate ? const Color(0xFFFFB300) : Colors.white10),
          width: isActive || canActivate ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon Container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF232D48),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: sm.tierColor),
                ),
                child: Center(
                  child: Text(sm.skillIcon, style: const TextStyle(fontSize: 24)),
                ),
              ),

              const SizedBox(width: 12),

              // Manager info & zone
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          sm.managerName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: sm.tierColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: sm.tierColor, width: 0.8),
                          ),
                          child: Text(
                            sm.tierLabel,
                            style: TextStyle(
                              color: sm.tierColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sm.sectorName,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Action / Cooldown pill button
              if (isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF10B981)),
                  ),
                  child: Text(
                    'ACTIVE ${sm.activeTimer.toInt()}s',
                    style: const TextStyle(
                      color: Color(0xFF34D399),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                )
              else if (onCooldown)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    '⏳ ${sm.cooldownTimer.toInt()}s',
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    gs.activateManagerSkill(sm.sectorId);
                  },
                  child: const Text(
                    '⚡ ACTIVATE',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          // Skill Name & Description
          Text(
            '${sm.skillName}: ${sm.skillDesc}',
            style: const TextStyle(
              color: Color(0xFFD1D5DB),
              fontSize: 11,
              height: 1.3,
            ),
          ),

          // Active / Cooldown Progress Bar
          if (isActive || onCooldown) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: isActive ? sm.activeProgress : sm.cooldownProgress,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isActive ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
                ),
                minHeight: 4,
              ),
            ),
          ],
        ],
      ),
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
        color: const Color(0xFF141432),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: manager.isAssigned
              ? manager.rarityColor.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: manager.rarityColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: manager.rarityColor.withValues(alpha: 0.4)),
              ),
              child: Center(
                child: Text(manager.emoji, style: const TextStyle(fontSize: 22)),
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
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          )),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: manager.rarityColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(manager.rarityLabel,
                            style: TextStyle(
                              color: manager.rarityColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    manager.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (manager.incomeBoost > 1.0)
                        _boostChip('+${((manager.incomeBoost - 1) * 100).toInt()}% \$',
                            const Color(0xFF4CAF50)),
                      if (manager.speedBoost > 1.0) ...[
                        const SizedBox(width: 6),
                        _boostChip('+${((manager.speedBoost - 1) * 100).toInt()}% Spd',
                            const Color(0xFF2196F3)),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Action
            if (manager.isUnlocked)
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
                      ),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFFFE082)),
                    ),
                    child: const Text(
                      '⭐ MAX LEVEL',
                      style: TextStyle(
                        color: Color(0xFF3E2723),
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
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

// ── Gear Wardrobe View ───────────────────────────────────────────────────────
class _GearWardrobeView extends StatelessWidget {
  final GameState gs;

  const _GearWardrobeView({required this.gs});

  @override
  Widget build(BuildContext context) {
    final headItem = gs.gearInventory[gs.equippedGear['head']];
    final bodyItem = gs.gearInventory[gs.equippedGear['body']];
    final toolItem = gs.gearInventory[gs.equippedGear['tool']];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        // ── Character Preview & Equipped Slots ──
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            children: [
              const Text(
                'HEAD CHEF & WAITER UNIFORM LOADOUT',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _EquippedSlotBox(
                    slotTitle: 'HEAD SLOT',
                    item: headItem,
                    fallbackIcon: '👨‍🍳',
                  ),
                  // Center Character Avatar Preview
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        headItem?.icon ?? '👨‍🍳',
                        style: const TextStyle(fontSize: 36),
                      ),
                    ),
                  ),
                  _EquippedSlotBox(
                    slotTitle: 'BODY SLOT',
                    item: bodyItem,
                    fallbackIcon: '🦺',
                  ),
                  _EquippedSlotBox(
                    slotTitle: 'HAND TOOL',
                    item: toolItem,
                    fallbackIcon: '🍳',
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ── Proc Summary Card ──
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFF59E0B).withValues(alpha: 0.15),
                const Color(0xFFB45309).withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text('⚡', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 6),
                  Text(
                    'ACTIVE GEAR PROC STATS',
                    style: TextStyle(
                      color: Color(0xFFFFD54F),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _ProcStatRow(
                icon: '⚡',
                label: 'Instant Cook Chance',
                value: '${gs.gearInstantCookChance.toStringAsFixed(1)}%',
                desc: 'Stoves finish recipe in 0.1s ("INSTANT!")',
                color: const Color(0xFFFFD54F),
              ),
              const SizedBox(height: 6),
              _ProcStatRow(
                icon: '✨',
                label: 'Divine Dish Chance',
                value: '${gs.gearDivineDishChance.toStringAsFixed(1)}%',
                desc: 'Plated meals award 5x normal revenue',
                color: const Color(0xFF38BDF8),
              ),
              const SizedBox(height: 6),
              _ProcStatRow(
                icon: '👟',
                label: 'All Staff Walk Speed',
                value: '+${((gs.gearStaffWalkSpeedMultiplier - 1.0) * 100.0).toStringAsFixed(1)}%',
                desc: 'Movement speed bonus for Waiters & Chefs',
                color: const Color(0xFF4ADE80),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Blueprint Inventory & Merging Grid ──
        const Text(
          'GEAR BLUEPRINTS & MERGING (3x -> NEXT TIER)',
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),

        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.75,
          children: gs.gearInventory.values.map((item) {
            final isEquipped = gs.equippedGear.values.contains(item.id);
            final canMerge = gs.canMergeGear(item.id);

            return Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isEquipped ? const Color(0xFFFFD54F) : item.rarity.color,
                  width: isEquipped ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: item.rarity.color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.rarity.displayName.toUpperCase(),
                          style: TextStyle(
                            color: item.rarity.color,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Text(
                        'x${item.count}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Text(item.icon, style: const TextStyle(fontSize: 24)),
                  Text(
                    item.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    item.desc,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 8,
                    ),
                  ),
                  // Bottom action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isEquipped)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD54F).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'EQUIPPED',
                            style: TextStyle(color: Color(0xFFFFD54F), fontSize: 8, fontWeight: FontWeight.w900),
                          ),
                        )
                      else
                        InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            gs.equipGearItem(item.id);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0284C7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'EQUIP',
                              style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                      if (canMerge) ...[
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            final res = gs.mergeGearItem(item.id);
                            if (res['success'] == true) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: const Color(0xFFFFB300),
                                  content: Text(
                                    '🎉 Merged into ${res['new_rarity']} ${item.name}!',
                                    style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w900),
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'MERGE',
                              style: TextStyle(color: Colors.black87, fontSize: 8, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _EquippedSlotBox extends StatelessWidget {
  final String slotTitle;
  final GearItem? item;
  final String fallbackIcon;

  const _EquippedSlotBox({
    required this.slotTitle,
    required this.item,
    required this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    final color = item?.rarity.color ?? Colors.white24;

    return Container(
      width: 76,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            slotTitle,
            style: const TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(item?.icon ?? fallbackIcon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 2),
          Text(
            item?.name ?? 'Empty',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _ProcStatRow extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final String desc;
  final Color color;

  const _ProcStatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.desc,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
              ),
              Text(
                desc,
                style: const TextStyle(color: Colors.white54, fontSize: 9),
              ),
            ],
          ),
        ),
        Text(
          value,
          style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}
