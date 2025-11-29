import 'package:go_router/go_router.dart';
import 'package:croiz/features/home/home_screen.dart';
import 'package:croiz/features/game/crossword_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/crossword',
      builder: (context, state) => const CrosswordScreen(),
    ),
  ],
);
