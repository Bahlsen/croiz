import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:croiz/features/puzzles/puzzles_list_page.dart';
import 'package:croiz/features/game/screens/crossword_screen.dart';

part 'app_routes.g.dart';

@TypedGoRoute<HomeRoute>(path: '/puzzles', routes: [])
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
  Widget build(BuildContext context, GoRouterState state) =>
      CrosswordScreen(puzzleId: id);
}
