import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/services/game_audio_service.dart';
import 'package:croiz/services/audio_service.dart';
import 'package:croiz/features/game/services/word_check_service.dart';

// Secure Storage Provider
final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

// Game Audio Service Provider
final gameAudioServiceProvider = Provider<AudioService>(
  (ref) => GameAudioService(),
);

// Keyboard layout: false = QWERTY (default), true = AZERTY
final gameKeyboardLayoutProvider =
    NotifierProvider<KeyboardLayoutNotifier, bool>(KeyboardLayoutNotifier.new);

// Global game audio mute flag
final gameAudioMutedProvider = NotifierProvider<AudioMutedNotifier, bool>(
  AudioMutedNotifier.new,
);

// App theme dark flag (true = dark)
final appIsDarkProvider = NotifierProvider<AppIsDarkNotifier, bool>(
  AppIsDarkNotifier.new,
);

// --- Notifier implementations (Riverpod 3.0 style) ---
class KeyboardLayoutNotifier extends Notifier<bool> {
  @override
  bool build() => false; // false = QWERTY by default

  // Use a setter to modify the property (satisfies linter)
  bool get isAzerty => state;
  set isAzerty(bool value) => state = value;

  void toggle() => state = !state;
}

class AudioMutedNotifier extends Notifier<bool> {
  @override
  bool build() => false; // not muted by default

  // Use a setter to modify the property (satisfies linter)
  bool get muted => state;
  set muted(bool value) => state = value;

  void toggle() => state = !state;
}

class AppIsDarkNotifier extends Notifier<bool> {
  @override
  bool build() => false; // light theme by default

  // Use a setter to modify the property (satisfies linter)
  bool get isDark => state;
  set isDark(bool value) => state = value;

  void toggle() => state = !state;
}

// Word Check Service Provider
final wordCheckServiceProvider = Provider<WordCheckService>(
  (ref) => WordCheckService(),
);

// Dio HTTP Client Provider
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:8080/api/v1',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      responseType: ResponseType.json,
    ),
  );

  // Add interceptors
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token if available
        final storage = ref.read(secureStorageProvider);
        final token = await storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        // Handle errors
        if (error.response?.statusCode == 401) {
          // Token expired - redirect to login
          // This would be handled by router
        }
        return handler.next(error);
      },
    ),
  );

  return dio;
});

// Authentication Provider
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
