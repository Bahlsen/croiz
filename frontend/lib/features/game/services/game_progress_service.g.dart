// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_progress_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(gameProgressService)
final gameProgressServiceProvider = GameProgressServiceProvider._();

final class GameProgressServiceProvider
    extends
        $FunctionalProvider<
          GameProgressService,
          GameProgressService,
          GameProgressService
        >
    with $Provider<GameProgressService> {
  GameProgressServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gameProgressServiceProvider',
        isAutoDispose: false,
        dependencies: <ProviderOrFamily>[
          wordCheckServiceProvider,
          puzzleStorageProvider,
        ],
        $allTransitiveDependencies: <ProviderOrFamily>[
          GameProgressServiceProvider.$allTransitiveDependencies0,
          GameProgressServiceProvider.$allTransitiveDependencies1,
          GameProgressServiceProvider.$allTransitiveDependencies2,
        ],
      );

  static final $allTransitiveDependencies0 = wordCheckServiceProvider;
  static final $allTransitiveDependencies1 = puzzleStorageProvider;
  static final $allTransitiveDependencies2 =
      PuzzleStorageProvider.$allTransitiveDependencies0;

  @override
  String debugGetCreateSourceHash() => _$gameProgressServiceHash();

  @$internal
  @override
  $ProviderElement<GameProgressService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GameProgressService create(Ref ref) {
    return gameProgressService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GameProgressService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GameProgressService>(value),
    );
  }
}

String _$gameProgressServiceHash() =>
    r'779054a0765d76f877923568bedb2a1d623c60a6';
