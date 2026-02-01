// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the AchievementService instance.

@ProviderFor(achievementService)
final achievementServiceProvider = AchievementServiceProvider._();

/// Provider for the AchievementService instance.

final class AchievementServiceProvider
    extends
        $FunctionalProvider<
          AchievementService,
          AchievementService,
          AchievementService
        >
    with $Provider<AchievementService> {
  /// Provider for the AchievementService instance.
  AchievementServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'achievementServiceProvider',
        isAutoDispose: false,
        dependencies: <ProviderOrFamily>[appDatabaseProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          AchievementServiceProvider.$allTransitiveDependencies0,
        ],
      );

  static final $allTransitiveDependencies0 = appDatabaseProvider;

  @override
  String debugGetCreateSourceHash() => _$achievementServiceHash();

  @$internal
  @override
  $ProviderElement<AchievementService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AchievementService create(Ref ref) {
    return achievementService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AchievementService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AchievementService>(value),
    );
  }
}

String _$achievementServiceHash() =>
    r'9bef9512b253ac5be2b63ed2911160039aef10c4';

/// Provider for the StatisticsService instance.

@ProviderFor(statisticsService)
final statisticsServiceProvider = StatisticsServiceProvider._();

/// Provider for the StatisticsService instance.

final class StatisticsServiceProvider
    extends
        $FunctionalProvider<
          StatisticsService,
          StatisticsService,
          StatisticsService
        >
    with $Provider<StatisticsService> {
  /// Provider for the StatisticsService instance.
  StatisticsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'statisticsServiceProvider',
        isAutoDispose: false,
        dependencies: <ProviderOrFamily>[
          appDatabaseProvider,
          achievementServiceProvider,
        ],
        $allTransitiveDependencies: <ProviderOrFamily>[
          StatisticsServiceProvider.$allTransitiveDependencies0,
          StatisticsServiceProvider.$allTransitiveDependencies1,
        ],
      );

  static final $allTransitiveDependencies0 = appDatabaseProvider;
  static final $allTransitiveDependencies1 = achievementServiceProvider;

  @override
  String debugGetCreateSourceHash() => _$statisticsServiceHash();

  @$internal
  @override
  $ProviderElement<StatisticsService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StatisticsService create(Ref ref) {
    return statisticsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StatisticsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StatisticsService>(value),
    );
  }
}

String _$statisticsServiceHash() => r'27a0549ec90c554daf631479b4b1f31da1fba6b0';

/// Provider for all unlocked achievements.

@ProviderFor(unlockedAchievements)
final unlockedAchievementsProvider = UnlockedAchievementsProvider._();

/// Provider for all unlocked achievements.

final class UnlockedAchievementsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AchievementId>>,
          List<AchievementId>,
          FutureOr<List<AchievementId>>
        >
    with
        $FutureModifier<List<AchievementId>>,
        $FutureProvider<List<AchievementId>> {
  /// Provider for all unlocked achievements.
  UnlockedAchievementsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unlockedAchievementsProvider',
        isAutoDispose: true,
        dependencies: <ProviderOrFamily>[achievementServiceProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          UnlockedAchievementsProvider.$allTransitiveDependencies0,
          UnlockedAchievementsProvider.$allTransitiveDependencies1,
        ],
      );

  static final $allTransitiveDependencies0 = achievementServiceProvider;
  static final $allTransitiveDependencies1 =
      AchievementServiceProvider.$allTransitiveDependencies0;

  @override
  String debugGetCreateSourceHash() => _$unlockedAchievementsHash();

  @$internal
  @override
  $FutureProviderElement<List<AchievementId>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AchievementId>> create(Ref ref) {
    return unlockedAchievements(ref);
  }
}

String _$unlockedAchievementsHash() =>
    r'31fb9b0c689b718043ec2f53e1681a08b081e04f';

/// Provider for the global UserStats.
/// Refreshes automatically whenever stats are updated.

@ProviderFor(UserStatsNotifier)
final userStatsProvider = UserStatsNotifierProvider._();

/// Provider for the global UserStats.
/// Refreshes automatically whenever stats are updated.
final class UserStatsNotifierProvider
    extends $AsyncNotifierProvider<UserStatsNotifier, UserStats> {
  /// Provider for the global UserStats.
  /// Refreshes automatically whenever stats are updated.
  UserStatsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userStatsProvider',
        isAutoDispose: false,
        dependencies: <ProviderOrFamily>[statisticsServiceProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          UserStatsNotifierProvider.$allTransitiveDependencies0,
          UserStatsNotifierProvider.$allTransitiveDependencies1,
          UserStatsNotifierProvider.$allTransitiveDependencies2,
        ],
      );

  static final $allTransitiveDependencies0 = statisticsServiceProvider;
  static final $allTransitiveDependencies1 =
      StatisticsServiceProvider.$allTransitiveDependencies0;
  static final $allTransitiveDependencies2 =
      StatisticsServiceProvider.$allTransitiveDependencies1;

  @override
  String debugGetCreateSourceHash() => _$userStatsNotifierHash();

  @$internal
  @override
  UserStatsNotifier create() => UserStatsNotifier();
}

