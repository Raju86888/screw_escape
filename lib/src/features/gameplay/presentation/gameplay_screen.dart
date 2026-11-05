import 'package:flutter/material.dart';
import 'package:screw_escape/src/core/theme/app_colors.dart';
import 'package:screw_escape/src/core/widgets/responsive_container.dart';
import 'package:screw_escape/src/features/gameplay/application/gameplay_controller.dart';
import 'package:screw_escape/src/features/gameplay/presentation/widgets/game_controls_bar.dart';
import 'package:screw_escape/src/features/gameplay/presentation/widgets/game_hud.dart';
import 'package:screw_escape/src/features/gameplay/presentation/widgets/game_over_dialog.dart';
import 'package:screw_escape/src/features/gameplay/presentation/widgets/level_win_dialog.dart';
import 'package:screw_escape/src/features/gameplay/presentation/widgets/puzzle_canvas.dart';

/// Primary gameplay screen hosting the interactive puzzle canvas, HUD, and controls.
class GameplayScreen extends StatefulWidget {
  /// Optional injected controller (for headless testing or state restoration).
  final GameplayController? controller;

  const GameplayScreen({
    super.key,
    this.controller,
  });

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> {
  late final GameplayController _controller;
  late final bool _ownsController;
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? GameplayController();

    _controller.onGameWon = _handleGameWon;
    _controller.onGameLost = _handleGameLost;
    _controller.onToast = _handleToast;
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    } else {
      _controller.onGameWon = null;
      _controller.onGameLost = null;
      _controller.onToast = null;
    }
    super.dispose();
  }

  void _handleGameWon() {
    if (!mounted || _isDialogShowing) return;
    _isDialogShowing = true;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return LevelWinDialog(
          onReplayPressed: () {
            Navigator.of(dialogContext).pop();
            _controller.restartLevel();
          },
          onMainMenuPressed: () {
            Navigator.of(dialogContext).pop();
            if (mounted) {
              Navigator.of(context).maybePop();
            }
          },
        );
      },
    ).then((_) {
      if (mounted) {
        _isDialogShowing = false;
      }
    });
  }

  void _handleGameLost() {
    if (!mounted || _isDialogShowing) return;
    _isDialogShowing = true;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return GameOverDialog(
          onUndoPressed: () {
            Navigator.of(dialogContext).pop();
            _controller.undo();
          },
          onRetryPressed: () {
            Navigator.of(dialogContext).pop();
            _controller.restartLevel();
          },
        );
      },
    ).then((_) {
      if (mounted) {
        _isDialogShowing = false;
      }
    });
  }

  void _handleToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.woodMedium,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final isLocked = _controller.isInputLocked;
        final isUndoDisabled = isLocked || _controller.gameState.history.isEmpty;

        return Scaffold(
          backgroundColor: AppColors.woodDark,
          body: SafeArea(
            child: ResponsiveContainer(
              scrollable: false,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  // 1. Top HUD Bar
                  GameHud(
                    levelTitle: 'LEVEL 1',
                    isInputLocked: isLocked,
                    onBackPressed: () => Navigator.of(context).maybePop(),
                    onRestartPressed: () => _controller.restartLevel(),
                  ),

                  // 2. Interactive Responsive Puzzle Canvas
                  Expanded(
                    child: Center(
                      child: PuzzleCanvas(
                        controller: _controller,
                      ),
                    ),
                  ),

                  // 3. Bottom Controls Bar
                  GameControlsBar(
                    isUndoDisabled: isUndoDisabled,
                    isHintDisabled: isLocked,
                    onUndoPressed: () => _controller.undo(),
                    onHintPressed: () => _controller.requestHint(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
