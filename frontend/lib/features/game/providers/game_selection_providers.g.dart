// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_selection_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Holds the currently selected cell (or null if none).

@ProviderFor(SelectedCellNotifier)
final selectedCellProvider = SelectedCellNotifierProvider._();

/// Holds the currently selected cell (or null if none).
final class SelectedCellNotifierProvider
    extends $NotifierProvider<SelectedCellNotifier, SelectedCell?> {
  /// Holds the currently selected cell (or null if none).
  SelectedCellNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedCellProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedCellNotifierHash();

  @$internal
  @override
  SelectedCellNotifier create() => SelectedCellNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SelectedCell? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SelectedCell?>(value),
    );
  }
}

String _$selectedCellNotifierHash() =>
    r'a42805b62f08fce49c4b565f43fd9b26c26d9a5e';

/// Holds the currently selected cell (or null if none).

abstract class _$SelectedCellNotifier extends $Notifier<SelectedCell?> {
  SelectedCell? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SelectedCell?, SelectedCell?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SelectedCell?, SelectedCell?>,
              SelectedCell?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Holds the current word direction (horizontal or vertical).

@ProviderFor(WordDirectionNotifier)
final wordDirectionProvider = WordDirectionNotifierProvider._();

/// Holds the current word direction (horizontal or vertical).
final class WordDirectionNotifierProvider
    extends $NotifierProvider<WordDirectionNotifier, WordDirection> {
  /// Holds the current word direction (horizontal or vertical).
  WordDirectionNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wordDirectionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wordDirectionNotifierHash();

  @$internal
  @override
  WordDirectionNotifier create() => WordDirectionNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WordDirection value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WordDirection>(value),
    );
  }
}

String _$wordDirectionNotifierHash() =>
    r'0eb3385b01e7843f6a8b69fc0733dfcfa6e0e510';

/// Holds the current word direction (horizontal or vertical).

abstract class _$WordDirectionNotifier extends $Notifier<WordDirection> {
  WordDirection build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<WordDirection, WordDirection>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WordDirection, WordDirection>,
              WordDirection,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
