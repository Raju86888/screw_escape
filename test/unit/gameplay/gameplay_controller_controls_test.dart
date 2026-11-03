import 'package:flutter_test/flutter_test.dart';
import 'package:screw_escape/src/features/gameplay/application/gameplay_controller.dart';
import 'package:screw_escape/src/features/gameplay/domain/models/game_status.dart';
import 'package:screw_escape/src/features/gameplay/domain/solver/puzzle_solver.dart';

void main() {
  group('TASK-002-10: Undo, Hint Timer Lifecycle, and Restart Tests', () {
    test('undo rolls back pre-move snapshot, clears hint halo, cancels timer, and notifies listeners', () async {
      final controller = GameplayController(
        screwTravelDuration: Duration.zero,
        boardFallDuration: Duration.zero,
        trayClearDuration: Duration.zero,
        settlementDuration: Duration.zero,
        hintDuration: const Duration(milliseconds: 60),
      );
      int notifyCount = 0;
      controller.addListener(() => notifyCount++);

      // Initially history is empty -> undo returns false
      expect(controller.undo(), isFalse);
      expect(notifyCount, equals(0));

      // Make a move: screw_3a
      await controller.onScrewTapped('screw_3a');
      expect(controller.gameState.traySlots[0], equals('screw_3a'));
      expect(controller.gameState.history.length, equals(1));

      // Request hint
      controller.requestHint();
      expect(controller.hintedScrewId, isNotNull);

      notifyCount = 0;
      // Call undo
      final success = controller.undo();
      expect(success, isTrue);
      expect(controller.gameState.traySlots[0], isNull);
      expect(controller.gameState.history, isEmpty);
      expect(controller.gameState.screws['screw_3a']!.isInTray, isFalse);
      expect(controller.hintedScrewId, isNull, reason: 'Undo must dismiss active hint halo');
      expect(notifyCount, greaterThan(0));

      // Advancing past hint duration does not trigger any stale callback or mutation
      await Future.delayed(const Duration(milliseconds: 80));
      expect(controller.hintedScrewId, isNull);

      controller.dispose();
    });

    test('undo is strictly disabled while input is locked', () async {
      final controller = GameplayController(
        screwTravelDuration: const Duration(milliseconds: 30),
        boardFallDuration: Duration.zero,
        trayClearDuration: Duration.zero,
        settlementDuration: Duration.zero,
      );

      // Start move
      final tapFuture = controller.onScrewTapped('screw_3a');
      expect(controller.isInputLocked, isTrue);

      // Attempt undo mid-animation
      final undoResult = controller.undo();
      expect(undoResult, isFalse, reason: 'Undo must be rejected while isInputLocked');

      await tapFuture;
      expect(controller.isInputLocked, isFalse);

      controller.dispose();
    });

    test('requestHint uses BFS solver to highlight first winning move for hint duration', () async {
      final controller = GameplayController(
        hintDuration: const Duration(milliseconds: 60),
      );
      expect(controller.hintedScrewId, isNull);

      final expectedTarget = PuzzleSolver.solve(controller.gameState).shortestPath.first;

      controller.requestHint();
      expect(controller.hintedScrewId, equals(expectedTarget));

      // Before expiration (30ms of 60ms) - halo must still be active
      await Future.delayed(const Duration(milliseconds: 30));
      expect(controller.hintedScrewId, isNotNull);

      // Wait until after expiration
      await Future.delayed(const Duration(milliseconds: 40));
      expect(controller.hintedScrewId, isNull);

      controller.dispose();
    });

    test('requestHint is ignored when game is already lost or won', () async {
      final controller = GameplayController(
        screwTravelDuration: Duration.zero,
        boardFallDuration: Duration.zero,
        trayClearDuration: Duration.zero,
        settlementDuration: Duration.zero,
      );
      String? toastMessage;
      controller.onToast = (msg) => toastMessage = msg;

      // Reach deadlock: 1a, 2a, 3a
      await controller.onScrewTapped('screw_1a');
      await controller.onScrewTapped('screw_2a');
      await controller.onScrewTapped('screw_3a');

      expect(controller.gameState.status, equals(GameStatus.lost));

      // Request hint in lost state
      controller.requestHint();
      expect(controller.hintedScrewId, isNull);
      expect(toastMessage, isNull);

      controller.dispose();
    });

    test('requestHint displays toast when in an unsolvable playing state', () async {
      final controller = GameplayController(
        screwTravelDuration: Duration.zero,
        boardFallDuration: Duration.zero,
        trayClearDuration: Duration.zero,
        settlementDuration: Duration.zero,
      );
      String? toastMessage;
      controller.onToast = (msg) => toastMessage = msg;

      // Moves 1a and 2a fill 2 slots without clearing boards
      await controller.onScrewTapped('screw_1a');
      await controller.onScrewTapped('screw_2a');

      expect(controller.gameState.traySlots, equals(['screw_1a', 'screw_2a', null]));
      expect(controller.gameState.status, equals(GameStatus.playing));

      // Request hint in this unwinnable active state
      controller.requestHint();

      expect(controller.hintedScrewId, isNull);
      expect(toastMessage, equals('No winning path from here. Use Undo or Restart!'));

      controller.dispose();
    });

    test('requesting a new hint cancels the existing hint timer (Timer Lifecycle Safety)', () async {
      final controller = GameplayController(
        hintDuration: const Duration(milliseconds: 60),
      );

      controller.requestHint();
      final firstHinted = controller.hintedScrewId;
      expect(firstHinted, isNotNull);

      // Wait 40ms of 60ms
      await Future.delayed(const Duration(milliseconds: 40));
      expect(controller.hintedScrewId, equals(firstHinted));

      // Request hint again (cancels old timer, resets fresh 60ms window)
      controller.requestHint();
      expect(controller.hintedScrewId, equals(firstHinted));

      // Wait 35ms (total 75ms since first hint, 35ms since second hint)
      await Future.delayed(const Duration(milliseconds: 35));
      // Must STILL be active because second hint refreshed the 60ms timer
      expect(controller.hintedScrewId, equals(firstHinted));

      // Wait another 35ms (total 70ms since second hint)
      await Future.delayed(const Duration(milliseconds: 35));
      expect(controller.hintedScrewId, isNull);

      controller.dispose();
    });

    test('restartLevel resets to pristine Level 1, clears timers/halos, and restores unlocked input', () async {
      final controller = GameplayController(
        screwTravelDuration: Duration.zero,
        boardFallDuration: Duration.zero,
        trayClearDuration: Duration.zero,
        settlementDuration: Duration.zero,
        hintDuration: const Duration(milliseconds: 60),
      );

      // Make move and request hint
      await controller.onScrewTapped('screw_3a');
      controller.requestHint();
      expect(controller.hintedScrewId, isNotNull);
      expect(controller.gameState.history.length, equals(1));
      expect(controller.gameState.traySlots[0], equals('screw_3a'));

      // Restart level
      controller.restartLevel();

      expect(controller.hintedScrewId, isNull);
      expect(controller.isInputLocked, isFalse);
      expect(controller.gameState.history, isEmpty);
      expect(controller.gameState.traySlots, equals([null, null, null]));
      expect(controller.gameState.status, equals(GameStatus.playing));
      expect(controller.gameState.boards.length, equals(3));
      expect(controller.gameState.screws['screw_3a']!.isInTray, isFalse);

      // Advancing time does not trigger stale timer
      await Future.delayed(const Duration(milliseconds: 80));
      expect(controller.hintedScrewId, isNull);

      controller.dispose();
    });

    test('dispose safely cancels timer and prevents stale callbacks from modifying controller', () async {
      final controller = GameplayController(
        hintDuration: const Duration(milliseconds: 60),
      );

      controller.requestHint();
      expect(controller.hintedScrewId, isNotNull);

      // Wait 20ms, then dispose
      await Future.delayed(const Duration(milliseconds: 20));
      controller.dispose();
      expect(controller.isDisposed, isTrue);

      // Advancing remaining time should not throw or trigger notifyListeners on disposed controller
      await Future.delayed(const Duration(milliseconds: 60));
    });

    test('undo from GameStatus.lost restores pre-deadlock state, resets status to playing, and unlocks input', () async {
      final controller = GameplayController(
        screwTravelDuration: Duration.zero,
        boardFallDuration: Duration.zero,
        trayClearDuration: Duration.zero,
        settlementDuration: Duration.zero,
      );

      // Trigger deadlock: 1a, 2a, 3a
      await controller.onScrewTapped('screw_1a');
      await controller.onScrewTapped('screw_2a');
      await controller.onScrewTapped('screw_3a');

      expect(controller.gameState.status, equals(GameStatus.lost));
      expect(controller.isInputLocked, isTrue);

      // Undo move (simulating tapping "Undo Move" on GameOverDialog)
      final success = controller.undo();
      expect(success, isTrue);
      expect(controller.gameState.status, equals(GameStatus.playing));
      expect(controller.isInputLocked, isFalse);
      expect(controller.gameState.traySlots, equals(['screw_1a', 'screw_2a', null]));

      controller.dispose();
    });

    test('restartLevel from terminal won and lost states reloads Level 1 and unlocks input', () async {
      final controller = GameplayController(
        screwTravelDuration: Duration.zero,
        boardFallDuration: Duration.zero,
        trayClearDuration: Duration.zero,
        settlementDuration: Duration.zero,
      );

      // Reach deadlock: 1a, 2a, 3a
      await controller.onScrewTapped('screw_1a');
      await controller.onScrewTapped('screw_2a');
      await controller.onScrewTapped('screw_3a');

      expect(controller.gameState.status, equals(GameStatus.lost));
      expect(controller.isInputLocked, isTrue);

      // Restart level (simulating tapping "Retry Level" on GameOverDialog)
      controller.restartLevel();
      expect(controller.gameState.status, equals(GameStatus.playing));
      expect(controller.isInputLocked, isFalse);
      expect(controller.gameState.traySlots, equals([null, null, null]));

      controller.dispose();
    });
  });
}
