import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Secure Storage Provider
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) => const FlutterSecureStorage());

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
final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<AuthState>>(AuthNotifier.new);

class AuthNotifier extends StateNotifier<AsyncValue<AuthState>> {

  AuthNotifier(this.ref) : super(AsyncValue.data(AuthState.initial()));
  final Ref ref;

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
