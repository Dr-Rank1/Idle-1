import 'dart:math';
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
  String _currentMultiplier = 'x1';

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gs, _) {
        final station = widget.station;
        final isMaxed = station.level >= station.maxLevel;
        final levelFraction = station.level / station.maxLevel;

        int levelsToBuy = 1;
        double totalCost = 0.0;
        if (_currentMultiplier == 'x1') {
          levelsToBuy = (!isMaxed) ? 1 : 0;
          totalCost = station.upgradeCost;
        } else if (_currentMultiplier == 'x10') {
          levelsToBuy = min(10, station.maxLevel - station.level);
          for (int i = 0; i < levelsToBuy; i++) {
            totalCost += station.baseCostFn(station.level + i);
          }
        } else {
          int count = 0;
          double acc = 0.0;
          for (int l = station.level; l < station.maxLevel; l++) {
            double c = station.baseCostFn(l);
            if (acc + c <= gs.cash || count == 0) {
              acc += c;
              count++;
            } else {
              break;
            }
          }
          levelsToBuy = count;
          totalCost = acc;
        }

        final canAfford = !isMaxed && levelsToBuy > 0 && gs.cash >= totalCost;
        final bottleneck = gs.getSectorBottleneckStatus();

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

              // Reddish-Brown Header Bar showing Zone Title, Bottleneck Status, Multiplier Toggle, and Operating Hours
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Sector Bottleneck Status Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (bottleneck['color'] as Color).withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: bottleneck['color'] as Color, width: 1),
                      ),
                      child: Text(
                        '${bottleneck['icon']} ${bottleneck['text']}',
                        style: TextStyle(
                          color: bottleneck['color'] as Color,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Bulk-Buy Multiplier Toggle Pill (x1, x10, MAX)
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5A1A10),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFD84315), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: ['x1', 'x10', 'MAX'].map((m) {
                          final isSel = _currentMultiplier == m;
                          return GestureDetector(
                            onTap: () => setState(() => _currentMultiplier = m),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSel ? const Color(0xFF00E676) : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                m,
                                style: TextStyle(
                                  color: isSel ? const Color(0xFF1B5E20) : Colors.white70,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        operatingHours,
                        style: const TextStyle(
                          color: Color(0xFFFFD6A5),
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              // Cyan/Green Milestone Progress Bar with Milestone Progress Ticks at Levels 10, 25, 50
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final barWidth = constraints.maxWidth;
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: levelFraction.clamp(0.0, 1.0),
                              minHeight: 10,
                              backgroundColor: const Color(0xFF2E1A14),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
                            ),
                          ),
                          // Milestone progress ticks at Levels 10, 25, 50
                          ...[10, 25, 50].map((milestone) {
                            final frac = milestone / station.maxLevel;
                            if (frac > 1.0) return const SizedBox.shrink();
                            final xPos = barWidth * frac;
                            final reached = station.level >= milestone;
                            return Positioned(
                              left: (xPos - 1).clamp(0.0, barWidth - 2),
                              top: 0,
                              bottom: 0,
                              child: Container(
                                width: 2,
                                color: reached ? const Color(0xFFFFD54F) : Colors.white38,
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Lv ${station.level} / ${station.maxLevel}',
                        style: const TextStyle(
                          color: Color(0xFF45241C),
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                        ),
                      ),
                      Row(
                        children: [10, 25, 50].map((m) {
                          final reached = station.level >= m;
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Row(
                              children: [
                                Icon(
                                  reached ? Icons.star : Icons.star_border,
                                  size: 11,
                                  color: reached ? const Color(0xFF8C261E) : Colors.black45,
                                ),
                                Text(
                                  '$m',
                                  style: TextStyle(
                                    color: reached ? const Color(0xFF8C261E) : Colors.black45,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
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
                    Text(
                      '💎 ${NumberFormat('#,###').format(gs.gems)}',
                      style: const TextStyle(
                        color: Color(0xFF80D8FF),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Orange-to-Golden-Yellow Gradient Card for Selected Item
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFFDE7), Color(0xFFFFF8E1), Color(0xFFFFF3E0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isMaxed ? const Color(0xFFFFA000) : const Color(0xFFFFCC80),
                    width: 1.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33FFA000),
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
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: [
                                  _StatusRibbonMini(
                                    text: '📈 +${_fmt.format(station.income)}/cust',
                                    isPositive: true,
                                  ),
                                  _StatusRibbonMini(
                                    text: '⚡ +${(station.level * 2).clamp(5, 50)}',
                                    isPositive: true,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Upgrade Button (or MAX LEVEL UPGRADE)
                        _UpgradeActionBtn(
                          isMaxed: isMaxed,
                          canAfford: canAfford,
                          levelsToBuy: levelsToBuy,
                          cost: totalCost,
                          onTap: () {
                            gs.upgradeStationBulk(station.id, levelsToBuy);
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
        return '🍳 Master Kitchen';
      case ZoneType.diningRoom:
        return '🪑 Dining Room';
      case ZoneType.reception:
        return '🛎️ Reception Lobby';
      case ZoneType.lounge:
        return '🍸 Cocktail Lounge';
      case ZoneType.milkshakeDiner:
        return '🥤 50s Milkshake Diner';
      case ZoneType.parking:
        return '🚗 Valet Parking Lot';
      case ZoneType.restroom:
        return '🧼 Restroom Hygiene';
      case ZoneType.managerOffice:
        return '💼 Manager\'s Office';
      case ZoneType.breakroom:
        return '☕ Staff Breakroom';
      case ZoneType.hotelRoom:
        return '🛏️ Guest Rooms';
      default:
        return '⭐ Resort Sector';
    }
  }

  String _getOperatingHours(ZoneType zone) {
    switch (zone) {
      case ZoneType.reception:
        return '🌙 Closes: 11:00 PM';
      case ZoneType.hotelRoom:
      case ZoneType.parking:
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
        _SubItem('🪑', 'Terrace 10', 'Sunset Cabana 10', 'Outdoor cabana table under umbrella.'),
        _SubItem('🪑', 'Terrace 11', 'Sunset Cabana 11', 'Scenic garden terrace booth.'),
        _SubItem('🪑', 'Terrace 12', 'Sunset Cabana 12', 'VIP ocean view dining cabana.'),
        _SubItem('🍽️', 'Tableware', 'Cutlery Set', 'Polished diner silverware and napkins.'),
        _SubItem('🎵', 'Jukebox', 'Retro Jukebox', 'Rock and roll hits on vinyl.'),
      ];
    } else if (zone == ZoneType.lounge) {
      return const [
        _SubItem('🍸', 'Bar Counter', 'Mahogany Counter', 'Deep cherry mahogany polished bar.'),
        _SubItem('🍷', 'Wine Cellar', 'Vintage Rack', 'Temperature-controlled sommelier storage.'),
        _SubItem('🧊', 'Ice Machine', 'Crystal Cubes', 'Purified ice makers for craft cocktails.'),
        _SubItem('🛋️', 'Lounge Stools', 'Leather Stools', 'Padded mahogany counter stools.'),
        _SubItem('🎵', 'Soundtrack', 'Jazz Audio', 'Smooth vinyl background acoustics.'),
      ];
    } else if (zone == ZoneType.restroom) {
      return const [
        _SubItem('🧼', 'Sanitizer', 'Touchless Wash', 'Hospital-grade automated sanitizers.'),
        _SubItem('🪞', 'Mirrors', 'Vanity Mirrors', 'Illuminated vanity ledges.'),
        _SubItem('🌸', 'Diffusers', 'Aroma Diffusers', 'Fresh eucalyptus & lavender scents.'),
        _SubItem('🧹', 'Polish', 'Tile Scrubbers', 'High-shine sanitary floor polishers.'),
      ];
    } else if (zone == ZoneType.managerOffice) {
      return const [
        _SubItem('💼', 'Executive Desk', 'GM Suite', 'Mahogany executive desk with brass trim.'),
        _SubItem('📊', 'Analytics', 'Live Dashboard', 'Real-time sales & expense projections.'),
        _SubItem('☕', 'Espresso', 'Barista Machine', 'Fueling 24/7 managerial inspections.'),
        _SubItem('📋', 'Audit Board', 'Inspection Drone', 'Automated floor sweep cameras (+25% boost).'),
      ];
    } else if (zone == ZoneType.parking) {
      return const [
        _SubItem('🚗', 'Valet Stall', 'Parking Bay', 'Reserved valet arrival parking slots.'),
        _SubItem('🚁', 'Helipad', 'VIP Helipad', 'South-West helipad landing zone for investors.'),
        _SubItem('🛑', 'Security', 'Boom Gates', 'Automated entry sensors expediting flow.'),
        _SubItem('💡', 'Neon Sign', 'Roadside Neon', 'High-lumen diner sign drawing traffic.'),
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
  final int levelsToBuy;
  final double cost;
  final VoidCallback onTap;

  const _UpgradeActionBtn({
    required this.isMaxed,
    required this.canAfford,
    this.levelsToBuy = 1,
    required this.cost,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isMaxed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFFFECB3), width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66FFA000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: const Text(
          '⭐ MAX LEVEL',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF3E2723),
            fontWeight: FontWeight.w900,
            fontSize: 11,
            letterSpacing: 0.5,
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
            Text(
              levelsToBuy > 1 ? 'UPGRADE +$levelsToBuy' : 'UPGRADE',
              style: const TextStyle(
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

class _StatusRibbonMini extends StatelessWidget {
  final String text;
  final bool isPositive;

  const _StatusRibbonMini({required this.text, required this.isPositive});

  @override
  Widget build(BuildContext context) {
    final bg = isPositive ? const Color(0xFF145224) : const Color(0xFF611414);
    final border = isPositive ? const Color(0xFF00E676) : const Color(0xFFFF5252);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
        border: Border(left: BorderSide(color: border, width: 2.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isPositive ? const Color(0xFFB9F6CA) : const Color(0xFFFFCDD2),
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
