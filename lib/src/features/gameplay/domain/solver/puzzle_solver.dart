import '../models/game_state.dart';
import '../models/game_status.dart';

/// Produces a deterministic canonical serialization key representing all
/// variables in a [GameState] that can affect future transitions.
///
/// Guaranteed to produce identical output regardless of Map/Set insertion orders.
String canonicalStateKey(GameState s) {
  // 1. Boards: sorted by ID
  final sortedBoardIds = s.boards.keys.toList()..sort();
  final bParts = sortedBoardIds.map((id) {
    final b = s.boards[id]!;
    final screws = b.attachedScrewIds.toList()..sort();
    return '$id:${b.status.name}:[${screws.join(",")}]';
  }).join(';');

  // 2. Screws: sorted by ID, recording tray assignment
  final sortedScrewIds = s.screws.keys.toList()..sort();
  final sParts = sortedScrewIds.map((id) {
    final sc = s.screws[id]!;
    return '$id:${sc.traySlot ?? "board"}';
  }).join(';');

  // 3. Tray slots: exact ordered occupancy (0, 1, 2)
  final tParts = s.traySlots.map((slot) => slot ?? '_').join(',');

  // 4. Game status: playing, won, lost
  final gPart = s.status.name;

  return 'B:$bParts#S:$sParts#T:$tParts#G:$gPart';
}

/// Result payload produced by [PuzzleSolver.solve].
class SolverResult {
  /// Whether a valid move sequence leading to [GameStatus.won] was discovered.
  final bool isSolvable;

  /// The sequence of screw IDs representing the shortest winning path.
  final List<String> shortestPath;

  /// Total count of distinct game states visited during the search.
  final int statesVisited;

  /// Total count of deadlocked/lost branch endpoints identified.
  final int deadlocksFound;

  SolverResult({
    required this.isSolvable,
    required this.shortestPath,
    required this.statesVisited,
    required this.deadlocksFound,
  });
}

/// Internal queue node for BFS puzzle graph traversal.
class _SolverNode {
  final GameState state;
  final List<String> path;

  _SolverNode(this.state, this.path);
}

/// Pure Dart Breadth-First Search (BFS) Solver for Screw Escape puzzles.
///
/// Uses the exact authoritative domain transitions ([GameState.applyMove],
/// [GameState.finalizeBoardClear], and [GameState.evaluateLoseCondition])
/// to guarantee 100% mechanical agreement with live gameplay.
abstract final class PuzzleSolver {
  /// Solves the puzzle starting from [initial] using BFS.
  ///
  /// Returns a [SolverResult] containing solvability status, the shortest
  /// winning move sequence, and graph traversal telemetry.
  static SolverResult solve(GameState initial) {
    final queue = <_SolverNode>[_SolverNode(initial.clone(), [])];
    final visited = <String>{};
    List<String>? winningPath;
    int statesVisited = 0;
    int deadlocksFound = 0;

    visited.add(canonicalStateKey(initial));

    while (queue.isNotEmpty) {
      final node = queue.removeAt(0);
      statesVisited++;

      // Winning terminal state reached
      if (node.state.status == GameStatus.won) {
        winningPath ??= node.path;
        continue;
      }

      // Lost/deadlock terminal state reached
      if (node.state.status == GameStatus.lost) {
        deadlocksFound++;
        continue;
      }

      // Capacity deadlock: tray is full and no moves can be applied
      if (!node.state.traySlots.contains(null)) {
        deadlocksFound++;
        continue;
      }

      // Explore all candidate moves for accessible screws
      for (final screwId in node.state.screws.keys) {
        if (!node.state.isScrewAccessible(screwId)) continue;

        final nextState = node.state.clone();
        final result = nextState.applyMove(screwId);
        if (result.boardDropped) {
          nextState.finalizeBoardClear(result.droppedBoardId!);
        }
        nextState.evaluateLoseCondition();

        final key = canonicalStateKey(nextState);
        if (!visited.contains(key)) {
          visited.add(key);
          queue.add(_SolverNode(nextState, [...node.path, screwId]));
        }
      }
    }

    return SolverResult(
      isSolvable: winningPath != null,
      shortestPath: winningPath ?? [],
      statesVisited: statesVisited,
      deadlocksFound: deadlocksFound,
    );
  }
}

