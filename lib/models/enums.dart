/// Every type of zone in the hotel resort.
enum ZoneType {
  entrance,
  lobby,
  reception,
  kitchen,
  diningRoom,
  hotelRoom,
  pool,
  lounge,
  milkshakeDiner,
  breakroom,
  managerOffice,
  restroom,
  parking,
}

/// What a character is doing right now.
enum CharacterState {
  // Guest states
  arriving,
  walkingToReception,
  queuingAtReception,
  checkingIn,
  walkingToDining,
  queuingAtTable,
  seated,
  eating,
  walkingToRoom,
  inRoom,
  checkingOut,
  leaving,

  // Staff states
  idle,
  cooking,
  walkingToTable,
  serving,
  cleaning,
  walkingToKitchen,
  carryingFood,
  onBreak,
  visitingLockers,
  inspectingFloor,
}

/// Type of character.
enum CharacterType {
  guest,
  receptionist,
  chef,
  waiter,
  maid,
  hostess,
  bartender,
  barista,
  janitor,
  manager,
}

/// Rarity for manager cards.
enum ManagerRarity { common, rare, epic, legendary }

/// Direction character is facing (for sprite mirroring).
enum FacingDirection { southEast, southWest, northEast, northWest }
