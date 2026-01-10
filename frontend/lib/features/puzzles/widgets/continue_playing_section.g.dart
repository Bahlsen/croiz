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
        dependencies: <ProviderOrFamily>[
          puzzleStorageProvider,
          puzzleProgressServiceProvider,
          puzzlesProvider,
        ],
        $allTransitiveDependencies: <ProviderOrFamily>{
          InProgressPuzzlesProvider.$allTransitiveDependencies0,
          InProgressPuzzlesProvider.$allTransitiveDependencies1,
          InProgressPuzzlesProvider.$allTransitiveDependencies2,
          InProgressPuzzlesProvider.$allTransitiveDependencies3,
          InProgressPuzzlesProvider.$allTransitiveDependencies4,
        },
      );

  static final $allTransitiveDependencies0 = puzzleStorageProvider;
  static final $allTransitiveDependencies1 =
      PuzzleStorageProvider.$allTransitiveDependencies0;
  static final $allTransitiveDependencies2 = puzzleProgressServiceProvider;
  static final $allTransitiveDependencies3 = puzzlesProvider;
  static final $allTransitiveDependencies4 =
      PuzzlesProvider.$allTransitiveDependencies0;

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

String _$inProgressPuzzlesHash() => r'488690e5ab67fa4886b037a7c3588f82a47b4272';
