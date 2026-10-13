import 'dart:ui';

/// Isometric projection math helper.
/// Converts grid coordinates (gx, gy) to screen (x, y) pixels.
class IsoMath {
  static const double tileW = 80.0; // full tile width  (diamond width)
  static const double tileH = 40.0; // full tile height (diamond height)

  /// Grid → screen (top-center of tile)
  static Offset gridToScreen(double gx, double gy) {
    final sx = (gx - gy) * (tileW / 2);
    final sy = (gx + gy) * (tileH / 2);
    return Offset(sx, sy);
  }

  /// Screen → grid (approximate)
  static Offset screenToGrid(double sx, double sy) {
    final gx = (sx / (tileW / 2) + sy / (tileH / 2)) / 2;
    final gy = (sy / (tileH / 2) - sx / (tileW / 2)) / 2;
    return Offset(gx, gy);
  }

  /// Depth key for Y-sorting: lower = drawn first (further back)
  static double depthKey(double gx, double gy) => gx + gy;
}
