import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/services/secure_storage_provider.dart';

/// Authentication Provider
final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  FutureOr<AuthState> build() => AuthState.initial();

  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => Future.value(AuthState.authenticated('user_id', 'token')),
    );
  }

  Future<void> logout() async {
    final storage = ref.read(secureStorageProvider);
    await storage.delete(key: 'auth_token');
    state = AsyncValue.data(AuthState.initial());
  }
}

class AuthState {
  const AuthState({
    required this.isAuthenticated,
    this.userId,
    this.token,
    this.error,
  });

  factory AuthState.initial() => const AuthState(isAuthenticated: false);

  factory AuthState.authenticated(String userId, String token) =>
      AuthState(isAuthenticated: true, userId: userId, token: token);

  factory AuthState.error(String error) =>
      AuthState(isAuthenticated: false, error: error);

  final bool isAuthenticated;
  final String? userId;
  final String? token;
  final String? error;
}
