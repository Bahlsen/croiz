import 'package:go_router/go_router.dart';
import 'package:croiz/features/home/home_screen.dart';
import 'package:croiz/features/game/crossword_screen.dart';
import 'package:croiz/features/puzzles/puzzles_list_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/puzzles',
      builder: (context, state) => const PuzzlesListPage(),
    ),
    GoRoute(
      path: '/crossword',
      builder: (context, state) => CrosswordScreen(
        puzzleId: state.uri.queryParameters['id'],
      ),
    ),
  ],
);
