import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../logic/game_state.dart';

final _fmt = NumberFormat.compactCurrency(symbol: '\$', decimalDigits: 0);

/// Clean, high-contrast mobile Tycoon HUD Overlay.
/// Replaces dark web-style boxes and system emojis with crisp PNG icons,
/// eliminates bottom collisions, collapses right buttons to 3,
/// and compacts the top header to 12% of screen height.
class HudOverlay extends StatefulWidget {
  final VoidCallback onManagersTap;
  final VoidCallback onStatsTap;
  final VoidCallback? onWorldMapTap;
  final VoidCallback? onShopTap;
  final VoidCallback? onBoostTap;
  final VoidCallback? onPiggyBankTap;
  final VoidCallback? onRecipeBookTap;
  final VoidCallback? onReviewDrawerTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onUpgradesTap;

  const HudOverlay({
    super.key,
    required this.onManagersTap,
    required this.onStatsTap,
    this.onWorldMapTap,
    this.onShopTap,
    this.onBoostTap,
    this.onPiggyBankTap,
    this.onRecipeBookTap,
    this.onReviewDrawerTap,
    this.onSettingsTap,
    this.onUpgradesTap,
  });

  @override
  State<HudOverlay> createState() => _HudOverlayState();
}

class _HudOverlayState extends State<HudOverlay> {
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

