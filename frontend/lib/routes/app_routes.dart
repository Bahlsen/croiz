import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:croiz/features/puzzles/puzzles_list_page.dart';
import 'package:croiz/features/game/screens/crossword_screen.dart';
import 'package:croiz/features/onboarding/screens/onboarding_screen.dart';

part 'app_routes.g.dart';

@TypedGoRoute<HomeRoute>(path: '/puzzles')
class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const PuzzlesListPage();
}

@TypedGoRoute<CrosswordRoute>(path: '/crossword')
class CrosswordRoute extends GoRouteData with $CrosswordRoute {
  const CrosswordRoute({required this.id});

  final String id;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      CustomTransitionPage<void>(
        key: state.pageKey,
        child: CrosswordScreen(puzzleId: id),
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) => FadeTransition(
              opacity: CurveTween(curve: Curves.easeIn).animate(animation),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.05, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: child,
              ),
            ),
      );
}

@TypedGoRoute<OnboardingRoute>(path: '/onboarding')
class OnboardingRoute extends GoRouteData with $OnboardingRoute {
  const OnboardingRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const OnboardingScreen();
}
