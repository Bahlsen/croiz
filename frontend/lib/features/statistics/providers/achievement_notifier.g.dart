// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A notifier that broadcasts newly unlocked achievements.
/// Other parts of the app can listen to this stream to show popups.

@ProviderFor(AchievementNotifier)
final achievementNotifier = AchievementNotifierProvider._();

/// A notifier that broadcasts newly unlocked achievements.
/// Other parts of the app can listen to this stream to show popups.
final class AchievementNotifierProvider
    extends $StreamNotifierProvider<AchievementNotifier, List<AchievementId>> {
  /// A notifier that broadcasts newly unlocked achievements.
  /// Other parts of the app can listen to this stream to show popups.
  AchievementNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'achievementNotifier',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$achievementNotifierHash();

  @$internal
  @override
  AchievementNotifier create() => AchievementNotifier();
}

String _$achievementNotifierHash() =>
    r'7a2740f0da34952744763e8c50f6e1930cac4936';

/// A notifier that broadcasts newly unlocked achievements.
/// Other parts of the app can listen to this stream to show popups.

abstract class _$AchievementNotifier
    extends $StreamNotifier<List<AchievementId>> {
  Stream<List<AchievementId>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<AchievementId>>, List<AchievementId>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<AchievementId>>, List<AchievementId>>,
              AsyncValue<List<AchievementId>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
