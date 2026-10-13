import 'dart:ui';

/// A floating "+$120" cash/tip particle on screen.
class FloatingLabel {
  final String id;
  final String text;
  final Color color;
  Offset screenPos;
  double life; // 0.0→1.0, decreases over time
  double opacity;
  double scale;

  FloatingLabel({
    required this.id,
    required this.text,
    required this.screenPos,
    this.color = const Color(0xFF4CAF50),
    this.life = 1.0,
    this.opacity = 1.0,
    this.scale = 1.0,
  });
}

/// A particle (confetti, steam, sparkle).
class Particle {
  final String id;
  Offset pos;
  Offset velocity;
  double life;
  final Color color;
  final double size;

  Particle({
    required this.id,
    required this.pos,
    required this.velocity,
    required this.color,
    required this.size,
    this.life = 1.0,
  });
}
