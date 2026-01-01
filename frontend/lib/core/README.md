# Core Utilities

This directory contains application-wide utilities, constants, and theme definitions.

## Overview

Core provides foundational elements used throughout the application:
- Application constants and configuration
- Theme definitions (colors, typography, spacing)
- Shared exceptions and error types
- Common utility functions

## Directory Structure

```
core/
├── constants.dart       # App-wide constant values
├── theme.dart           # Theme definitions (light/dark)
├── exceptions.dart      # Custom exception classes
└── extensions/          # Dart extension methods
```

## Key Files

### `constants.dart`

Application-wide constants:

```dart
/// API configuration
const String apiBaseUrl = 'http://localhost:8080/api/v1';
const Duration defaultTimeout = Duration(seconds: 30);

/// Storage keys
const String authTokenKey = 'auth_token';
const String lastPuzzleKey = 'last_selected_puzzle';

/// Game settings
const int defaultGridSize = 15;
const Duration autoSaveInterval = Duration(seconds: 30);
```

### `theme.dart`

Material Design theme configuration:

```dart
class AppTheme {
  /// Returns the light theme configuration.
  static ThemeData lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      // ...
    );
  }

  /// Returns the dark theme configuration.
  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.blueAccent,
      // ...
    );
  }
}
```

Theme features:
- Consistent color palette across screens
- Typography using Google Fonts
- Custom component themes (buttons, cards, etc.)
- Responsive sizing considerations

### `exceptions.dart`

Custom exception types for better error handling:

```dart
/// Thrown when a puzzle cannot be loaded.
class PuzzleLoadException implements Exception {
  final String message;
  PuzzleLoadException(this.message);
}

/// Thrown when authentication fails.
class AuthenticationException implements Exception {
  final String message;
  AuthenticationException(this.message);
}

/// Thrown when network request fails.
class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  NetworkException(this.message, {this.statusCode});
}
```

## Usage Guidelines

### Constants
- Use constants for magic numbers and strings
- Group related constants together
- Prefer const over final for true constants

### Themes
- Always use theme colors via `Theme.of(context)`
- Use semantic color names (primary, error, etc.)
- Support both light and dark modes

### Exceptions
- Create specific exception types for different errors
- Include meaningful error messages
- Use for expected error conditions (network, auth, etc.)

## Related Files

- [Services](../services/README.md) - Uses constants for configuration
- [Features](../features/README.md) - Uses theme for styling
- [main.dart](../main.dart) - Applies theme to MaterialApp
