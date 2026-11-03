import 'package:flutter_test/flutter_test.dart';
import 'package:screw_escape/src/features/gameplay/domain/levels/level_1_data.dart';
import 'package:screw_escape/src/features/gameplay/domain/models/board_status.dart';
import 'package:screw_escape/src/features/gameplay/domain/models/game_status.dart';

void main() {
  group('TASK-002-05: Level 1 Data Definition Tests', () {
    test('Level1Data.create() builds canonical 3-board 6-screw Level 1 layout', () {
      final level = Level1Data.create();

      expect(level.status, equals(GameStatus.playing));
      expect(level.traySlots, equals([null, null, null]));
      expect(level.history, isEmpty);

      // Verify boards
      expect(level.boards.length, equals(3));
      expect(level.boards.containsKey('board_1'), isTrue);
      expect(level.boards.containsKey('board_2'), isTrue);
      expect(level.boards.containsKey('board_3'), isTrue);

      // Board 1 (Oak, bottom layer, zIndex: 0)
      final board1 = level.boards['board_1']!;
      expect(board1.id, equals('board_1'));
      expect(board1.left, equals(40.0));
      expect(board1.top, equals(310.0));
      expect(board1.width, equals(280.0));
      expect(board1.height, equals(50.0));
      expect(board1.zIndex, equals(0));
      expect(board1.status, equals(BoardStatus.pinned));
      expect(board1.attachedScrewIds, equals({'screw_1a', 'screw_1b'}));

      // Board 2 (Walnut, middle layer, zIndex: 1)
      final board2 = level.boards['board_2']!;
      expect(board2.id, equals('board_2'));
      expect(board2.left, equals(40.0));
      expect(board2.top, equals(210.0));
      expect(board2.width, equals(280.0));
      expect(board2.height, equals(50.0));
      expect(board2.zIndex, equals(1));
      expect(board2.status, equals(BoardStatus.pinned));
      expect(board2.attachedScrewIds, equals({'screw_2a', 'screw_2b'}));

      // Board 3 (Teak, top layer, zIndex: 2)
      final board3 = level.boards['board_3']!;
      expect(board3.id, equals('board_3'));
      expect(board3.left, equals(150.0));
      expect(board3.top, equals(140.0));
      expect(board3.width, equals(60.0));
      expect(board3.height, equals(260.0));
      expect(board3.zIndex, equals(2));
      expect(board3.status, equals(BoardStatus.pinned));
      expect(board3.attachedScrewIds, equals({'screw_3a', 'screw_3b'}));

      // Verify screws
      expect(level.screws.length, equals(6));

      // Screws on Board 1
      final s1a = level.screws['screw_1a']!;
      expect(s1a.boardId, equals('board_1'));
      expect(s1a.x, equals(75.0));
      expect(s1a.y, equals(335.0));
      expect(s1a.traySlot, isNull);

      final s1b = level.screws['screw_1b']!;
      expect(s1b.boardId, equals('board_1'));
      expect(s1b.x, equals(180.0));
      expect(s1b.y, equals(335.0));
      expect(s1b.traySlot, isNull);

      // Screws on Board 2
      final s2a = level.screws['screw_2a']!;
      expect(s2a.boardId, equals('board_2'));
      expect(s2a.x, equals(75.0));
      expect(s2a.y, equals(235.0));
      expect(s2a.traySlot, isNull);

      final s2b = level.screws['screw_2b']!;
      expect(s2b.boardId, equals('board_2'));
      expect(s2b.x, equals(180.0));
      expect(s2b.y, equals(235.0));
      expect(s2b.traySlot, isNull);

      // Screws on Board 3
      final s3a = level.screws['screw_3a']!;
      expect(s3a.boardId, equals('board_3'));
      expect(s3a.x, equals(180.0));
      expect(s3a.y, equals(170.0));
      expect(s3a.traySlot, isNull);

      final s3b = level.screws['screw_3b']!;
      expect(s3b.boardId, equals('board_3'));
      expect(s3b.x, equals(180.0));
      expect(s3b.y, equals(375.0));
      expect(s3b.traySlot, isNull);
    });

    test('Level 1 initial screw accessibility matches geometric occlusion', () {
      final level = Level1Data.create();

      // Board 3 is top layer (zIndex: 2) -> both screws accessible
      expect(level.isScrewAccessible('screw_3a'), isTrue);
      expect(level.isScrewAccessible('screw_3b'), isTrue);

      // Board 2 has s2a exposed, s2b covered by Board 3
      expect(level.isScrewAccessible('screw_2a'), isTrue);
      expect(level.isScrewAccessible('screw_2b'), isFalse);

      // Board 1 has s1a exposed, s1b covered by Board 3
      expect(level.isScrewAccessible('screw_1a'), isTrue);
      expect(level.isScrewAccessible('screw_1b'), isFalse);
    });

    test('Level1Data.create() returns fresh independent instances on each call', () {
      final levelA = Level1Data.create();
      final levelB = Level1Data.create();

      // Mutate levelA
      levelA.applyMove('screw_3a');

      // levelB must be completely unaffected
      expect(levelA.traySlots[0], equals('screw_3a'));
      expect(levelB.traySlots[0], isNull);
      expect(levelA.boards['board_3']!.attachedScrewIds.length, equals(1));
      expect(levelB.boards['board_3']!.attachedScrewIds.length, equals(2));
    });
  });
}
