// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'continue_playing_section.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider that returns the list of in-progress puzzles sorted by recency.
///
/// Fetches all puzzles with saved progress, calculates completion percent,
/// and returns them sorted by most recently played.

@ProviderFor(inProgressPuzzles)
final inProgressPuzzlesProvider = InProgressPuzzlesProvider._();

/// Provider that returns the list of in-progress puzzles sorted by recency.
///
/// Fetches all puzzles with saved progress, calculates completion percent,
/// and returns them sorted by most recently played.

final class InProgressPuzzlesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<InProgressPuzzleInfo>>,
          List<InProgressPuzzleInfo>,
          FutureOr<List<InProgressPuzzleInfo>>
        >
    with
        $FutureModifier<List<InProgressPuzzleInfo>>,
        $FutureProvider<List<InProgressPuzzleInfo>> {
  /// Provider that returns the list of in-progress puzzles sorted by recency.
  ///
  /// Fetches all puzzles with saved progress, calculates completion percent,
  /// and returns them sorted by most recently played.
  InProgressPuzzlesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inProgressPuzzlesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inProgressPuzzlesHash();

  @$internal
  @override
  $FutureProviderElement<List<InProgressPuzzleInfo>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<InProgressPuzzleInfo>> create(Ref ref) {
    return inProgressPuzzles(ref);
  }
}

String _$inProgressPuzzlesHash() => r'e7e04dc7774739f894d2db2578f308a304ff759f';
