import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:screw_escape/src/features/gameplay/domain/levels/level_1_data.dart';
import 'package:screw_escape/src/features/gameplay/domain/models/board_status.dart';
import 'package:screw_escape/src/features/gameplay/domain/models/game_status.dart';
import 'package:screw_escape/src/features/gameplay/domain/solver/puzzle_solver.dart';

void main() {
  group('TASK-002-07: Level 1 Solvability Verification & Benchmark Telemetry', () {
    test('Level 1 is mathematically solvable in 6 moves using PuzzleSolver & GameState.applyMove', () {
      final level = Level1Data.create();

      // Benchmark measurement telemetry
      final stopwatch = Stopwatch()..start();
      final result = PuzzleSolver.solve(level);
      stopwatch.stop();

      final elapsedMs = stopwatch.elapsedMilliseconds;
      // Record telemetry for performance monitoring
      // ignore: avoid_print
      print(
        'TELEMETRY [TASK-002-07] Level 1 BFS Benchmark: ${elapsedMs}ms | '
        'States Visited: ${result.statesVisited} | '
        'Deadlocks: ${result.deadlocksFound} | '
        'Platform: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
      );

      // Mandatory Solvability & Correctness Assertions
      expect(result.isSolvable, isTrue);
      expect(result.shortestPath.length, equals(6));
      expect(result.statesVisited, equals(53));
      expect(result.deadlocksFound, equals(12));

      // Benchmark Target Advisory Check (< 5ms target)
      // Note: As specified in TASK-002-07, < 5ms is a monitored benchmark target rather
      // than a hard failure to avoid brittle failures on heavily throttled test runners.
      if (elapsedMs >= 5) {
        // ignore: avoid_print
        print('BENCHMARK WARNING: BFS execution time (${elapsedMs}ms) exceeded 5ms target.');
      }

      // Verify the canonical top-down winning sequence explicitly:
      // Board 3 (Top) -> Board 2 (Middle) -> Board 1 (Bottom)
      final canonicalLevel = Level1Data.create();

      // Move 1 & 2: Board 3
      canonicalLevel.applyMove('screw_3a');
      final r2 = canonicalLevel.applyMove('screw_3b');
      expect(r2.boardDropped, isTrue);
      canonicalLevel.finalizeBoardClear(r2.droppedBoardId!);
      expect(canonicalLevel.boards['board_3']!.status, equals(BoardStatus.cleared));
      expect(canonicalLevel.traySlots, equals([null, null, null]));

      // Move 3 & 4: Board 2
      canonicalLevel.applyMove('screw_2a');
      final r4 = canonicalLevel.applyMove('screw_2b');
      expect(r4.boardDropped, isTrue);
      canonicalLevel.finalizeBoardClear(r4.droppedBoardId!);
      expect(canonicalLevel.boards['board_2']!.status, equals(BoardStatus.cleared));
      expect(canonicalLevel.traySlots, equals([null, null, null]));

      // Move 5 & 6: Board 1
      canonicalLevel.applyMove('screw_1a');
      final r6 = canonicalLevel.applyMove('screw_1b');
      expect(r6.boardDropped, isTrue);
      canonicalLevel.finalizeBoardClear(r6.droppedBoardId!);
      expect(canonicalLevel.boards['board_1']!.status, equals(BoardStatus.cleared));
      expect(canonicalLevel.traySlots, equals([null, null, null]));

      // Final status must be won
      expect(canonicalLevel.status, equals(GameStatus.won));
    });

    test('Covered screws dynamically become accessible when covering board falls', () {
      final level = Level1Data.create();

      // Initially covered
      expect(level.isScrewAccessible('screw_2b'), isFalse);
      expect(level.isScrewAccessible('screw_1b'), isFalse);

      // Unscrew Board 3
      level.applyMove('screw_3a');
      final rDrop = level.applyMove('screw_3b');
      level.finalizeBoardClear(rDrop.droppedBoardId!);

      expect(level.boards['board_3']!.status, equals(BoardStatus.cleared));

      // Screws on Board 2 and Board 1 are now dynamically accessible
      expect(level.isScrewAccessible('screw_2b'), isTrue);
      expect(level.isScrewAccessible('screw_1b'), isTrue);
    });

    test('Filling all 3 tray slots without dropping a board triggers GameStatus.lost', () {
      final level = Level1Data.create();

      // Tap 1 screw from each board (leaves 1 attached screw on each board)
      level.applyMove('screw_1a'); // Slot 0
      level.applyMove('screw_2a'); // Slot 1
      level.applyMove('screw_3a'); // Slot 2

      // Tray is now completely full
      expect(level.traySlots, equals(['screw_1a', 'screw_2a', 'screw_3a']));
      // No board has 0 screws attached
      expect(level.boards['board_1']!.attachedScrewIds, equals({'screw_1b'}));
      expect(level.boards['board_2']!.attachedScrewIds, equals({'screw_2b'}));
      expect(level.boards['board_3']!.attachedScrewIds, equals({'screw_3b'}));

      // Evaluate lose condition
      level.evaluateLoseCondition();

      // Deadlock condition verified
      expect(level.status, equals(GameStatus.lost));
    });

    test('Lossless Undo restores exact pre-move state deterministically on Level 1', () {
      final level = Level1Data.create();

      expect(level.traySlots, equals([null, null, null]));
      expect(level.isScrewAccessible('screw_2b'), isFalse);

      // Make a move
      level.applyMove('screw_3a');
      expect(level.traySlots, equals(['screw_3a', null, null]));

      // Undo move
      final undoSuccess = level.undo();
      expect(undoSuccess, isTrue);
      expect(level.traySlots, equals([null, null, null]));
      expect(level.screws['screw_3a']!.isInTray, isFalse);
      expect(level.boards['board_3']!.attachedScrewIds.contains('screw_3a'), isTrue);

      // Make 2 moves to drop Board 3
      level.applyMove('screw_3a');
      final rDrop = level.applyMove('screw_3b');
      level.finalizeBoardClear(rDrop.droppedBoardId!);
      expect(level.boards['board_3']!.status, equals(BoardStatus.cleared));
      expect(level.isScrewAccessible('screw_2b'), isTrue);

      // Undo the drop move
      level.undo();
      expect(level.boards['board_3']!.status, equals(BoardStatus.pinned));
      expect(level.isScrewAccessible('screw_2b'), isFalse); // Dynamically covered again
    });
  });
}
