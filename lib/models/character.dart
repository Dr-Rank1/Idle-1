import 'dart:ui';
import 'enums.dart';

/// A character (guest or staff) moving around the resort.
class Character {
  final String id;
  final CharacterType type;
  CharacterState state;

  // Grid position (floating point for smooth movement)
  double gx;
  double gy;

  // Target grid position for walking
  double targetGx;
  double targetGy;

  // Waypoint queue for multi-step paths
  final List<Offset> waypoints = [];

  // Timers
  double stateTimer = 0.0; // seconds remaining in current state
  double patience = 0.0;   // guest patience (0 = leaves unhappy)

  // Earning from this visit
  double earnValue = 0.0;

  // Which table/room/station is assigned
  String? assignedStationId;

  // Animation frame
  double walkCycle = 0.0;
  FacingDirection facing = FacingDirection.southEast;

  // Visual: floating cash label
  String? floatingLabel;
  double floatingLabelTimer = 0.0;

  // Tint color override (for mood/event indicators)
  Color? tintColor;

  // VIP flag
  bool isVip = false;

  // Staff progression & management
  int level = 1;
  double speedMultiplier = 1.0;
  double cookingMultiplier = 1.0;
  double servingMultiplier = 1.0;
  int carryCapacity = 1;
  double fatigue = 0.0; // 0.0 (fresh) to 1.0 (exhausted)
  bool isOnBreak = false;
  double breakroomTimer = 0.0;
  bool hasSpeedBuff = false;
  double speedBuffTimer = 0.0;

  Character({
    required this.id,
    required this.type,
    required this.gx,
    required this.gy,
    this.state = CharacterState.arriving,
    this.patience = 30.0,
    this.level = 1,
    this.speedMultiplier = 1.0,
    this.cookingMultiplier = 1.0,
    this.servingMultiplier = 1.0,
    this.carryCapacity = 1,
    this.fatigue = 0.0,
    this.isOnBreak = false,
  }) : targetGx = gx,
       targetGy = gy;

  bool get isMoving =>
      (gx - targetGx).abs() > 0.01 || (gy - targetGy).abs() > 0.01;

  bool get isGuest => type == CharacterType.guest;
  bool get isStaff => !isGuest;
}
