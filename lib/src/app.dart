import 'package:flutter/material.dart';
import 'package:screw_escape/src/core/config/app_config.dart';

/// The root widget of the Screw Escape application.
class ScrewEscapeApp extends StatelessWidget {
  const ScrewEscapeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF2C1810),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B5A2B),
          brightness: Brightness.dark,
        ),
      ),
      home: const _FoundationHomeScreen(),
    );
  }
}

class _FoundationHomeScreen extends StatelessWidget {
  const _FoundationHomeScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppConfig.appName,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD4AF37),
                  letterSpacing: 2.0,
                ),
              ),
              SizedBox(height: 8),
              Text(
                AppConfig.appVersion,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 32),
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Foundation ready',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white54,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

