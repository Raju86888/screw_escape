import 'package:flutter/material.dart';
import 'package:screw_escape/src/core/config/app_config.dart';
import 'package:screw_escape/src/core/theme/app_colors.dart';
import 'package:screw_escape/src/core/theme/app_spacing.dart';
import 'package:screw_escape/src/core/theme/app_text_styles.dart';
import 'package:screw_escape/src/core/widgets/metallic_button.dart';
import 'package:screw_escape/src/core/widgets/responsive_container.dart';
import 'package:screw_escape/src/core/widgets/wood_surface.dart';
import 'package:screw_escape/src/features/gameplay_placeholder/presentation/gameplay_placeholder_screen.dart';
import 'package:screw_escape/src/features/home/presentation/widgets/game_title.dart';
import 'package:screw_escape/src/features/home/presentation/widgets/level_select_dialog.dart';
import 'package:screw_escape/src/features/settings/data/in_memory_preferences_repository.dart';
import 'package:screw_escape/src/features/settings/domain/settings_controller.dart';
import 'package:screw_escape/src/features/settings/presentation/settings_dialog.dart';

/// The main entry-point screen of the game.
///
/// Implements REQ-001-03, REQ-001-04, EC-04, EC-05, AC-02, and AC-03.
class HomeScreen extends StatefulWidget {
  /// The settings controller injected into the screen.
  final SettingsController? settingsController;

  const HomeScreen({
    super.key,
    this.settingsController,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final SettingsController _controller;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    // Default to an in-memory controller if none was injected (e.g., in standalone tests)
    _controller = widget.settingsController ??
        SettingsController(InMemoryPreferencesRepository());

    if (!_controller.isLoaded) {
      _controller.loadSettings();
    }
  }

  /// Navigates to [GameplayPlaceholderScreen] with resilient try/finally debounce guard.
  ///
  /// Guarantees against rapid double-tap route stacking (EC-05) and navigation lockouts.
  Future<void> _onPlayPressed() async {
    if (_isNavigating) return;
    _isNavigating = true;

    try {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const GameplayPlaceholderScreen(),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isNavigating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.woodDark,
      body: WoodSurface(
        showPlanks: true,
        child: ResponsiveContainer(
          maxWidth: 480.0,
          scrollable: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Row: Settings Icon and App Version
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0x33000000),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(
                        color: const Color(0x22FFFFFF),
                        width: 1.0,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.settings_rounded,
                        color: AppColors.metalGold,
                        size: 26,
                      ),
                      tooltip: 'Settings',
                      onPressed: () => SettingsDialog.show(
                        context,
                        controller: _controller,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x33000000),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      'v${AppConfig.appVersion}',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Hero Title Area
              const GameTitle(),
              const SizedBox(height: AppSpacing.xxl),

              // Primary Call To Action: Play Button
              MetallicButton(
                label: 'PLAY',
                icon: Icons.play_arrow_rounded,
                variant: MetallicButtonVariant.primaryGreen,
                height: 60.0,
                onPressed: _onPlayPressed,
              ),
              const SizedBox(height: AppSpacing.md),

              // Secondary Call To Action: Levels Button
              MetallicButton(
                label: 'LEVELS',
                icon: Icons.grid_view_rounded,
                variant: MetallicButtonVariant.gold,
                height: 52.0,
                onPressed: () => LevelSelectDialog.show(context),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

