import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_resort_tycoon/logic/game_state.dart';
import 'package:hotel_resort_tycoon/models/enums.dart';
import 'package:hotel_resort_tycoon/services/save_service.dart';
import 'package:hotel_resort_tycoon/utils/iso_math.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('IsoMath Tests', () {
    test('gridToScreen and screenToGrid roundtrip', () {
      const gx = 5.0;
      const gy = 7.0;
      final screen = IsoMath.gridToScreen(gx, gy);
      final grid = IsoMath.screenToGrid(screen.dx, screen.dy);

      expect(grid.dx, closeTo(gx, 0.001));
      expect(grid.dy, closeTo(gy, 0.001));
    });

    test('depthKey calculation', () {
      expect(IsoMath.depthKey(2, 3), equals(5));
      expect(IsoMath.depthKey(4, 5), greaterThan(IsoMath.depthKey(2, 3)));
    });
  });

  group('GameState Economy and Upgrades', () {
    late GameState gameState;

    setUp(() {
      gameState = GameState();
    });

    test('Initial state parameters', () {
      expect(gameState.cash, equals(500.0));
      expect(gameState.reputation, equals(1));
      expect(gameState.stations.isNotEmpty, isTrue);
      expect(gameState.managers.isNotEmpty, isTrue);
      expect(gameState.prestigeStars, equals(0));
      expect(gameState.prestigeMultiplier, equals(1.0));
    });

    test('Station upgrading works when affordable', () {
      final station = gameState.stations.first;
      final initialLevel = station.level;
      final cost = station.upgradeCost;

      // Ensure we have enough cash
      gameState.cash = cost + 100;
      final success = gameState.upgradeStation(station.id);

      expect(success, isTrue);
      expect(station.level, equals(initialLevel + 1));
      expect(gameState.cash, equals(100));
    });

    test('Station upgrading fails when unaffordable', () {
      final station = gameState.stations.first;
      gameState.cash = 0;
      final success = gameState.upgradeStation(station.id);

      expect(success, isFalse);
    });

    test('Manager recruitment and boost application', () {
      final manager = gameState.managers.firstWhere(
        (m) => m.id == 'chef_pierre',
      );
      expect(manager.isUnlocked, isFalse);

      // Give enough cash to recruit legendary manager
      gameState.cash = 50000;
      final recruited = gameState.recruitManager(manager.id);
      expect(recruited, isTrue);
      expect(manager.isUnlocked, isTrue);

      // Assign manager and verify kitchen station boosts
      final assigned = gameState.assignManager(manager.id);
      expect(assigned, isTrue);
      expect(manager.isAssigned, isTrue);

      final kitchenStove = gameState.stations.firstWhere(
        (s) => s.zone == ZoneType.kitchen,
      );
      expect(kitchenStove.incomeMultiplier, equals(manager.incomeBoost));
      expect(kitchenStove.speedMultiplier, equals(manager.speedBoost));
    });
  });

  group('Prestige and Franchise Mechanics', () {
    late GameState gameState;

    setUp(() {
      gameState = GameState();
    });

    test('Prestige availability and star calculations', () {
      expect(gameState.canPrestige, isFalse);

      // Accumulate revenue
      gameState.totalEarned = 25000.0;
      expect(gameState.canPrestige, isTrue);
      expect(gameState.starsToEarnOnPrestige, greaterThanOrEqualTo(1));

      final stars = gameState.starsToEarnOnPrestige;
      final initialRep = gameState.reputation;
      final didReset = gameState.prestigeReset();

      expect(didReset, isTrue);
      expect(gameState.prestigeStars, equals(stars));
      expect(gameState.reputation, equals(initialRep + 1));
      expect(gameState.prestigeMultiplier, greaterThan(1.0));
      expect(gameState.stations.every((s) => s.level == 1), isTrue);
      expect(gameState.cash, equals(500.0 * (1 + stars)));
    });
  });

  group('Interactive Clicker Rush Mechanics', () {
    late GameState gameState;

    setUp(() {
      gameState = GameState();
    });

    test('Tapping cooking stove rushes cooking progress', () {
      final stove = gameState.stations.firstWhere(
        (s) => s.zone == ZoneType.kitchen,
      );
      stove.foodReady = false;
      stove.cookTimer = 1.0;

      final rushed = gameState.rushActionAt(stove.centerGrid);

      expect(rushed, isTrue);
      expect(stove.cookTimer, greaterThan(1.0));
      expect(gameState.floatingLabels.any((l) => l.text.contains('CHEF RUSH')), isTrue);
    });

    test('Tapping dirty hotel room rushes maid cleaning', () {
      final room = gameState.stations.firstWhere(
        (s) => s.zone == ZoneType.hotelRoom,
      );
      room.isDirty = true;
      room.cleanTimer = 0.0;

      final rushed = gameState.rushActionAt(room.centerGrid);

      expect(rushed, isTrue);
      expect(gameState.floatingLabels.any((l) => l.text.contains('QUICK CLEAN')), isTrue);
    });
  });

  group('SaveService Tests', () {
    late GameState gameState;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      gameState = GameState();
    });

    test('Save and load state persistence including prestige', () async {
      gameState.cash = 12345.0;
      gameState.hotelName = 'Grand Paradise Resort';
      gameState.prestigeStars = 4;
      gameState.stations.first.level = 5;

      await SaveService.save(gameState);

      final newGameState = GameState();
      await SaveService.load(newGameState);

      expect(newGameState.cash, equals(12345.0));
      expect(newGameState.hotelName, equals('Grand Paradise Resort'));
      expect(newGameState.prestigeStars, equals(4));
      expect(newGameState.stations.first.level, equals(5));
      expect(newGameState.prestigeMultiplier, equals(1.0 + (4 * 0.25)));
    });

    test('Save and load state persistence for Piggy Bank, Recipe Book, and Sector Managers', () async {
      gameState.depositPiggyBank(75);
      gameState.unlockedStarTiers.addAll([2, 3]);
      gameState.claimedStarRewards.add(2);
      gameState.sectorManagers['kitchen']!.tier = 'executive';

      await SaveService.save(gameState);

      final newGameState = GameState();
      await SaveService.load(newGameState);

      expect(newGameState.piggyBankBalance, equals(75));
      expect(newGameState.unlockedStarTiers.contains(2), isTrue);
      expect(newGameState.unlockedStarTiers.contains(3), isTrue);
      expect(newGameState.isStarRewardClaimed(2), isTrue);
      expect(newGameState.sectorManagers['kitchen']!.tier, equals('executive'));
    });
  });

  group('Golden Piggy Bank Mechanics', () {
    late GameState gameState;

    setUp(() {
      gameState = GameState();
    });

    test('Piggy bank deposits up to cap of 250 diamonds', () {
      expect(gameState.piggyBankBalance, equals(0));
      expect(gameState.isPiggyBankFull, isFalse);

      gameState.depositPiggyBank(50);
      expect(gameState.piggyBankBalance, equals(50));

      gameState.depositPiggyBank(300);
      expect(gameState.piggyBankBalance, equals(250));
      expect(gameState.isPiggyBankFull, isTrue);
    });

    test('Smashing piggy bank awards saved diamonds to gems and resets balance', () {
      final initialGems = gameState.gems;
      gameState.depositPiggyBank(100);

      final claimed = gameState.smashPiggyBank();
      expect(claimed, equals(100));
      expect(gameState.piggyBankBalance, equals(0));
      expect(gameState.gems, equals(initialGems + 100));

      // Smashing empty piggy bank claims 0
      final emptyClaim = gameState.smashPiggyBank();
      expect(emptyClaim, equals(0));
    });

    test('Upgrading station deposits diamonds to piggy bank', () {
      gameState.cash = 10000.0;
      final station = gameState.stations.first;
      expect(gameState.piggyBankBalance, equals(0));

      final success = gameState.upgradeStation(station.id);
      expect(success, isTrue);
      expect(gameState.piggyBankBalance, greaterThanOrEqualTo(1));
    });
  });

  group('5-Star Recipe Book Progression', () {
    late GameState gameState;

    setUp(() {
      gameState = GameState();
    });

    test('Initial star tier 1 is unlocked and rewards can be claimed', () {
      expect(gameState.isStarDishUnlocked(1), isTrue);
      expect(gameState.isStarRewardClaimed(1), isFalse);

      final initialGems = gameState.gems;
      final claimed = gameState.claimStarDishReward(1);

      expect(claimed, isTrue);
      expect(gameState.gems, equals(initialGems + 25));
      expect(gameState.isStarRewardClaimed(1), isTrue);

      // Duplicate claims rejected
      final duplicateClaim = gameState.claimStarDishReward(1);
      expect(duplicateClaim, isFalse);
    });

    test('Level progression automatically unlocks star dish tiers', () {
      expect(gameState.isStarDishUnlocked(2), isFalse);

      // Level up to 3 for Tier 2
      gameState.restaurantLevel = 3;
      gameState.checkStarDishUnlocks();
      expect(gameState.isStarDishUnlocked(2), isTrue);
      expect(gameState.activeRecipeMultiplier, greaterThanOrEqualTo(2.5));

      // Level up to 15 for 5-Star Michelin Feast
      gameState.restaurantLevel = 15;
      gameState.checkStarDishUnlocks();
      expect(gameState.isStarDishUnlocked(5), isTrue);
      expect(gameState.activeRecipeMultiplier, equals(10.0));
    });
  });

  group('Sector Manager Skills Mechanics', () {
    late GameState gameState;

    setUp(() {
      gameState = GameState();
    });

    test('All 4 core sector managers are initialized', () {
      expect(gameState.sectorManagers.containsKey('kitchen'), isTrue);
      expect(gameState.sectorManagers.containsKey('dining'), isTrue);
      expect(gameState.sectorManagers.containsKey('milkshake'), isTrue);
      expect(gameState.sectorManagers.containsKey('lounge'), isTrue);
      expect(gameState.isAnyManagerSkillReady(), isTrue);
      expect(gameState.readyManagerSkillsCount, equals(4));
    });

    test('Activating manager skill sets active timer and updates multipliers', () {
      expect(gameState.canActivateManagerSkill('milkshake'), isTrue);
      expect(gameState.getManagerUpgradeDiscount(), equals(0.0));

      final activated = gameState.activateManagerSkill('milkshake');
      expect(activated, isTrue);
      expect(gameState.isManagerSkillActive('milkshake'), isTrue);
      expect(gameState.getManagerUpgradeDiscount(), greaterThan(0.0));

      // Cannot re-activate while active
      expect(gameState.canActivateManagerSkill('milkshake'), isFalse);
    });

    test('Activating dining skill performs instant table clean', () {
      final room = gameState.stations.firstWhere((s) => s.zone == ZoneType.hotelRoom);
      room.isDirty = true;

      gameState.activateManagerSkill('dining');
      expect(room.isDirty, isFalse);
    });

    test('Tick processes active skill duration into cooldown', () {
      gameState.activateManagerSkill('lounge');
      final lounge = gameState.sectorManagers['lounge']!;
      expect(lounge.isActive, isTrue);

      // Advance by 65 seconds
      gameState.tick(65.0);

      expect(lounge.isActive, isFalse);
      expect(lounge.cooldownTimer, greaterThan(0.0));
      expect(gameState.canActivateManagerSkill('lounge'), isFalse);
    });

    test('Activate all manager skills triggers all available sectors', () {
      final count = gameState.activateAllManagerSkills();
      expect(count, equals(4));
      expect(gameState.readyManagerSkillsCount, equals(0));
    });
  });
}
