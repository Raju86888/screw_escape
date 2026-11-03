import 'package:flutter/material.dart';
import 'package:screw_escape/src/core/config/app_config.dart';
import 'package:screw_escape/src/core/theme/app_colors.dart';
import 'package:screw_escape/src/features/home/presentation/home_screen.dart';
import 'package:screw_escape/src/features/settings/domain/settings_controller.dart';

/// The root widget of the Screw Escape application.
///
/// Implements REQ-001-01, REQ-001-06, AC-01, NFR-001-01, and NFR-001-04.
/// Accepts an optional [SettingsController] to allow headless unit/widget tests
/// without platform channel dependencies.
class ScrewEscapeApp extends StatelessWidget {
  /// The settings controller managing sound state and preferences.
  final SettingsController? settingsController;

  const ScrewEscapeApp({
    super.key,
    this.settingsController,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.woodDark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.woodSurface,
          brightness: Brightness.dark,
        ),
      ),
      home: HomeScreen(settingsController: settingsController),
    );
  }
}
