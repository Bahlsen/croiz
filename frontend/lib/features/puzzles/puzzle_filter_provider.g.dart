// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'puzzle_filter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for managing puzzle filter state.

@ProviderFor(PuzzleFilter)
final puzzleFilterProvider = PuzzleFilterProvider._();

/// Notifier for managing puzzle filter state.
final class PuzzleFilterProvider
    extends $NotifierProvider<PuzzleFilter, PuzzleFilterState> {
  /// Notifier for managing puzzle filter state.
  PuzzleFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'puzzleFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$puzzleFilterHash();

  @$internal
  @override
  PuzzleFilter create() => PuzzleFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PuzzleFilterState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PuzzleFilterState>(value),
    );
  }
}

String _$puzzleFilterHash() => r'ed4e9550f0cd1a7f6df9b2a0601b834048b324d6';

/// Notifier for managing puzzle filter state.

abstract class _$PuzzleFilter extends $Notifier<PuzzleFilterState> {
  PuzzleFilterState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PuzzleFilterState, PuzzleFilterState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PuzzleFilterState, PuzzleFilterState>,
              PuzzleFilterState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
