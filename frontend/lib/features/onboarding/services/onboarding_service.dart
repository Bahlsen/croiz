import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String _completedKey = 'has_completed_onboarding';

  Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_completedKey) ?? false;
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_completedKey, true);
  }
}