  void _showMoreMenu(BuildContext context, GameState gs) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2430),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFFFD54F), width: 2.0),
        ),
        titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
        contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD54F).withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.apps_rounded, color: Color(0xFFFFD54F), size: 22),
            ),
            const SizedBox(width: 10),
            const Text(
              'DINER OPERATIONS',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 0.8,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: const Icon(Icons.close, color: Colors.white60, size: 22),
            ),
          ],
        ),
        content: SizedBox(
          width: 320,
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.15,
            children: [
              _MoreGridTile(
                title: 'Analytics',
                subtitle: 'Pipeline & Stats',
                icon: const Icon(Icons.bar_chart_rounded, color: Color(0xFF4CAF50), size: 28),
                borderColor: const Color(0xFF4CAF50),
                onTap: () {
                  Navigator.pop(ctx);
                  widget.onStatsTap();
                },
              ),
              _MoreGridTile(
                title: 'Franchise',
                subtitle: 'World Map',
                icon: const Icon(Icons.public_rounded, color: Color(0xFF29B6F6), size: 28),
                borderColor: const Color(0xFF29B6F6),
                onTap: () {
                  Navigator.pop(ctx);
                  widget.onWorldMapTap?.call();
                },
              ),
              _MoreGridTile(
                title: 'Recipes',
                subtitle: '5★ Masteries',
                icon: Image.asset(
                  'restaurant_tycoon_3d/assets/textures/chalkboard_menu.png',
                  width: 28,
                  height: 28,
                  errorBuilder: (_, __, ___) => const Icon(Icons.menu_book_rounded, color: Color(0xFFFFB300), size: 28),
                ),
                borderColor: const Color(0xFFFFB300),
                onTap: () {
                  Navigator.pop(ctx);
                  widget.onRecipeBookTap?.call();
                },
              ),
              _MoreGridTile(
                title: 'Settings',
                subtitle: 'Audio & Save',
                icon: const Icon(Icons.settings_rounded, color: Color(0xFFAB47BC), size: 28),
                borderColor: const Color(0xFFAB47BC),
                onTap: () {
                  Navigator.pop(ctx);
                  widget.onSettingsTap?.call();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gs, _) {
        final timeStr = DateFormat('hh:mm a').format(_gameClock);

        return SafeArea(
          child: Stack(
            children: [
              // ── 1. Compact Top Header (12% Screen Height, 2 Tight Rows) ────
              Positioned(
                top: 4,
                left: 12,
                right: 12,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Row 1: Avatar + 5-Star Milestone Rating Bar + Clock
                    Row(
                      children: [
                        // Avatar Badge
                        _AvatarPill(level: gs.restaurantLevel),
                        const SizedBox(width: 8),

                        // Interactive 5-Star Milestone Rating Bar Capsule
                        Expanded(
                          child: GestureDetector(
                            onTap: widget.onReviewDrawerTap ?? widget.onRecipeBookTap,
                            child: _TopRatingCapsule(
                              progress: (gs.starRating / 5.0).clamp(0.0, 1.0),
                              starRating: gs.starRating,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Time & Live indicator
                        _LiveTimeCapsule(time: timeStr),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Row 2: Cash, Diamonds, and Energy High-Contrast Capsules
                    Row(
                      children: [
                        // Cash Capsule with +$/s rate
                        Expanded(
                          flex: 5,
                          child: _CashCapsule(
                            cash: gs.cash,
                            ratePerSec: gs.cashPerSecond,
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Diamonds Capsule
                        Expanded(
                          flex: 3,
                          child: _DiamondCapsule(gems: gs.gems),
                        ),
                        const SizedBox(width: 8),

                        // Energy Capsule
                        Expanded(
                          flex: 3,
                          child: const _EnergyCapsule(energy: 833, maxEnergy: 880),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── 2. Collapsed Right Margin (Only 3 Compact 52x52 Buttons) ───
              Positioned(
                right: 16,
                top: MediaQuery.of(context).size.height * 0.28,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Button 1: Golden Piggy Bank (52x52)
                    _CompactMarginButton(
                      size: 52,
                      tooltip: 'Piggy Bank',
                      iconAsset: 'restaurant_tycoon_3d/assets/textures/icon_chest_gold.png',
                      fallbackIcon: Icons.savings_rounded,
                      badgeText: gs.piggyBankBalance > 0 ? '${gs.piggyBankBalance}' : null,
                      gradient: const [Color(0xFFFF8F00), Color(0xFFD84315)],
                      borderColor: const Color(0xFFFFD54F),
                      onTap: widget.onPiggyBankTap ?? () {},
                    ),
                    const SizedBox(height: 12),

                    // Button 2: Manager Cards (52x52)
                    _CompactMarginButton(
                      size: 52,
                      tooltip: 'Staff & Managers',
                      iconAsset: 'restaurant_tycoon_3d/assets/textures/idle_diner_mascot_icon.png',
                      fallbackIcon: Icons.badge_rounded,
                      gradient: const [Color(0xFF8E24AA), Color(0xFF4A148C)],
                      borderColor: const Color(0xFFFFD54F),
                      onTap: widget.onManagersTap,
                    ),
                    const SizedBox(height: 12),

                    // Button 3: More Drawer Toggle (52x52)
                    _CompactMarginButton(
                      size: 52,
                      tooltip: 'More Options',
                      fallbackIcon: Icons.grid_view_rounded,
                      gradient: const [Color(0xFF37474F), Color(0xFF212121)],
                      borderColor: const Color(0xFFFFD54F),
                      onTap: () => _showMoreMenu(context, gs),
                    ),
                  ],
                ),
              ),

              // ── 3. Non-Overlapping Bottom Bar (3 Elements, 16px Padding) ────
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left: 64x64 3D-Beveled Shop Button
                    _BeveledBottomButton(
                      size: 64,
                      title: 'SHOP',
                      iconAsset: 'restaurant_tycoon_3d/assets/textures/icon_chest_gold.png',
                      fallbackIcon: Icons.storefront_rounded,
                      gradient: const [Color(0xFFFFB300), Color(0xFFE65100)],
                      borderColor: const Color(0xFFFFE082),
                      shadowColor: const Color(0xFFBF360C),
                      onTap: widget.onShopTap ??
                          () => ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('🛒 Tycoon Superstore opening...'),
                                  duration: Duration(seconds: 1),
                                ),
                              ),
                    ),

                    // Center: Compact x2 BOOST! Pill Button (180x52)
                    _CompactBoostPill(
                      isBoosted: gs.vipActive,
                      timer: gs.vipTimer,
                      onTap: widget.onBoostTap ?? () => gs.triggerVipEvent(),
                    ),

                    // Right: 64x64 Upgrades / Stations Drawer Button
                    _BeveledBottomButton(
                      size: 64,
                      title: 'UPGRADE',
                      iconAsset: 'restaurant_tycoon_3d/assets/textures/idle_diner_mascot_icon.png',
                      fallbackIcon: Icons.arrow_upward_rounded,
                      gradient: const [Color(0xFF43A047), Color(0xFF1B5E20)],
                      borderColor: const Color(0xFFA5D6A7),
                      shadowColor: const Color(0xFF0D5302),
                      onTap: widget.onUpgradesTap ?? widget.onManagersTap,
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

// ═════════════════════════════════════════════════════════════════════════════
// TOP HEADER CAPSULES (HIGH CONTRAST, BRIGHT BORDERS)
// ═════════════════════════════════════════════════════════════════════════════

class _AvatarPill extends StatelessWidget {
  final int level;

  const _AvatarPill({required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFFFD54F), width: 2.2),
        boxShadow: const [
          BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipOval(
            child: Image.asset(
              'restaurant_tycoon_3d/assets/textures/idle_diner_mascot_icon.png',
              width: 38,
              height: 38,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Color(0xFF5D4037), size: 24),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFFFF8F00),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: Text(
                'Lv.$level',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopRatingCapsule extends StatelessWidget {
  final double progress;
  final num starRating;

  const _TopRatingCapsule({required this.progress, required this.starRating});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFFFB300), width: 2.0),
        boxShadow: const [
          BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFE082), Color(0xFFFFB300)],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFFF8F00), size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '${starRating.toStringAsFixed(1)} ★★★★★ Diner Rating',
                    style: const TextStyle(
                      color: Color(0xFF3E2723),
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'REVIEWS ▼',
                    style: TextStyle(
                      color: Color(0xFFE65100),
                      fontWeight: FontWeight.w900,
                      fontSize: 9,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveTimeCapsule extends StatelessWidget {
  final String time;

  const _LiveTimeCapsule({required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFF90A4AE), width: 1.8),
        boxShadow: const [
          BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF00E676),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            time,
            style: const TextStyle(
              color: Color(0xFF263238),
              fontWeight: FontWeight.w900,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _CashCapsule extends StatelessWidget {
  final double cash;
  final double ratePerSec;

  const _CashCapsule({required this.cash, required this.ratePerSec});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFF4CAF50), width: 2.0),
        boxShadow: const [
          BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            'restaurant_tycoon_3d/assets/textures/icon_gold_coin.png',
            width: 20,
            height: 20,
            errorBuilder: (_, __, ___) => const Icon(Icons.attach_money, color: Color(0xFF2E7D32), size: 18),
          ),
          const SizedBox(width: 6),
          Text(
            _fmt.format(cash),
            style: const TextStyle(
              color: Color(0xFF1B5E20),
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+${_fmt.format(ratePerSec)}/s',
              style: const TextStyle(
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.w900,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiamondCapsule extends StatelessWidget {
  final int gems;

  const _DiamondCapsule({required this.gems});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFF0288D1), width: 2.0),
        boxShadow: const [
          BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'restaurant_tycoon_3d/assets/textures/icon_diamond.png',
            width: 20,
            height: 20,
            errorBuilder: (_, __, ___) => const Icon(Icons.diamond_rounded, color: Color(0xFF0288D1), size: 18),
          ),
          const SizedBox(width: 6),
          Text(
            '$gems',
            style: const TextStyle(
              color: Color(0xFF01579B),
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _EnergyCapsule extends StatelessWidget {
  final int energy;
  final int maxEnergy;

  const _EnergyCapsule({required this.energy, required this.maxEnergy});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFFF8F00), width: 2.0),
        boxShadow: const [
          BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'restaurant_tycoon_3d/assets/textures/icon_energy.png',
            width: 20,
            height: 20,
            errorBuilder: (_, __, ___) => const Icon(Icons.bolt_rounded, color: Color(0xFFFF8F00), size: 18),
          ),
          const SizedBox(width: 4),
          Text(
            '$energy',
            style: const TextStyle(
              color: Color(0xFFE65100),
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// RIGHT MARGIN BUTTONS (COLLAPSED TO 3 COMPACT 52x52 BUTTONS)
// ═════════════════════════════════════════════════════════════════════════════

class _CompactMarginButton extends StatelessWidget {
  final double size;
  final String tooltip;
  final String? iconAsset;
  final IconData fallbackIcon;
  final String? badgeText;
  final List<Color> gradient;
  final Color borderColor;
  final VoidCallback onTap;

  const _CompactMarginButton({
    required this.size,
    required this.tooltip,
    this.iconAsset,
    required this.fallbackIcon,
    this.badgeText,
    required this.gradient,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
            border: Border.all(color: borderColor, width: 2.2),
            boxShadow: const [
              BoxShadow(color: Colors.black38, offset: Offset(0, 3), blurRadius: 5),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (iconAsset != null)
                Image.asset(
                  iconAsset!,
                  width: size * 0.55,
                  height: size * 0.55,
                  errorBuilder: (_, __, ___) => Icon(fallbackIcon, color: Colors.white, size: size * 0.52),
                )
              else
                Icon(fallbackIcon, color: borderColor, size: size * 0.52),

              if (badgeText != null)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0288D1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white, width: 1.2),
                    ),
                    child: Text(
                      badgeText!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// BOTTOM BAR (3 NON-OVERLAPPING ELEMENTS WITH 16PX PADDING)
// ═════════════════════════════════════════════════════════════════════════════

class _BeveledBottomButton extends StatelessWidget {
  final double size;
  final String title;
  final String? iconAsset;
  final IconData fallbackIcon;
  final List<Color> gradient;
  final Color borderColor;
  final Color shadowColor;
  final VoidCallback onTap;

  const _BeveledBottomButton({
    required this.size,
    required this.title,
    this.iconAsset,
    required this.fallbackIcon,
    required this.gradient,
    required this.borderColor,
    required this.shadowColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradient,
          ),
          border: Border(
            top: BorderSide(color: borderColor, width: 3.0),
            left: BorderSide(color: borderColor, width: 2.0),
            right: BorderSide(color: borderColor, width: 2.0),
            bottom: BorderSide(color: shadowColor, width: 4.5),
          ),
          boxShadow: const [
            BoxShadow(color: Colors.black45, offset: Offset(0, 4), blurRadius: 6),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconAsset != null)
              Image.asset(
                iconAsset!,
                width: 28,
                height: 28,
                errorBuilder: (_, __, ___) => Icon(fallbackIcon, color: Colors.white, size: 26),
              )
            else
              Icon(fallbackIcon, color: Colors.white, size: 26),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 0.5,
                shadows: [
                  Shadow(color: Colors.black87, offset: Offset(1, 1), blurRadius: 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactBoostPill extends StatelessWidget {
  final bool isBoosted;
  final double timer;
  final VoidCallback onTap;

  const _CompactBoostPill({
    required this.isBoosted,
    required this.timer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: isBoosted ? const Color(0xFF2E7D32) : const Color(0xFFFFB300),
            width: 2.8,
          ),
          boxShadow: const [
            BoxShadow(color: Colors.black38, offset: Offset(0, 4), blurRadius: 6),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'restaurant_tycoon_3d/assets/textures/icon_energy.png',
              width: 26,
              height: 26,
              errorBuilder: (_, __, ___) => const Icon(Icons.bolt, color: Color(0xFFFF8F00), size: 24),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBoosted ? 'x2 ACTIVE!' : 'x2 BOOST!',
                  style: TextStyle(
                    color: isBoosted ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  isBoosted ? '${timer.toInt()}s left' : 'Tap for 2x Speed',
                  style: const TextStyle(
                    color: Color(0xFF546E7A),
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
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

class _MoreGridTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget icon;
  final Color borderColor;
  final VoidCallback onTap;

  const _MoreGridTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF263238),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor.withValues(alpha: 0.6), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// STATS / ANALYTICS MODAL (HOUSES PIPELINE, FEVER COMBO, AND EXPENSE RIBBONS)
// ═════════════════════════════════════════════════════════════════════════════

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
          width: 330,
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2430).withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFD54F), width: 2.0),
            boxShadow: const [
              BoxShadow(color: Colors.black54, offset: Offset(0, 8), blurRadius: 16),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.insights_rounded, color: Color(0xFFFFD54F), size: 22),
                  const SizedBox(width: 8),
                  const Text(
                    'RESTAURANT ANALYTICS',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onClose,
                    child: const Icon(Icons.close, color: Colors.white70, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 3-Stage Pipeline Balance Widget (Moved from permanent screen)
              const Text(
                '3-STAGE PIPELINE THROUGHPUT',
                style: TextStyle(
                  color: Color(0xFFFFD54F),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 6),
              _PipelineBalanceWidget(
                parkingRate: gs.parkingThroughputPerMin,
                kitchenRate: gs.kitchenThroughputPerMin,
                seatingRate: gs.seatingThroughputPerMin,
                bottleneck: gs.pipelineBottleneckSector,
                onSectorTap: (_) {},
              ),
              const SizedBox(height: 12),

              // Diner Fever Combo Bar (Moved from permanent screen)
              const Text(
                'DINER FEVER OVERDRIVE',
                style: TextStyle(
                  color: Color(0xFFFF8F00),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 6),
              _FeverComboBanner(
                charge: gs.feverCharge,
                maxCharge: GameState.feverMaxCharge,
                isActive: gs.isFeverActive,
                onSurgeTap: () => gs.tapFeverSurge(),
              ),
              const SizedBox(height: 12),

              // 4 Operational Status Ribbons (Moved from permanent screen)
              const Text(
                'OPERATIONAL STATUS RIBBONS',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 6),
              Builder(
                builder: (context) {
                  final b = gs.getSectorBottleneckStatus();
                  final col = b['color'] as Color;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: col.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: col, width: 1.2),
                    ),
                    child: Text(
                      '${b['text']}',
                      style: TextStyle(color: col, fontWeight: FontWeight.w800, fontSize: 11),
                    ),
                  );
                },
              ),
              const _StatusRibbon(text: '- 50 Marketing Upkeep', isPositive: false),
              const SizedBox(height: 4),
              const _StatusRibbon(text: '+ 25,830 Parking Revenue', isPositive: true),
              const SizedBox(height: 4),
              const _StatusRibbon(text: '- 300 Cleaning Upkeep', isPositive: false),

              const Divider(color: Colors.white24, height: 20),

              // Overview Stats
              _statRow('Total Earned', _fmt.format(gs.totalEarned)),
              _statRow('Active Patrons', '$guestCount guests'),
              _statRow('Service Staff', '$staffCount on floor'),
              _statRow('Managers', '$assignedManagers active'),
            ],
          ),
        );
      },
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.5)),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// COMPONENT WIDGETS USED IN STATS MODAL
// ═════════════════════════════════════════════════════════════════════════════

class _PipelineBalanceWidget extends StatelessWidget {
  final int parkingRate;
  final int kitchenRate;
  final int seatingRate;
  final String bottleneck;
  final ValueChanged<String> onSectorTap;

  const _PipelineBalanceWidget({
    required this.parkingRate,
    required this.kitchenRate,
    required this.seatingRate,
    required this.bottleneck,
    required this.onSectorTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF263238),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _pipelineStage('Parking', '$parkingRate/m', bottleneck == 'parking', () => onSectorTap('parking')),
          const Icon(Icons.arrow_forward_rounded, color: Colors.white38, size: 14),
          _pipelineStage('Kitchen', '$kitchenRate/m', bottleneck == 'kitchen', () => onSectorTap('kitchen')),
          const Icon(Icons.arrow_forward_rounded, color: Colors.white38, size: 14),
          _pipelineStage('Seating', '$seatingRate/m', bottleneck == 'seating', () => onSectorTap('seating')),
        ],
      ),
    );
  }

  Widget _pipelineStage(String name, String rate, bool isBottleneck, VoidCallback onTap) {
    final col = isBottleneck ? const Color(0xFFFF5252) : const Color(0xFF00E676);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: col.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: col, width: 1.2),
        ),
        child: Column(
          children: [
            Text(name, style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold)),
            Text(rate, style: TextStyle(color: col, fontSize: 11, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}

class _FeverComboBanner extends StatelessWidget {
  final double charge;
  final double maxCharge;
  final bool isActive;
  final VoidCallback onSurgeTap;

  const _FeverComboBanner({
    required this.charge,
    required this.maxCharge,
    required this.isActive,
    required this.onSurgeTap,
  });

  @override
  Widget build(BuildContext context) {
    final frac = (charge / maxCharge).clamp(0.0, 1.0);
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF263238),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isActive ? const Color(0xFFFFD54F) : Colors.white24),
      ),
      child: Row(
        children: [
          Text(
            isActive ? '🔥 FEVER ACTIVE (2x)' : 'FEVER COMBO',
            style: TextStyle(
              color: isActive ? const Color(0xFFFFD54F) : Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 10,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: frac,
                minHeight: 8,
                backgroundColor: Colors.black38,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isActive ? const Color(0xFFFFD54F) : const Color(0xFFFF7043),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onSurgeTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFF8F00),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'SURGE',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusRibbon extends StatelessWidget {
  final String text;
  final bool isPositive;

  const _StatusRibbon({required this.text, required this.isPositive});

  @override
  Widget build(BuildContext context) {
    final col = isPositive ? const Color(0xFF00E676) : const Color(0xFFFF5252);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: col.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border(left: BorderSide(color: col, width: 3)),
      ),
      child: Text(
        text,
        style: TextStyle(color: col, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// Welcome Back Modal (offline earnings)
class WelcomeBackModal extends StatelessWidget {
  final double earnings;
  final void Function(double multiplier) onClaim;

  const WelcomeBackModal({
    super.key,
    required this.earnings,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        decoration: BoxDecoration(
          color: const Color(0xFF181C28),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF5B025), width: 2.5),
          boxShadow: const [
            BoxShadow(
              color: Colors.black87,
              blurRadius: 28,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE65100), Color(0xFFFFA000), Color(0xFFFFD54F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(17)),
              ),
              child: const Column(
                children: [
                  Text(
                    '✨ WELCOME BACK, CHEF! ✨',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 1)),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Your diner staff kept cooking while you were away!',
                    style: TextStyle(
                      color: Color(0xFFFFF8E1),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1E16),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF00E676), width: 1.5),
                      boxShadow: const [
                        BoxShadow(color: Color(0x3300E676), blurRadius: 10),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'TOTAL OFFLINE EARNINGS',
                          style: TextStyle(
                            color: Color(0xFFA7F3D0),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '+${_fmt.format(earnings)}',
                          style: const TextStyle(
                            color: Color(0xFF00E676),
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => onClaim(1.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF4CAF50), width: 1.5),
                              boxShadow: const [
                                BoxShadow(color: Color(0x661B5E20), blurRadius: 6, offset: Offset(0, 3)),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'COLLECT',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => onClaim(2.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF8F00), Color(0xFFE65100)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
                              boxShadow: const [
                                BoxShadow(color: Color(0x66E65100), blurRadius: 6, offset: Offset(0, 3)),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                '⚡ 2X BOOST!',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

typedef OfflineEarningsDialog = WelcomeBackModal;
