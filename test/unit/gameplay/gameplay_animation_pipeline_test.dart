import 'package:flutter_test/flutter_test.dart';
import 'package:screw_escape/src/features/gameplay/application/gameplay_controller.dart';
import 'package:screw_escape/src/features/gameplay/domain/models/board_status.dart';
import 'package:screw_escape/src/features/gameplay/domain/models/game_status.dart';

void main() {
  group('TASK-002-09: Sequential Animation Pipeline & Settlement Tests', () {
    test('Non-clearing move: transitions screw, does not drop board, unlocks input', () async {
      final controller = GameplayController(
        screwTravelDuration: const Duration(milliseconds: 20),
        boardFallDuration: const Duration(milliseconds: 20),
        trayClearDuration: const Duration(milliseconds: 20),
        settlementDuration: const Duration(milliseconds: 20),
      );

      // Initially unlocked
      expect(controller.isInputLocked, isFalse);
      expect(controller.animatingScrewId, isNull);
      expect(controller.fallingBoardId, isNull);
      expect(controller.ejectingScrewIds, isEmpty);

      // Tap screw_3a (accessible on board_3)
      final tapFuture = controller.onScrewTapped('screw_3a');

      // Step 1: Input locked, animating screw
      expect(controller.isInputLocked, isTrue);
      expect(controller.animatingScrewId, equals('screw_3a'));
      expect(controller.fallingBoardId, isNull);
      expect(controller.ejectingScrewIds, isEmpty);

      await tapFuture;

      // Translation finished: screw in tray, screw animation cleared
      expect(controller.animatingScrewId, isNull);
      expect(controller.gameState.traySlots[0], equals('screw_3a'));

      // board_3 still has screw_3b, so no board drop occurs
      expect(controller.fallingBoardId, isNull);
      expect(controller.ejectingScrewIds, isEmpty);
      expect(controller.gameState.boards['board_3']!.status, equals(BoardStatus.pinned));

      // Game remains in playing status and unlocks input
      expect(controller.gameState.status, equals(GameStatus.playing));
      expect(controller.isInputLocked, isFalse);

      controller.dispose();
    });

    test('Board-clearing move: sequences screw translation -> board drop -> tray eject -> unlock', () async {
      final controller = GameplayController(
        screwTravelDuration: const Duration(milliseconds: 30),
        boardFallDuration: const Duration(milliseconds: 40),
        trayClearDuration: const Duration(milliseconds: 30),
        settlementDuration: const Duration(milliseconds: 20),
      );

      // First move: remove screw_3a
      await controller.onScrewTapped('screw_3a');
      expect(controller.isInputLocked, isFalse);

      // Second move: remove screw_3b (unlocks board_3)
      final tapFuture = controller.onScrewTapped('screw_3b');

      // Phase 1: Screw translation
      expect(controller.isInputLocked, isTrue);
      expect(controller.animatingScrewId, equals('screw_3b'));
      expect(controller.fallingBoardId, isNull);

      // Wait for screw translation to finish and board fall to begin
      await Future.delayed(const Duration(milliseconds: 35));

      // Phase 2: Board gravity drop
      expect(controller.animatingScrewId, isNull);
      expect(controller.fallingBoardId, equals('board_3'));
      expect(controller.gameState.boards['board_3']!.status, equals(BoardStatus.falling));
      expect(controller.isInputLocked, isTrue);

      // Wait for board drop to complete and tray ejection to begin
      await Future.delayed(const Duration(milliseconds: 45));

      // Phase 3: Tray screw ejection
      expect(controller.fallingBoardId, isNull);
      expect(controller.gameState.boards['board_3']!.status, equals(BoardStatus.cleared));
      expect(controller.ejectingScrewIds, equals(['screw_3a', 'screw_3b']));
      expect(controller.isInputLocked, isTrue);

      // Wait for complete sequence
      await tapFuture;

      // Animations complete and input unlocks
      expect(controller.ejectingScrewIds, isEmpty);
      expect(controller.gameState.traySlots, equals([null, null, null]));
      expect(controller.gameState.status, equals(GameStatus.playing));
      expect(controller.isInputLocked, isFalse);

      controller.dispose();
    });

    test('Winning sequence triggers onGameWon callback after settlement buffer with locked input', () async {
      final controller = GameplayController(
        screwTravelDuration: const Duration(milliseconds: 10),
        boardFallDuration: const Duration(milliseconds: 10),
        trayClearDuration: const Duration(milliseconds: 10),
        settlementDuration: const Duration(milliseconds: 40),
      );
      bool gameWonCalled = false;
      controller.onGameWon = () {
        gameWonCalled = true;
      };

      // Canonical winning sequence: 3a, 3b, 2a, 2b, 1a, 1b
      await controller.onScrewTapped('screw_3a');
      await controller.onScrewTapped('screw_3b');
      await controller.onScrewTapped('screw_2a');
      await controller.onScrewTapped('screw_2b');
      await controller.onScrewTapped('screw_1a');

      // 6th move: screw_1b -> triggers WIN!
      final winTapFuture = controller.onScrewTapped('screw_1b');

      // Wait for animations (10ms + 10ms + 10ms = 30ms), before settlement completes (40ms)
      await Future.delayed(const Duration(milliseconds: 35));

      // Terminal win reached in GameState, but settlement buffer is pending
      expect(controller.gameState.status, equals(GameStatus.won));
      expect(gameWonCalled, isFalse, reason: 'onGameWon must wait for settlement buffer');
      expect(controller.isInputLocked, isTrue);

      // Await full completion
      await winTapFuture;

      // onGameWon has now been called
      expect(gameWonCalled, isTrue);
      // Input must remain locked in terminal state
      expect(controller.isInputLocked, isTrue);

      controller.dispose();
    });

    test('Deadlock sequence triggers onGameLost callback after settlement buffer with locked input', () async {
      final controller = GameplayController(
        screwTravelDuration: const Duration(milliseconds: 10),
        boardFallDuration: const Duration(milliseconds: 10),
        trayClearDuration: const Duration(milliseconds: 10),
        settlementDuration: const Duration(milliseconds: 40),
      );
      bool gameLostCalled = false;
      controller.onGameLost = () {
        gameLostCalled = true;
      };

      // Deadlock trap: 1a, 2a, 3a
      await controller.onScrewTapped('screw_1a');
      await controller.onScrewTapped('screw_2a');

      // 3rd move: screw_3a -> fills 3rd tray slot, deadlock!
      final lostTapFuture = controller.onScrewTapped('screw_3a');

      // Wait for screw translation (10ms), before settlement (40ms)
      await Future.delayed(const Duration(milliseconds: 15));

      expect(controller.gameState.status, equals(GameStatus.lost));
      expect(gameLostCalled, isFalse, reason: 'onGameLost must wait for settlement buffer');
      expect(controller.isInputLocked, isTrue);

      // Complete settlement
      await lostTapFuture;

      expect(gameLostCalled, isTrue);
      expect(controller.isInputLocked, isTrue);

      controller.dispose();
    });

    test('Disposing controller during active animation cancels pending futures safely', () async {
      final controller = GameplayController(
        screwTravelDuration: const Duration(milliseconds: 50),
        boardFallDuration: const Duration(milliseconds: 50),
        trayClearDuration: const Duration(milliseconds: 50),
        settlementDuration: const Duration(milliseconds: 50),
      );
      bool gameWonCalled = false;
      controller.onGameWon = () {
        gameWonCalled = true;
      };

      final tapFuture = controller.onScrewTapped('screw_3a');
      expect(controller.isInputLocked, isTrue);

      // Dispose mid-flight
      await Future.delayed(const Duration(milliseconds: 15));
      controller.dispose();
      expect(controller.isDisposed, isTrue);

      await tapFuture;

      // No errors thrown, gameWon not called
      expect(gameWonCalled, isFalse);
    });
  });
}
