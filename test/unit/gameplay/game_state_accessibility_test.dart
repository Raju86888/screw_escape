import 'package:flutter_test/flutter_test.dart';
import 'package:screw_escape/src/features/gameplay/domain/models/board_status.dart';
import 'package:screw_escape/src/features/gameplay/domain/models/game_state.dart';
import 'package:screw_escape/src/features/gameplay/domain/models/screw_state.dart';
import 'package:screw_escape/src/features/gameplay/domain/models/wooden_board_state.dart';

void main() {
  group('TASK-002-03: Dynamic Geometric Screw Accessibility Tests', () {
    late GameState gameState;

    setUp(() {
      // 3 boards modeling Level 1's vertical overlap:
      // Board 1 (Oak, z:0, Y: 310..360, X: 40..320)
      // Board 2 (Walnut, z:1, Y: 210..260, X: 40..320)
      // Board 3 (Teak, z:2, Y: 140..400, X: 150..210) - overlaps middle of Board 1 & Board 2
      final boards = {
        'board_1': WoodenBoardState(
          id: 'board_1',
          left: 40.0,
          top: 310.0,
          width: 280.0,
          height: 50.0,
          zIndex: 0,
          attachedScrewIds: {'screw_1a', 'screw_1b'},
        ),
        'board_2': WoodenBoardState(
          id: 'board_2',
          left: 40.0,
          top: 210.0,
          width: 280.0,
          height: 50.0,
          zIndex: 1,
          attachedScrewIds: {'screw_2a', 'screw_2b'},
        ),
        'board_3': WoodenBoardState(
          id: 'board_3',
          left: 150.0,
          top: 140.0,
          width: 60.0,
          height: 260.0,
          zIndex: 2,
          attachedScrewIds: {'screw_3a', 'screw_3b'},
        ),
      };

      final screws = {
        'screw_1a': ScrewState(id: 'screw_1a', boardId: 'board_1', x: 75.0, y: 335.0),
        'screw_1b': ScrewState(id: 'screw_1b', boardId: 'board_1', x: 180.0, y: 335.0), // Covered by Board 3
        'screw_2a': ScrewState(id: 'screw_2a', boardId: 'board_2', x: 75.0, y: 235.0),
        'screw_2b': ScrewState(id: 'screw_2b', boardId: 'board_2', x: 180.0, y: 235.0), // Covered by Board 3
        'screw_3a': ScrewState(id: 'screw_3a', boardId: 'board_3', x: 180.0, y: 170.0), // Top of Board 3
        'screw_3b': ScrewState(id: 'screw_3b', boardId: 'board_3', x: 180.0, y: 375.0), // Bottom of Board 3
      };

      gameState = GameState(boards: boards, screws: screws);
    });

    test('Rule 1: Screw in tray is never accessible', () {
      expect(gameState.isScrewAccessible('screw_3a'), isTrue);
      gameState.screws['screw_3a']!.traySlot = 0;
      expect(gameState.isScrewAccessible('screw_3a'), isFalse);
    });

    test('Rule 2: Screw on non-pinned board is never accessible', () {
      expect(gameState.isScrewAccessible('screw_3a'), isTrue);
      gameState.boards['board_3']!.status = BoardStatus.falling;
      expect(gameState.isScrewAccessible('screw_3a'), isFalse);

      gameState.boards['board_3']!.status = BoardStatus.cleared;
      expect(gameState.isScrewAccessible('screw_3a'), isFalse);
    });

    test('Rule 3: Occluded screw is inaccessible while covering board is pinned', () {
      // screw_1b and screw_2b are at x=180, which is covered by Board 3 (X in [150, 210])
      expect(gameState.isScrewAccessible('screw_1b'), isFalse);
      expect(gameState.isScrewAccessible('screw_2b'), isFalse);

      // Uncovered screws at x=75 are accessible
      expect(gameState.isScrewAccessible('screw_1a'), isTrue);
      expect(gameState.isScrewAccessible('screw_2a'), isTrue);
    });

    test('Rule 4: Topmost layer board screws are unconditionally accessible', () {
      // Board 3 has zIndex 2 (highest); both screws are accessible
      expect(gameState.isScrewAccessible('screw_3a'), isTrue);
      expect(gameState.isScrewAccessible('screw_3b'), isTrue);
    });

    test('Dynamic recomputation: Covered screws become accessible when covering board clears', () {
      expect(gameState.isScrewAccessible('screw_2b'), isFalse);
      expect(gameState.isScrewAccessible('screw_1b'), isFalse);

      // Mark Board 3 as cleared
      gameState.boards['board_3']!.status = BoardStatus.cleared;

      // Both screws immediately evaluate as accessible dynamically
      expect(gameState.isScrewAccessible('screw_2b'), isTrue);
      expect(gameState.isScrewAccessible('screw_1b'), isTrue);
    });

    test('Unknown screw id returns false safely', () {
      expect(gameState.isScrewAccessible('unknown_screw'), isFalse);
    });
  });
}
