/// App-wide constants
class AppConstants {
  static const String appName = 'Croiz';
  static const String appVersion = '1.0.0';

  // API
  static const String apiBaseUrl = 'http://localhost:8080/api/v1';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Game
  static const int gridSize = 15;
  static const int maxGameDuration = 3600; // seconds

  // Storage keys
  static const String authTokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userNameKey = 'user_name';
}
