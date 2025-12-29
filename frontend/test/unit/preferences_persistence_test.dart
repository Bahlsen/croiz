import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:croiz/services/providers.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('preferences notifiers persist values to SharedPreferences', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Set preferences via notifiers
    container.read(appIsDarkProvider.notifier).setIsDark(isDark: true);
    container
        .read(gameKeyboardLayoutProvider.notifier)
        .setIsAzerty(isAzerty: true);
    container
        .read(gameKeyboardSizeProvider.notifier)
        .setSize(KeyboardSize.large);
    container.read(gameAudioMutedProvider.notifier).setMuted(muted: true);

    // Wait a short time for async writes to complete
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('pref_is_dark'), isTrue);
    expect(prefs.getBool('pref_keyboard_azerty'), isTrue);
    expect(
      prefs.getString('pref_keyboard_size'),
      equals(KeyboardSize.large.name),
    );
    expect(prefs.getBool('pref_audio_muted'), isTrue);
  });
}
