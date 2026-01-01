// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'secure_storage_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for Flutter Secure Storage.
///
/// Used to securely store sensitive data like authentication tokens.
/// The storage is encrypted using platform-specific encryption mechanisms
/// (Keychain on iOS, EncryptedSharedPreferences on Android).

@ProviderFor(secureStorage)
final secureStorageProvider = SecureStorageProvider._();

/// Provider for Flutter Secure Storage.
///
/// Used to securely store sensitive data like authentication tokens.
/// The storage is encrypted using platform-specific encryption mechanisms
/// (Keychain on iOS, EncryptedSharedPreferences on Android).

final class SecureStorageProvider
    extends
        $FunctionalProvider<
          FlutterSecureStorage,
          FlutterSecureStorage,
          FlutterSecureStorage
        >
    with $Provider<FlutterSecureStorage> {
  /// Provider for Flutter Secure Storage.
  ///
  /// Used to securely store sensitive data like authentication tokens.
  /// The storage is encrypted using platform-specific encryption mechanisms
  /// (Keychain on iOS, EncryptedSharedPreferences on Android).
  SecureStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'secureStorageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$secureStorageHash();

  @$internal
  @override
  $ProviderElement<FlutterSecureStorage> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FlutterSecureStorage create(Ref ref) {
    return secureStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FlutterSecureStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FlutterSecureStorage>(value),
    );
  }
}

String _$secureStorageHash() => r'a4f75721472cf77465bf47f759c90de5ca30856e';
