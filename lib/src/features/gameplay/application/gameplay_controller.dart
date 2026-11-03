import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../settings/domain/settings_controller.dart';
import '../domain/levels/level_1_data.dart';
import '../domain/models/game_state.dart';
import '../domain/models/game_status.dart';
import '../domain/solver/puzzle_solver.dart';

/// Orchestrates gameplay state, animation lifecycles, and user interactions.
class GameplayController extends ChangeNotifier {
  /// Authoritative game state model.
  GameState _gameState;

  /// Optional sound/haptic settings controller.
  final SettingsController? settingsController;

  /// Animation durations (configurable for deterministic and rapid test runs).
  final Duration screwTravelDuration;
  final Duration boardFallDuration;
  final Duration trayClearDuration;
  final Duration settlementDuration;
  final Duration hintDuration;

  /// Whether user inputs (screw taps, undo, hint, restart) are currently disabled.
  bool _isInputLocked = false;

  /// Currently highlighted screw ID for player hint assistance, or null if inactive.
  String? _hintedScrewId;

  /// Timer driving the 3-second hint golden halo auto-dismissal.
  Timer? _hintTimer;

  /// Whether this controller has been disposed.
  bool _isDisposed = false;

  /// Identifier of the screw currently translating to the tray, if any.
  String? _animatingScrewId;

  /// Identifier of the board currently falling off-screen, if any.
  String? _fallingBoardId;

  /// Identifiers of screws currently shrinking/fading out of the tray.
  List<String> _ejectingScrewIds = const [];

  /// Callback invoked when victory is resolved after all animations settle.
  VoidCallback? onGameWon;

  /// Callback invoked when game over / deadlock is resolved after settlement.
  VoidCallback? onGameLost;

  /// Callback invoked to display a non-blocking toast/snackbar message.
  ValueChanged<String>? onToast;

  GameplayController({
    GameState? initialState,
    this.settingsController,
    this.screwTravelDuration = const Duration(milliseconds: 250),
    this.boardFallDuration = const Duration(milliseconds: 400),
    this.trayClearDuration = const Duration(milliseconds: 150),
    this.settlementDuration = const Duration(milliseconds: 100),
    this.hintDuration = const Duration(seconds: 3),
  }) : _gameState = initialState ?? Level1Data.create();

  // --- Getters ---

  GameState get gameState => _gameState;
  bool get isInputLocked => _isInputLocked;
  String? get hintedScrewId => _hintedScrewId;
  String? get animatingScrewId => _animatingScrewId;
  String? get fallingBoardId => _fallingBoardId;
  List<String> get ejectingScrewIds => _ejectingScrewIds;
  bool get isDisposed => _isDisposed;

  /// Primary interaction: player taps a screw fastener on the puzzle canvas.
  Future<void> onScrewTapped(String screwId) async {
    // 1. Guard against taps while locked, deadlocked, or invalid
    if (_isDisposed ||
        _isInputLocked ||
        _gameState.status != GameStatus.playing ||
        !_gameState.isScrewAccessible(screwId) ||
        !_gameState.traySlots.contains(null)) {
      return;
    }

    // 2. Synchronous Input Lock engagement
    _isInputLocked = true;
    _clearHintTimer();
    _hintedScrewId = null;
    _animatingScrewId = screwId;
    notifyListeners();

    // 3. Step 1: Screw translation animation
    if (screwTravelDuration > Duration.zero) {
      await Future.delayed(screwTravelDuration);
    }
    if (_isDisposed) return;

    // Authoritative move transition
    final moveResult = _gameState.applyMove(screwId);
    _animatingScrewId = null;
    notifyListeners();

    // 4. Step 2: Board gravity fall animation (if board was released)
    if (moveResult.boardDropped && moveResult.droppedBoardId != null) {
      _fallingBoardId = moveResult.droppedBoardId;
      notifyListeners();

      if (boardFallDuration > Duration.zero) {
        await Future.delayed(boardFallDuration);
      }
      if (_isDisposed) return;

      // Finalize board clear: ejects board's screws and checks Win condition
      _gameState.finalizeBoardClear(moveResult.droppedBoardId!);
      _fallingBoardId = null;

      // 5. Step 3: Tray screws ejection animation
      _ejectingScrewIds = List<String>.from(moveResult.clearedScrewIds);
      notifyListeners();

      if (trayClearDuration > Duration.zero) {
        await Future.delayed(trayClearDuration);
      }
      if (_isDisposed) return;

      _ejectingScrewIds = const [];
      notifyListeners();
    }

    // 6. Step 4: Terminal state evaluation
    _gameState.evaluateLoseCondition();

    // Terminal outcome resolution
    if (_gameState.status == GameStatus.won) {
      if (settlementDuration > Duration.zero) {
        await Future.delayed(settlementDuration);
      }
      if (_isDisposed) return;
      onGameWon?.call();
      notifyListeners();
    } else if (_gameState.status == GameStatus.lost) {
      if (settlementDuration > Duration.zero) {
        await Future.delayed(settlementDuration);
      }
      if (_isDisposed) return;
      onGameLost?.call();
      notifyListeners();
    } else {
      // Re-enable input lock for active gameplay
      _isInputLocked = false;
      notifyListeners();
    }
  }

  /// Undoes the last move, restoring the exact previous state and accessibility.
  bool undo() {
    if (_isDisposed || _gameState.history.isEmpty) {
      return false;
    }
    // Block undo during active animation, but allow from terminal game-over dialog
    if (_isInputLocked && _gameState.status != GameStatus.lost) {
      return false;
    }

    _clearHintTimer();
    _hintedScrewId = null;
    final success = _gameState.undo();
    if (success) {
      _isInputLocked = false;
      notifyListeners();
    }
    return success;
  }

  /// Solves the puzzle from the current state using BFS and highlights the optimal move.
  void requestHint() {
    if (_isDisposed ||
        _isInputLocked ||
        _gameState.status != GameStatus.playing) {
      return;
    }

    // Cancel any existing hint timer
    _clearHintTimer();

    // Pure read-only BFS solve
    final result = PuzzleSolver.solve(_gameState);

    if (result.isSolvable && result.shortestPath.isNotEmpty) {
      final targetScrewId = result.shortestPath.first;
      _hintedScrewId = targetScrewId;
      notifyListeners();

      // Schedule auto-dismissal timer with lifecycle safety
      _hintTimer = Timer(hintDuration, () {
        if (!_isDisposed && _hintedScrewId == targetScrewId) {
          _hintedScrewId = null;
          notifyListeners();
        }
      });
    } else {
      _hintedScrewId = null;
      notifyListeners();
      onToast?.call('No winning path from here. Use Undo or Restart!');
    }
  }

  /// Resets the puzzle to the pristine initial state of Level 1.
  void restartLevel() {
    if (_isDisposed) return;
    // Block restart during active animation, but allow from settled/dialog states
    if (_isInputLocked &&
        _gameState.status != GameStatus.lost &&
        _gameState.status != GameStatus.won) {
      return;
    }

    _clearHintTimer();
    _hintedScrewId = null;
    _animatingScrewId = null;
    _fallingBoardId = null;
    _ejectingScrewIds = const [];
    _gameState = Level1Data.create();
    _isInputLocked = false;
    notifyListeners();
  }

  void _clearHintTimer() {
    _hintTimer?.cancel();
    _hintTimer = null;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _clearHintTimer();
    super.dispose();
  }
}
