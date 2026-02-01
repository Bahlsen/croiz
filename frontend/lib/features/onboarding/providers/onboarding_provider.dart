import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:croiz/features/onboarding/services/onboarding_service.dart';

part 'onboarding_provider.g.dart';

@Riverpod(keepAlive: true)
OnboardingService onboardingService(Ref ref) => OnboardingService();

@Riverpod(keepAlive: true)
class OnboardingState extends _$OnboardingState {
  @override
  Future<bool> build() async {
    final service = ref.watch(onboardingServiceProvider);
    return service.hasCompletedOnboarding();
  }

  Future<void> completeOnboarding() async {
    final service = ref.read(onboardingServiceProvider);
    await service.completeOnboarding();
    state = const AsyncData(true);
  }
}
