// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_elapsed_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Stream provider that emits the elapsed seconds for the given `gameId`
/// every second.

@ProviderFor(elapsedSeconds)
final elapsedSecondsProvider = ElapsedSecondsFamily._();

/// Stream provider that emits the elapsed seconds for the given `gameId`
/// every second.

final class ElapsedSecondsProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// Stream provider that emits the elapsed seconds for the given `gameId`
  /// every second.
  ElapsedSecondsProvider._({
    required ElapsedSecondsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'elapsedSecondsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$elapsedSecondsHash();

  @override
  String toString() {
    return r'elapsedSecondsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    final argument = this.argument as String;
    return elapsedSeconds(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ElapsedSecondsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$elapsedSecondsHash() => r'44ac755e62a6e29342fd6c7921c8f5687fac1a4f';

/// Stream provider that emits the elapsed seconds for the given `gameId`
/// every second.

final class ElapsedSecondsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<int>, String> {
  ElapsedSecondsFamily._()
    : super(
        retry: null,
        name: r'elapsedSecondsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Stream provider that emits the elapsed seconds for the given `gameId`
  /// every second.

  ElapsedSecondsProvider call(String gameId) =>
      ElapsedSecondsProvider._(argument: gameId, from: this);

  @override
  String toString() => r'elapsedSecondsProvider';
}
