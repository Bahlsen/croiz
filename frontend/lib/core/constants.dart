import 'package:flutter/material.dart';

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

/// App-wide colors
class AppColors {
  static const Color primary = Color(0xFF2196F3);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color error = Color(0xFFB00020);
  
  static const Color gameBoardBackground = Color(0xFFFAFAFA);
  static const Color cellEmpty = Color(0xFFFFFFFF);
  static const Color cellFilled = Color(0xFFE8E8E8);
  static const Color cellSelected = Color(0xFFBBDEFB);
  static const Color cellHint = Color(0xFFFFF59D);
}

/// Text styles
class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: Colors.grey,
  );
}
