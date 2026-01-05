import 'package:go_router/go_router.dart';
import 'package:croiz/routes/app_routes.dart';

final appRouter = GoRouter(initialLocation: '/puzzles', routes: $appRoutes);
