// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A stream-based notifier that broadcasts newly unlocked achievements.
///
/// This notifier uses a broadcast [StreamController] to allow multiple listeners
/// (e.g., the `AchievementListener` widget) to react to achievement unlocks.
///
/// ## Usage:
/// ```dart
/// // Listen to achievements (typically done in AchievementListener)
/// ref.listen(achievementNotifier, (previous, next) {
///   if (next is AsyncData<List<AchievementId>>) {
///     // Show popup for next.value
///   }
/// });
///
/// // Notify about new achievements (typically done in StatisticsService)
/// ref.read(achievementNotifier.notifier).notifyAchievements([
///   AchievementId.firstPuzzle,
/// ]);
/// ```

@ProviderFor(AchievementNotifier)
final achievementNotifier = AchievementNotifierProvider._();

/// A stream-based notifier that broadcasts newly unlocked achievements.
///
/// This notifier uses a broadcast [StreamController] to allow multiple listeners
/// (e.g., the `AchievementListener` widget) to react to achievement unlocks.
///
/// ## Usage:
/// ```dart
/// // Listen to achievements (typically done in AchievementListener)
/// ref.listen(achievementNotifier, (previous, next) {
///   if (next is AsyncData<List<AchievementId>>) {
///     // Show popup for next.value
///   }
/// });
///
/// // Notify about new achievements (typically done in StatisticsService)
/// ref.read(achievementNotifier.notifier).notifyAchievements([
///   AchievementId.firstPuzzle,
/// ]);
/// ```
final class AchievementNotifierProvider
    extends $StreamNotifierProvider<AchievementNotifier, List<AchievementId>> {
  /// A stream-based notifier that broadcasts newly unlocked achievements.
  ///
  /// This notifier uses a broadcast [StreamController] to allow multiple listeners
  /// (e.g., the `AchievementListener` widget) to react to achievement unlocks.
  ///
  /// ## Usage:
  /// ```dart
  /// // Listen to achievements (typically done in AchievementListener)
  /// ref.listen(achievementNotifier, (previous, next) {
  ///   if (next is AsyncData<List<AchievementId>>) {
  ///     // Show popup for next.value
  ///   }
  /// });
  ///
  /// // Notify about new achievements (typically done in StatisticsService)
  /// ref.read(achievementNotifier.notifier).notifyAchievements([
  ///   AchievementId.firstPuzzle,
  /// ]);
  /// ```
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
    r'54e8217fbcf281c9781ce8928218ee0abb581ccb';

/// A stream-based notifier that broadcasts newly unlocked achievements.
///
/// This notifier uses a broadcast [StreamController] to allow multiple listeners
/// (e.g., the `AchievementListener` widget) to react to achievement unlocks.
///
/// ## Usage:
/// ```dart
/// // Listen to achievements (typically done in AchievementListener)
/// ref.listen(achievementNotifier, (previous, next) {
///   if (next is AsyncData<List<AchievementId>>) {
///     // Show popup for next.value
///   }
/// });
///
/// // Notify about new achievements (typically done in StatisticsService)
/// ref.read(achievementNotifier.notifier).notifyAchievements([
///   AchievementId.firstPuzzle,
/// ]);
/// ```

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
