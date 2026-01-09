// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keyboard_size_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for keyboard size preference.

@ProviderFor(KeyboardSizeNotifier)
final keyboardSizeProvider = KeyboardSizeNotifierProvider._();

/// Provider for keyboard size preference.
final class KeyboardSizeNotifierProvider
    extends $NotifierProvider<KeyboardSizeNotifier, KeyboardSize> {
  /// Provider for keyboard size preference.
  KeyboardSizeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'keyboardSizeProvider',
        isAutoDispose: false,
        dependencies: <ProviderOrFamily>[preferencePersistenceServiceProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          KeyboardSizeNotifierProvider.$allTransitiveDependencies0,
        ],
      );

  static final $allTransitiveDependencies0 =
      preferencePersistenceServiceProvider;

  @override
  String debugGetCreateSourceHash() => _$keyboardSizeNotifierHash();

  @$internal
  @override
  KeyboardSizeNotifier create() => KeyboardSizeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KeyboardSize value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KeyboardSize>(value),
    );
  }
}

String _$keyboardSizeNotifierHash() =>
    r'cc6d28cd26aafe283dbf7af5e73a0954dd29dcab';

/// Provider for keyboard size preference.

abstract class _$KeyboardSizeNotifier extends $Notifier<KeyboardSize> {
  KeyboardSize build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<KeyboardSize, KeyboardSize>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<KeyboardSize, KeyboardSize>,
              KeyboardSize,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
