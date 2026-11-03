import 'package:flutter_test/flutter_test.dart';
import 'package:screw_escape/src/features/gameplay/domain/models/board_status.dart';
import 'package:screw_escape/src/features/gameplay/domain/models/game_state.dart';
import 'package:screw_escape/src/features/gameplay/domain/models/game_status.dart';
import 'package:screw_escape/src/features/gameplay/domain/models/screw_state.dart';
import 'package:screw_escape/src/features/gameplay/domain/models/wooden_board_state.dart';
import 'package:screw_escape/src/features/gameplay/domain/solver/puzzle_solver.dart';

void main() {
  group('TASK-002-06: Canonical BFS State Key and PuzzleSolver Tests', () {
    test('canonicalStateKey produces deterministic string regardless of map or set insertion order', () {
      // State 1: boards inserted 1 then 2, screws attached 'a' then 'b'
      final state1 = GameState(
        boards: {
          'board_1': WoodenBoardState(
            id: 'board_1',
            left: 0,
            top: 0,
            width: 100,
            height: 50,
            zIndex: 0,
            attachedScrewIds: {'screw_1a', 'screw_1b'},
          ),
          'board_2': WoodenBoardState(
            id: 'board_2',
            left: 0,
            top: 60,
            width: 100,
            height: 50,
            zIndex: 1,
            attachedScrewIds: {'screw_2a', 'screw_2b'},
          ),
        },
        screws: {
          'screw_1a': ScrewState(id: 'screw_1a', boardId: 'board_1', x: 20, y: 25),
          'screw_1b': ScrewState(id: 'screw_1b', boardId: 'board_1', x: 80, y: 25),
          'screw_2a': ScrewState(id: 'screw_2a', boardId: 'board_2', x: 20, y: 85),
          'screw_2b': ScrewState(id: 'screw_2b', boardId: 'board_2', x: 80, y: 85),
        },
      );

      // State 2: reverse map and set insertion order
      final state2 = GameState(
        boards: {
          'board_2': WoodenBoardState(
            id: 'board_2',
            left: 0,
            top: 60,
            width: 100,
            height: 50,
            zIndex: 1,
            attachedScrewIds: {'screw_2b', 'screw_2a'}, // Reversed set order
          ),
          'board_1': WoodenBoardState(
            id: 'board_1',
            left: 0,
            top: 0,
            width: 100,
            height: 50,
            zIndex: 0,
            attachedScrewIds: {'screw_1b', 'screw_1a'}, // Reversed set order
          ),
        },
        screws: {
          'screw_2b': ScrewState(id: 'screw_2b', boardId: 'board_2', x: 80, y: 85),
          'screw_1a': ScrewState(id: 'screw_1a', boardId: 'board_1', x: 20, y: 25),
          'screw_2a': ScrewState(id: 'screw_2a', boardId: 'board_2', x: 20, y: 85),
          'screw_1b': ScrewState(id: 'screw_1b', boardId: 'board_1', x: 80, y: 25),
        },
      );

      final key1 = canonicalStateKey(state1);
      final key2 = canonicalStateKey(state2);

      expect(key1, equals(key2));
      expect(key1, contains('B:board_1:pinned:[screw_1a,screw_1b];board_2:pinned:[screw_2a,screw_2b]'));
      expect(key1, contains('#S:screw_1a:board;screw_1b:board;screw_2a:board;screw_2b:board'));
      expect(key1, contains('#T:_,_,_#G:playing'));
    });

    test('canonicalStateKey produces distinct keys when any transition state variable changes', () {
      final base = GameState(
        boards: {
          'board_1': WoodenBoardState(
            id: 'board_1',
            left: 0,
            top: 0,
            width: 100,
            height: 50,
            zIndex: 0,
            attachedScrewIds: {'screw_1a'},
          ),
        },
        screws: {
          'screw_1a': ScrewState(id: 'screw_1a', boardId: 'board_1', x: 20, y: 25),
        },
      );

      final baseKey = canonicalStateKey(base);

      // Change board status
      final sStatus = base.clone()..boards['board_1']!.status = BoardStatus.cleared;
      expect(canonicalStateKey(sStatus), isNot(equals(baseKey)));

      // Change screw attached
      final sAttached = base.clone()..boards['board_1']!.attachedScrewIds.clear();
      expect(canonicalStateKey(sAttached), isNot(equals(baseKey)));

      // Change screw traySlot
      final sTraySlot = base.clone()..screws['screw_1a']!.traySlot = 0;
      expect(canonicalStateKey(sTraySlot), isNot(equals(baseKey)));

      // Change tray order
      final sTray = base.clone()..traySlots[0] = 'screw_1a';
      expect(canonicalStateKey(sTray), isNot(equals(baseKey)));

      // Change game status
      final sWon = base.clone()..status = GameStatus.won;
      expect(canonicalStateKey(sWon), isNot(equals(baseKey)));
    });

    test('PuzzleSolver solves a simple 1-board puzzle optimally', () {
      final miniLevel = GameState(
        boards: {
          'board_1': WoodenBoardState(
            id: 'board_1',
            left: 0,
            top: 0,
            width: 100,
            height: 50,
            zIndex: 0,
            attachedScrewIds: {'screw_1a', 'screw_1b'},
          ),
        },
        screws: {
          'screw_1a': ScrewState(id: 'screw_1a', boardId: 'board_1', x: 20, y: 25),
          'screw_1b': ScrewState(id: 'screw_1b', boardId: 'board_1', x: 80, y: 25),
        },
      );

      final result = PuzzleSolver.solve(miniLevel);

      expect(result.isSolvable, isTrue);
      expect(result.shortestPath.length, equals(2));
      expect(result.shortestPath.contains('screw_1a'), isTrue);
      expect(result.shortestPath.contains('screw_1b'), isTrue);
      expect(result.statesVisited, greaterThan(0));
    });

    test('PuzzleSolver correctly reports unsolvable deadlock state', () {
      final deadlockedState = GameState(
        boards: {
          'board_1': WoodenBoardState(
            id: 'board_1',
            left: 0,
            top: 0,
            width: 100,
            height: 50,
            zIndex: 0,
            attachedScrewIds: {'screw_1a'},
          ),
        },
        screws: {
          'screw_1a': ScrewState(id: 'screw_1a', boardId: 'board_1', x: 20, y: 25),
        },
        traySlots: ['x', 'y', 'z'], // All 3 slots full
        status: GameStatus.lost,
      );

      final result = PuzzleSolver.solve(deadlockedState);

      expect(result.isSolvable, isFalse);
      expect(result.shortestPath, isEmpty);
      expect(result.deadlocksFound, greaterThanOrEqualTo(1));
    });
  });
}

