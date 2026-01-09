import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:croiz/services/persistence/secure_storage_provider.dart';

part 'auth_provider.freezed.dart';
part 'auth_provider.g.dart';

/// Authentication Provider
@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<AuthState> build() => const AuthState.unauthenticated();

  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(
      () => Future.value(
        const AuthState.authenticated(userId: 'user_id', token: 'token'),
      ),
    );
    if (!ref.mounted) {
      return;
    }
    state = result;
  }

  Future<void> logout() async {
    final storage = ref.read(secureStorageProvider);
    await storage.delete(key: 'auth_token');
    if (!ref.mounted) {
      return;
    }
    state = const AsyncValue.data(AuthState.unauthenticated());
  }
}

/// Authentication state using freezed sealed class
@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.unauthenticated() = AuthStateUnauthenticated;

  const factory AuthState.authenticated({
    required String userId,
    required String token,
  }) = AuthStateAuthenticated;

  const factory AuthState.error(String message) = AuthStateError;
}
