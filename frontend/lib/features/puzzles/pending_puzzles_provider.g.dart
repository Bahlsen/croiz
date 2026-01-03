// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_puzzles_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PendingPuzzles)
final pendingPuzzlesProvider = PendingPuzzlesProvider._();

final class PendingPuzzlesProvider
    extends $NotifierProvider<PendingPuzzles, List<PendingPuzzle>> {
  PendingPuzzlesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingPuzzlesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingPuzzlesHash();

  @$internal
  @override
  PendingPuzzles create() => PendingPuzzles();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<PendingPuzzle> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PendingPuzzle>>(value),
    );
  }
}

String _$pendingPuzzlesHash() => r'734677012c8842ed4c6ca4b72044c79be9600b93';

abstract class _$PendingPuzzles extends $Notifier<List<PendingPuzzle>> {
  List<PendingPuzzle> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<PendingPuzzle>, List<PendingPuzzle>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<PendingPuzzle>, List<PendingPuzzle>>,
              List<PendingPuzzle>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
