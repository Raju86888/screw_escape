import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screw_escape/src/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enforce portrait orientation lock as required by REQ-001-01 / AC-01.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const ScrewEscapeApp());
}
