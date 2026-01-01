import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_storage_provider.g.dart';

/// Provider for Flutter Secure Storage.
///
/// Used to securely store sensitive data like authentication tokens.
/// The storage is encrypted using platform-specific encryption mechanisms
/// (Keychain on iOS, EncryptedSharedPreferences on Android).
@Riverpod(keepAlive: true)
FlutterSecureStorage secureStorage(Ref ref) => const FlutterSecureStorage();
