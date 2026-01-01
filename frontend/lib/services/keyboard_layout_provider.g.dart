// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keyboard_layout_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for keyboard layout preference.

@ProviderFor(KeyboardLayoutNotifier)
final keyboardLayoutProvider = KeyboardLayoutNotifierProvider._();

/// Provider for keyboard layout preference.
final class KeyboardLayoutNotifierProvider
    extends $NotifierProvider<KeyboardLayoutNotifier, bool> {
  /// Provider for keyboard layout preference.
  KeyboardLayoutNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'keyboardLayoutProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$keyboardLayoutNotifierHash();

  @$internal
  @override
  KeyboardLayoutNotifier create() => KeyboardLayoutNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$keyboardLayoutNotifierHash() =>
    r'1b50b71d5bd162d29b14fd6c3ad61a38cf603999';

/// Provider for keyboard layout preference.

abstract class _$KeyboardLayoutNotifier extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
