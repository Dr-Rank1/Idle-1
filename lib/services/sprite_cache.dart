import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Preloads and caches decoded [ui.Image] instances for the isometric canvas.
class SpriteCache {
  static final Map<String, ui.Image> _images = {};
  static bool isLoaded = false;
  static Future<void>? _loadingFuture;

  /// Retrieve a pre-rendered sprite or texture by its key.
  static ui.Image? get(String key) => _images[key];

  /// Preload all required textures and isometric sprites asynchronously.
  static Future<void> preload() {
    _loadingFuture ??= _loadAll();
    return _loadingFuture!;
  }

  static Future<void> _loadAll() async {
    final assetPaths = {
      // ── World Textures ────────────────────────────────────────────────────
      'diner_diamond_tiles':
          'restaurant_tycoon_3d/assets/textures/diner_diamond_tiles.png',
      'kitchen_slate_tiles':
          'restaurant_tycoon_3d/assets/textures/kitchen_slate_tiles.png',
      'kitchen_pass_rug':
          'restaurant_tycoon_3d/assets/textures/kitchen_pass_rug.png',
      'reception_tiles':
          'restaurant_tycoon_3d/assets/textures/reception_tiles.png',
      'red_carpet_runner':
          'restaurant_tycoon_3d/assets/textures/red_carpet_runner.png',
      'lounge_shelf_bottles':
          'restaurant_tycoon_3d/assets/textures/lounge_shelf_bottles.png',
      'jukebox_facade':
          'restaurant_tycoon_3d/assets/textures/jukebox_facade.png',
      'idle_diner_neon':
          'restaurant_tycoon_3d/assets/textures/idle_diner_neon.png',
      'the_milk_shake_neon':
          'restaurant_tycoon_3d/assets/textures/the_milk_shake_neon.png',
      'wood_parquet':
          'restaurant_tycoon_3d/assets/textures/wood_parquet.png',

      // ── 3D Isometric Sprites ──────────────────────────────────────────────
      'booth': 'assets/sprites/booth.png',
      'stove': 'assets/sprites/stove.png',
      'chef': 'assets/sprites/chef.png',
      'waiter': 'assets/sprites/waiter.png',
      'customer': 'assets/sprites/customer.png',
      'customer_vip': 'assets/sprites/customer_vip.png',
      'car_taxi': 'assets/sprites/car_taxi.png',
      'car_sedan': 'assets/sprites/car_sedan.png',
      'car_suv': 'assets/sprites/car_suv.png',
      'car_delivery': 'assets/sprites/car_delivery.png',
      'car_sport': 'assets/sprites/car_sport.png',

      // ── Status & Bubble Sprites ───────────────────────────────────────────
      'bubble_fork_knife': 'assets/sprites/bubble_fork_knife.png',
      'bubble_hourglass': 'assets/sprites/bubble_hourglass.png',
      'bubble_cash_stack': 'assets/sprites/bubble_cash_stack.png',
    };

    final futures = assetPaths.entries.map((entry) async {
      try {
        final data = await rootBundle.load(entry.value);
        final codec =
            await ui.instantiateImageCodec(data.buffer.asUint8List());
        final frame = await codec.getNextFrame();
        _images[entry.key] = frame.image;
      } catch (e) {
        if (kDebugMode) {
          print('SpriteCache: Failed to load ${entry.key}: $e');
        }
      }
    });

    await Future.wait(futures);
    isLoaded = true;
  }
}
