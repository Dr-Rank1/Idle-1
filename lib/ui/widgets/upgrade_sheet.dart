import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../logic/game_state.dart';
import '../../models/station.dart';
import '../../models/enums.dart';

final _fmt = NumberFormat.compactCurrency(symbol: '\$', decimalDigits: 0);

class UpgradeSheet extends StatefulWidget {
  final Station station;

  const UpgradeSheet({super.key, required this.station});

  @override
  State<UpgradeSheet> createState() => _UpgradeSheetState();
}

class _UpgradeSheetState extends State<UpgradeSheet> {
  int _selectedSubIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gs, _) {
        final station = widget.station;
        final canAfford = gs.cash >= station.upgradeCost;
        final isMaxed = station.level >= station.maxLevel;
        final levelFraction = station.level / station.maxLevel;

        final zoneTitle = _getZoneTitle(station.zone);
        final operatingHours = _getOperatingHours(station.zone);

        final subItems = _getSubItems(station.zone, station.name);
        final currentSub = subItems[_selectedSubIndex.clamp(0, subItems.length - 1)];

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFEA5E28), // Warm deep orange
                Color(0xFFFDB82C), // Golden yellow
              ],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 20,
                offset: Offset(0, -6),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Tabs (Upgrades & Staff) + Close button
              Row(
                children: [
                  // Upgrades Tab
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8C261E),
                      borderRadius: BorderRadius.circular(10),
                      border: const Border(
                        top: BorderSide(color: Color(0xFFD84315), width: 2),
                      ),
                    ),
                    child: const Text(
                      '← UPGRADES',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Staff Tab
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8672E).withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        '👥 STAFF',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Close Button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF45241C).withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '✕',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Reddish-Brown Header Bar showing Zone Title and Operating Hours
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8C261E),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFA73328), width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4),
                  ],
                ),
                child: Row(
                  children: [
                    Text(
                      zoneTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        operatingHours,
                        style: const TextStyle(
                          color: Color(0xFFFFD6A5),
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              // Cyan/Green Milestone Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: levelFraction.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: const Color(0xFF2E1A14),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
                ),
              ),

              const SizedBox(height: 6),

              // Dark Brown Stats Ribbon
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF5A1A10),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      '💵 ${_fmt.format(gs.cash)}',
                      style: const TextStyle(
                        color: Color(0xFF69F0AE),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                    const Text(
                      '⚡ 833',
                      style: TextStyle(
                        color: Color(0xFFFFE082),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                    const Text(
                      '💎 20,141',
                      style: TextStyle(
                        color: Color(0xFF80D8FF),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // White Card for Selected Item
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Card Header: Item Title, Level Badge, and MAX Badge
                    Row(
                      children: [
                        Text(
                          currentSub.title,
                          style: const TextStyle(
                            color: Color(0xFF1E2430),
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECEFF1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Level ${station.level}',
                            style: const TextStyle(
                              color: Color(0xFF455A64),
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (isMaxed)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2979FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'MAX',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Card Body: Icon, Description, Revenue Stat, and Upgrade Button
                    Row(
                      children: [
                        // Station Icon
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFFB74D), width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              currentSub.emoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Description & Stats
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentSub.desc,
                                style: const TextStyle(
                                  color: Color(0xFF546E7A),
                                  fontSize: 11,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '💵 +${_fmt.format(station.income)} / cust   ⚡ +15',
                                style: const TextStyle(
                                  color: Color(0xFF2E7D32),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Upgrade Button (or MAX LEVEL UPGRADE)
                        _UpgradeActionBtn(
                          isMaxed: isMaxed,
                          canAfford: canAfford,
                          cost: station.upgradeCost,
                          onTap: () {
                            gs.upgradeStation(station.id);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 2-Row Grid of Square Brown/Green Sub-Upgrade Icons
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.05,
                ),
                itemCount: subItems.length.clamp(0, 10),
                itemBuilder: (context, index) {
                  final item = subItems[index];
                  final isSelected = index == _selectedSubIndex;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedSubIndex = index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF9E3A20)
                            : const Color(0xFF632212),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF45170B),
                          width: isSelected ? 2.5 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                const BoxShadow(
                                  color: Color(0x66FFD54F),
                                  blurRadius: 6,
                                ),
                              ]
                            : null,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(item.emoji, style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 2),
                          Text(
                            item.shortName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.black38,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isMaxed ? 'MAX' : 'Lv. ${station.level}',
                              style: TextStyle(
                                color: isMaxed ? const Color(0xFF40C4FF) : Colors.white70,
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _getZoneTitle(ZoneType zone) {
    switch (zone) {
      case ZoneType.kitchen:
        return '🍳 Kitchen';
      case ZoneType.diningRoom:
        return '🪑 Dining';
      case ZoneType.reception:
        return '🛎️ Lobby';
      case ZoneType.hotelRoom:
        return '🚗 Parking';
      default:
        return '🥤 Milkshake Bar';
    }
  }

  String _getOperatingHours(ZoneType zone) {
    switch (zone) {
      case ZoneType.reception:
        return '🌙 Closes: 11:00 PM';
      case ZoneType.hotelRoom:
        return '☀️ 24 Hours Open';
      default:
        return '🌙 Closes: 11:00 PM';
    }
  }

  List<_SubItem> _getSubItems(ZoneType zone, String stationName) {
    if (zone == ZoneType.kitchen) {
      return const [
        _SubItem('🍳', 'Stoves', 'Master Stoves', 'High efficiency gas cooking ranges.'),
        _SubItem('🔪', 'Prep', 'Prep Table', 'Stainless steel food prep and slicing station.'),
        _SubItem('🍟', 'Fryer', 'Deep Fryer', 'Crispy golden fries and onion rings.'),
        _SubItem('🧼', 'Dishes', 'Dishwasher', 'Commercial high-temperature sanitizing unit.'),
        _SubItem('🧊', 'Pantry', 'Cold Storage', 'Walk-in refrigeration for fresh ingredients.'),
        _SubItem('🧂', 'Spices', 'Spice Rack', 'Artisanal seasonings and house rubs.'),
        _SubItem('💨', 'Vent', 'Range Hood', 'Industrial fume extraction hood.'),
        _SubItem('🧾', 'Tickets', 'Order Rack', 'High-speed line ticket dispatch.'),
        _SubItem('🍽️', 'Knives', 'Chef Cutlery', 'Professional Japanese forged knife set.'),
        _SubItem('📦', 'Storage', 'Dry Pantry', 'Organized dry ingredient storage.'),
      ];
    } else if (zone == ZoneType.diningRoom) {
      return const [
        _SubItem('🪑', 'Booth 1', 'Booth Table 1', 'Plush red vinyl bench and turquoise table.'),
        _SubItem('🪑', 'Booth 2', 'Booth Table 2', 'Comfortable family dining suite.'),
        _SubItem('🪑', 'Booth 3', 'Booth Table 3', 'Quiet booth suite along the window.'),
        _SubItem('🪑', 'Booth 4', 'Booth Table 4', 'Central dining hall booth.'),
        _SubItem('🪑', 'Booth 5', 'Booth Table 5', 'Spacious corner booth for groups.'),
        _SubItem('🍽️', 'Tableware', 'Cutlery Set', 'Polished diner silverware and napkins.'),
        _SubItem('🧂', 'Sauces', 'Condiments', 'Classic diner ketchup and mustard bottles.'),
        _SubItem('🎵', 'Jukebox', 'Retro Jukebox', 'Rock and roll hits on vinyl.'),
        _SubItem('🌿', 'Planters', 'Hedge Decors', 'Lush greenery partitions.'),
        _SubItem('📺', 'TV', 'Sports Display', 'High-definition diner sports broadcast.'),
      ];
    } else {
      return const [
        _SubItem('🥤', 'Bar Top', 'Bar Top', 'Upgrade the Bar Top to increase cash earned.'),
        _SubItem('🍨', 'Blender', 'Frappe Blender', 'Dual-motor milkshake churners.'),
        _SubItem('🌿', 'Plants', 'Flower Box', 'Fresh decorative planter dividers.'),
        _SubItem('🪑', 'Booth 1', 'Retro Booth 1', 'Comfortable vinyl upholstered booth.'),
        _SubItem('🪑', 'Booth 2', 'Retro Booth 2', 'Spacious diner booth suite.'),
        _SubItem('🪑', 'Booth 3', 'Retro Booth 3', 'Cozy diner booth suite.'),
        _SubItem('🪑', 'Booth 4', 'Retro Booth 4', 'Window-side milkshake booth.'),
        _SubItem('📺', 'TV Screen', 'Sports TV', 'Crisp LCD display showing daily games.'),
        _SubItem('📻', 'Speaker', 'Sound System', 'Warm acoustic diner background music.'),
        _SubItem('🌸', 'Planter', 'Floral Divider', 'Vibrant flowering lobby accents.'),
      ];
    }
  }
}

class _SubItem {
  final String emoji;
  final String shortName;
  final String title;
  final String desc;

  const _SubItem(this.emoji, this.shortName, this.title, this.desc);
}

class _UpgradeActionBtn extends StatelessWidget {
  final bool isMaxed;
  final bool canAfford;
  final double cost;
  final VoidCallback onTap;

  const _UpgradeActionBtn({
    required this.isMaxed,
    required this.canAfford,
    required this.cost,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isMaxed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF78909C),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          'MAX LEVEL\nUPGRADE',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 10,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: canAfford ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: canAfford
              ? const LinearGradient(
                  colors: [Color(0xFF00E676), Color(0xFF00C853)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : null,
          color: canAfford ? null : Colors.grey.shade400,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: canAfford ? const Color(0xFF69F0AE) : Colors.grey,
            width: 1.5,
          ),
          boxShadow: canAfford
              ? const [
                  BoxShadow(
                    color: Color(0x6600E676),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'UPGRADE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
            Text(
              _fmt.format(cost),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
