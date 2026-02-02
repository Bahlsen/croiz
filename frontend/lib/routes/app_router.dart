import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:croiz/routes/app_routes.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:croiz/features/onboarding/providers/onboarding_provider.dart';

part 'app_router.g.dart';

/// Global navigator key that can be used to access the Navigator's overlay
/// from anywhere in the app.
final rootNavigatorKey = GlobalKey<NavigatorState>();

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final onboardingState = ref.watch(onboardingStateProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/puzzles',
    routes: $appRoutes,
    redirect: (context, state) {
      // Don't redirect while state is loading or error
      if (onboardingState.isLoading || onboardingState.hasError) {
        return null;
      }

      final hasOnboarded = onboardingState.asData?.value ?? false;
      final isOnboarding = state.matchedLocation == '/onboarding';

      if (!hasOnboarded && !isOnboarding) {
        return '/onboarding';
      }

      if (hasOnboarded && isOnboarding) {
        return '/puzzles';
      }

      return null;
    },
  );
}
