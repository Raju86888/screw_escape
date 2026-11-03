import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screw_escape/src/app.dart';
import 'package:screw_escape/src/features/settings/data/shared_preferences_repository.dart';
import 'package:screw_escape/src/features/settings/domain/settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enforce portrait orientation lock as required by REQ-001-01 / AC-01.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Instantiate production repository and controller
  final repository = SharedPreferencesRepository();
  final settingsController = SettingsController(repository);

  // Kick off asynchronous settings load safely
  settingsController.loadSettings();

  runApp(ScrewEscapeApp(settingsController: settingsController));
}
