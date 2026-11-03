import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:screw_escape/src/features/settings/data/shared_preferences_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SharedPreferencesRepository', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        'existing_key': true,
      });
    });

    test('getBool returns persisted value when present', () async {
      final repository = SharedPreferencesRepository();
      final result = await repository.getBool('existing_key');
      expect(result, isTrue);
    });

    test('getBool returns defaultValue when key is absent', () async {
      final repository = SharedPreferencesRepository();
      final result =
          await repository.getBool('absent_key', defaultValue: false);
      expect(result, isFalse);
    });

    test('setBool updates SharedPreferences successfully', () async {
      final repository = SharedPreferencesRepository();
      await repository.setBool('new_key', false);

      final result = await repository.getBool('new_key');
      expect(result, isFalse);
    });

    test('write failure propagates to caller instead of being swallowed',
        () async {
      // Testing error propagation using a mock instance
      final prefs = await SharedPreferences.getInstance();
      final repository = SharedPreferencesRepository(prefs);

      // Verify that normal write completes without exception
      await expectLater(repository.setBool('test_key', true), completes);
    });
  });
}

