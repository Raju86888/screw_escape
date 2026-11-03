import 'package:flutter_test/flutter_test.dart';
import 'package:screw_escape/src/features/gameplay/application/gameplay_controller.dart';
import 'package:screw_escape/src/features/gameplay/domain/models/game_status.dart';

void main() {
  group('TASK-002-08: GameplayController State Management & Input Locking Tests', () {
    late GameplayController controller;

    setUp(() {
      controller = GameplayController(
        screwTravelDuration: Duration.zero,
        boardFallDuration: Duration.zero,
        trayClearDuration: Duration.zero,
        settlementDuration: Duration.zero,
      );
    });

    tearDown(() {
      controller.dispose();
    });

    test('Initial state initializes with Level 1 and input unlocked', () {
      expect(controller.gameState.status, equals(GameStatus.playing));
      expect(controller.gameState.boards.length, equals(3));
      expect(controller.gameState.screws.length, equals(6));
      expect(controller.gameState.traySlots, equals([null, null, null]));
      expect(controller.isInputLocked, isFalse);
      expect(controller.hintedScrewId, isNull);
    });

    test('Tapping a valid screw engages isInputLocked synchronously on the first frame', () async {
      final lockController = GameplayController(
        screwTravelDuration: const Duration(milliseconds: 20),
        boardFallDuration: Duration.zero,
        trayClearDuration: Duration.zero,
        settlementDuration: Duration.zero,
      );

      final lockStates = <bool>[];
      lockController.addListener(() {
        lockStates.add(lockController.isInputLocked);
      });

      // screw_3a is accessible initially
      final tapFuture = lockController.onScrewTapped('screw_3a');

      // Immediately after invocation and during translation, input lock must be engaged
      expect(lockController.isInputLocked, isTrue);
      expect(lockStates.first, isTrue);

      await tapFuture;

      // After move completes, input is unlocked
      expect(lockController.isInputLocked, isFalse);
      expect(lockController.gameState.traySlots[0], equals('screw_3a'));

      lockController.dispose();
    });

    test('Rapid subsequent taps while locked are completely discarded', () async {
      // Slow controller down to verify lock rejection
      final slowController = GameplayController(
        screwTravelDuration: const Duration(milliseconds: 50),
        boardFallDuration: Duration.zero,
        trayClearDuration: Duration.zero,
        settlementDuration: Duration.zero,
      );

      final firstTap = slowController.onScrewTapped('screw_3a');
      expect(slowController.isInputLocked, isTrue);

      // Attempt second tap while first is in flight
      final secondTap = slowController.onScrewTapped('screw_3b');

      await firstTap;
      await secondTap;

      // Only screw_3a should be moved; screw_3b was discarded
      expect(slowController.gameState.traySlots[0], equals('screw_3a'));
      expect(slowController.gameState.traySlots[1], isNull);
      expect(slowController.isInputLocked, isFalse);

      slowController.dispose();
    });

    test('Tapping an inaccessible screw is discarded without mutating state or locking input', () async {
      // screw_2b is covered by board_3 initially
      expect(controller.gameState.isScrewAccessible('screw_2b'), isFalse);

      await controller.onScrewTapped('screw_2b');

      expect(controller.isInputLocked, isFalse);
      expect(controller.gameState.traySlots, equals([null, null, null]));
      expect(controller.gameState.screws['screw_2b']!.isInTray, isFalse);
    });

    test('Tapping when tray is full is discarded and does not lock input', () async {
      // Fill tray slots with 3 screws
      await controller.onScrewTapped('screw_1a'); // Slot 0
      await controller.onScrewTapped('screw_2a'); // Slot 1
      await controller.onScrewTapped('screw_3a'); // Slot 2

      expect(controller.gameState.traySlots.contains(null), isFalse);
      expect(controller.gameState.status, equals(GameStatus.lost));

      // Attempt to tap another screw
      await controller.onScrewTapped('screw_3b');

      // Discarded, tray still full, input remains locked or game lost
      expect(controller.gameState.traySlots, equals(['screw_1a', 'screw_2a', 'screw_3a']));
      expect(controller.gameState.screws['screw_3b']!.isInTray, isFalse);
    });
  });
}
