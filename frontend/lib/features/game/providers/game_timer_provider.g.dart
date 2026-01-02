// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_timer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(gameTimer)
final gameTimerProvider = GameTimerFamily._();

final class GameTimerProvider
    extends $FunctionalProvider<GameTimer, GameTimer, GameTimer>
    with $Provider<GameTimer> {
  GameTimerProvider._({
    required GameTimerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'gameTimerProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$gameTimerHash();

  @override
  String toString() {
    return r'gameTimerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<GameTimer> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GameTimer create(Ref ref) {
    final argument = this.argument as String;
    return gameTimer(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GameTimer value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GameTimer>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GameTimerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$gameTimerHash() => r'cbbdaeb4e63ff5375cbfd87e35eb9b9b5b6a46f8';

final class GameTimerFamily extends $Family
    with $FunctionalFamilyOverride<GameTimer, String> {
  GameTimerFamily._()
    : super(
        retry: null,
        name: r'gameTimerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  GameTimerProvider call(String gameId) =>
      GameTimerProvider._(argument: gameId, from: this);

  @override
  String toString() => r'gameTimerProvider';
}
