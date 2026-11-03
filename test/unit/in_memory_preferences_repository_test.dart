import 'package:flutter_test/flutter_test.dart';
import 'package:screw_escape/src/features/settings/data/in_memory_preferences_repository.dart';

void main() {
  group('InMemoryPreferencesRepository', () {
    late InMemoryPreferencesRepository repository;

    setUp(() {
      repository = InMemoryPreferencesRepository();
    });

    test('returns defaultValue when key is absent', () async {
      final resultDefaultTrue = await repository.getBool('absent_key');
      expect(resultDefaultTrue, isTrue);

      final resultDefaultFalse =
          await repository.getBool('absent_key', defaultValue: false);
      expect(resultDefaultFalse, isFalse);
    });

    test('persists and retrieves boolean value', () async {
      await repository.setBool('sound_enabled', false);
      final value = await repository.getBool('sound_enabled');
      expect(value, isFalse);

      await repository.setBool('sound_enabled', true);
      final updatedValue = await repository.getBool('sound_enabled');
      expect(updatedValue, isTrue);
    });

    test('throws PreferencesReadException when throwOnRead is enabled', () async {
      repository.throwOnRead = true;

      expect(
        () => repository.getBool('sound_enabled'),
        throwsA(isA<PreferencesReadException>()),
      );
    });

    test('throws PreferencesWriteException when throwOnWrite is enabled', () async {
      repository.throwOnWrite = true;

      expect(
        () => repository.setBool('sound_enabled', false),
        throwsA(isA<PreferencesWriteException>()),
      );
    });
  });
}

