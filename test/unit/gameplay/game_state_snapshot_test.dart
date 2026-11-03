import 'package:flutter_test/flutter_test.dart';
import 'package:screw_escape/src/features/gameplay/domain/models/game_status.dart';
import 'package:screw_escape/src/features/gameplay/domain/models/game_state_snapshot.dart';
import 'package:screw_escape/src/features/gameplay/domain/models/move_result.dart';
import 'package:screw_escape/src/features/gameplay/domain/models/screw_state.dart';
import 'package:screw_escape/src/features/gameplay/domain/models/wooden_board_state.dart';

void main() {
  group('TASK-002-02: GameStateSnapshot & MoveResult Models Tests', () {
    test('MoveResult holds correct transition properties', () {
      final result = MoveResult(
        screwId: 'screw_1a',
        traySlot: 0,
        boardDropped: true,
        droppedBoardId: 'board_1',
        clearedScrewIds: ['screw_1a'],
      );

      expect(result.screwId, equals('screw_1a'));
      expect(result.traySlot, equals(0));
      expect(result.boardDropped, isTrue);
      expect(result.droppedBoardId, equals('board_1'));
      expect(result.clearedScrewIds, equals(['screw_1a']));
    });

    test('MoveResult defaults clearedScrewIds to empty list', () {
      final result = MoveResult(
        screwId: 'screw_1a',
        traySlot: 1,
        boardDropped: false,
      );

      expect(result.boardDropped, isFalse);
      expect(result.droppedBoardId, isNull);
      expect(result.clearedScrewIds, isEmpty);
    });

    test('GameStateSnapshot creates deep copies and clone isolates all inner state', () {
      final originalBoards = {
        'board_1': WoodenBoardState(
          id: 'board_1',
          left: 40.0,
          top: 310.0,
          width: 280.0,
          height: 50.0,
          zIndex: 0,
          attachedScrewIds: {'screw_1a'},
        ),
      };

      final originalScrews = {
        'screw_1a': ScrewState(
          id: 'screw_1a',
          boardId: 'board_1',
          x: 75.0,
          y: 335.0,
        ),
      };

      final originalTraySlots = <String?>['screw_1a', null, null];

      final snapshot = GameStateSnapshot(
        boards: originalBoards,
        screws: originalScrews,
        traySlots: originalTraySlots,
        status: GameStatus.playing,
      );

      // Verify snapshot values
      expect(snapshot.boards.containsKey('board_1'), isTrue);
      expect(snapshot.screws.containsKey('screw_1a'), isTrue);
      expect(snapshot.traySlots, equals(['screw_1a', null, null]));
      expect(snapshot.status, equals(GameStatus.playing));

      // Mutate the original sources to prove snapshot has independent memory
      originalBoards['board_1']!.attachedScrewIds.clear();
      originalScrews['screw_1a']!.traySlot = 2;
      originalTraySlots[0] = null;

      expect(snapshot.boards['board_1']!.attachedScrewIds, equals({'screw_1a'}));
      expect(snapshot.screws['screw_1a']!.traySlot, isNull);
      expect(snapshot.traySlots[0], equals('screw_1a'));

      // Test clone() deep copy on snapshot itself
      final clonedSnapshot = snapshot.clone();
      expect(clonedSnapshot.boards['board_1']!.attachedScrewIds, equals({'screw_1a'}));

      clonedSnapshot.boards['board_1']!.attachedScrewIds.add('screw_1b');
      clonedSnapshot.traySlots[1] = 'screw_2a';

      // Original snapshot must remain completely unaffected
      expect(snapshot.boards['board_1']!.attachedScrewIds, equals({'screw_1a'}));
      expect(snapshot.traySlots[1], isNull);
    });
  });
}