String _$userStatsNotifierHash() => r'ae6ce1adb7572801e2d2e6884bf016290810aef8';

/// Provider for the global UserStats.
/// Refreshes automatically whenever stats are updated.

abstract class _$UserStatsNotifier extends $AsyncNotifier<UserStats> {
  FutureOr<UserStats> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<UserStats>, UserStats>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UserStats>, UserStats>,
              AsyncValue<UserStats>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Stream provider for recent puzzle completions.

@ProviderFor(recentCompletions)
final recentCompletionsProvider = RecentCompletionsFamily._();

/// Stream provider for recent puzzle completions.

final class RecentCompletionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PuzzleStat>>,
          List<PuzzleStat>,
          Stream<List<PuzzleStat>>
        >
    with $FutureModifier<List<PuzzleStat>>, $StreamProvider<List<PuzzleStat>> {
  /// Stream provider for recent puzzle completions.
  RecentCompletionsProvider._({
    required RecentCompletionsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'recentCompletionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  static final $allTransitiveDependencies0 = statisticsServiceProvider;
  static final $allTransitiveDependencies1 =
      StatisticsServiceProvider.$allTransitiveDependencies0;
  static final $allTransitiveDependencies2 =
      StatisticsServiceProvider.$allTransitiveDependencies1;

  @override
  String debugGetCreateSourceHash() => _$recentCompletionsHash();

  @override
  String toString() {
    return r'recentCompletionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<PuzzleStat>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PuzzleStat>> create(Ref ref) {
    final argument = this.argument as int;
    return recentCompletions(ref, limit: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RecentCompletionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recentCompletionsHash() => r'fc0f19f4c07435e285be8054f354ee837cf22a1f';

/// Stream provider for recent puzzle completions.

final class RecentCompletionsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<PuzzleStat>>, int> {
  RecentCompletionsFamily._()
    : super(
        retry: null,
        name: r'recentCompletionsProvider',
        dependencies: <ProviderOrFamily>[statisticsServiceProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          RecentCompletionsProvider.$allTransitiveDependencies0,
          RecentCompletionsProvider.$allTransitiveDependencies1,
          RecentCompletionsProvider.$allTransitiveDependencies2,
        ],
        isAutoDispose: true,
      );

  /// Stream provider for recent puzzle completions.

  RecentCompletionsProvider call({int limit = 10}) =>
      RecentCompletionsProvider._(argument: limit, from: this);

  @override
  String toString() => r'recentCompletionsProvider';
}

/// Future provider for all puzzle completions (useful for calendar).

@ProviderFor(allCompletions)
final allCompletionsProvider = AllCompletionsProvider._();

/// Future provider for all puzzle completions (useful for calendar).

final class AllCompletionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PuzzleStat>>,
          List<PuzzleStat>,
          FutureOr<List<PuzzleStat>>
        >
    with $FutureModifier<List<PuzzleStat>>, $FutureProvider<List<PuzzleStat>> {
  /// Future provider for all puzzle completions (useful for calendar).
  AllCompletionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allCompletionsProvider',
        isAutoDispose: true,
        dependencies: <ProviderOrFamily>[statisticsServiceProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          AllCompletionsProvider.$allTransitiveDependencies0,
          AllCompletionsProvider.$allTransitiveDependencies1,
          AllCompletionsProvider.$allTransitiveDependencies2,
        ],
      );

  static final $allTransitiveDependencies0 = statisticsServiceProvider;
  static final $allTransitiveDependencies1 =
      StatisticsServiceProvider.$allTransitiveDependencies0;
  static final $allTransitiveDependencies2 =
      StatisticsServiceProvider.$allTransitiveDependencies1;

  @override
  String debugGetCreateSourceHash() => _$allCompletionsHash();

  @$internal
  @override
  $FutureProviderElement<List<PuzzleStat>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PuzzleStat>> create(Ref ref) {
    return allCompletions(ref);
  }
}

String _$allCompletionsHash() => r'bb216d1e059974ea6ad125f879067a15e680517c';
