// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'end_game_overlay_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EndGameOverlayVisibleNotifier)
final endGameOverlayVisibleProvider = EndGameOverlayVisibleNotifierProvider._();

final class EndGameOverlayVisibleNotifierProvider
    extends $NotifierProvider<EndGameOverlayVisibleNotifier, bool> {
  EndGameOverlayVisibleNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'endGameOverlayVisibleProvider',
        isAutoDispose: false,
        dependencies: <ProviderOrFamily>[selectedPuzzleIdProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          EndGameOverlayVisibleNotifierProvider.$allTransitiveDependencies0,
        ],
      );

  static final $allTransitiveDependencies0 = selectedPuzzleIdProvider;

  @override
  String debugGetCreateSourceHash() => _$endGameOverlayVisibleNotifierHash();

  @$internal
  @override
  EndGameOverlayVisibleNotifier create() => EndGameOverlayVisibleNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$endGameOverlayVisibleNotifierHash() =>
    r'da17b154a5aff9546bada85c568cb73adda3a8be';

abstract class _$EndGameOverlayVisibleNotifier extends $Notifier<bool> {
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
