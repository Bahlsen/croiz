// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$homeRoute, $crosswordRoute];

RouteBase get $homeRoute =>
    GoRouteData.$route(path: '/puzzles', factory: $HomeRoute._fromState);

mixin $HomeRoute on GoRouteData {
  static HomeRoute _fromState(GoRouterState state) => const HomeRoute();

  @override
  String get location => GoRouteData.$location('/puzzles');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $crosswordRoute =>
    GoRouteData.$route(path: '/crossword', factory: $CrosswordRoute._fromState);

mixin $CrosswordRoute on GoRouteData {
  static CrosswordRoute _fromState(GoRouterState state) =>
      CrosswordRoute(id: state.uri.queryParameters['id']!);

  CrosswordRoute get _self => this as CrosswordRoute;

  @override
  String get location =>
      GoRouteData.$location('/crossword', queryParams: {'id': _self.id});

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
