import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Provider for Flutter Secure Storage.
///
/// Used to securely store sensitive data like authentication tokens.
/// The storage is encrypted using platform-specific encryption mechanisms
/// (Keychain on iOS, EncryptedSharedPreferences on Android).
final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);
