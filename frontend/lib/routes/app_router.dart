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
      redirect: (context, state) {
        final id = state.uri.queryParameters['id'];
        if (id == null || id.isEmpty) {
          return '/puzzles';
        }
        return null;
      },
      builder: (context, state) =>
          CrosswordScreen(puzzleId: state.uri.queryParameters['id']),
    ),
  ],
);
