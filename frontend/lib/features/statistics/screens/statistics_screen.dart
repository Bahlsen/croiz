import 'package:croiz/features/statistics/models/achievement.dart';
import 'package:croiz/features/statistics/providers/statistics_providers.dart';
import 'package:croiz/features/statistics/widgets/achievement_badge.dart';
import 'package:croiz/features/statistics/widgets/stats_summary_card.dart';
import 'package:croiz/features/statistics/widgets/streak_calendar.dart';
import 'package:croiz/features/statistics/widgets/completion_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/l10n/app_localizations.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final userStatsAsync = ref.watch(userStatsProvider);
    final recentCompletionsAsync = ref.watch(
      recentCompletionsProvider(limit: 5),
    );
    final allCompletionsAsync = ref.watch(allCompletionsProvider);
    final unlockedAchievementsAsync = ref.watch(unlockedAchievementsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.statisticsTitle), centerTitle: true),
      body: userStatsAsync.when(
        data:
            (stats) => RefreshIndicator(
              onRefresh: () => ref.read(userStatsProvider.notifier).refresh(),
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                children: [
                  // Summary Section
                  Text(
                    l10n.statsSummary,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn().slideX(),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.3,
                    children: [
                      StatsSummaryCard(
                        label: l10n.totalPuzzles,
                        value: '${stats.totalPuzzlesCompleted}',
                        icon: Icons.extension_rounded,
                        color: Colors.blue,
                      ),
                      StatsSummaryCard(
                        label: l10n.currentStreak,
                        value: l10n.dayStreak(stats.currentStreak),
                        icon: Icons.local_fire_department_rounded,
                        color: Colors.orange,
                      ),
                      StatsSummaryCard(
                        label: l10n.longestStreak,
                        value: l10n.dayStreak(stats.longestStreak),
                        icon: Icons.emoji_events_rounded,
                        color: Colors.amber,
                      ),
                      StatsSummaryCard(
                        label: l10n.totalTime,
                        value: _formatTotalTime(stats.totalPlayTimeSeconds),
                        icon: Icons.timer_rounded,
                        color: Colors.green,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Achievements Section
                  Text(
                    l10n.achievements,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn().slideX(),
                  const SizedBox(height: 16),

                  unlockedAchievementsAsync.when(
                    data: (unlockedIds) {
                      final unlockedSet = unlockedIds.toSet();
                      return SizedBox(
                        height: 140,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: AchievementId.values.length,
                          separatorBuilder:
                              (context, index) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final id = AchievementId.values[index];
                            final isUnlocked = unlockedSet.contains(id);
                            return AchievementBadge(
                              id: id,
                              isUnlocked: isUnlocked,
                            );
                          },
                        ),
                      ).animate().fadeIn(delay: 100.ms).slideX();
                    },
                    loading:
                        () => const SizedBox(
                          height: 140,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    error: (e, s) => Text('Error loading achievements: $e'),
                  ),

                  const SizedBox(height: 32),

                  // Charts Section
                  allCompletionsAsync.when(
                    data:
                        (completions) => Column(
                          children: [
                            if (completions.isNotEmpty) ...[
                              StreakCalendar(completions: completions),
                              const SizedBox(height: 32),
                              CompletionChart(completions: completions),
                              const SizedBox(height: 32),
                            ],
                          ],
                        ),
                    loading:
                        () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    error:
                        (err, stack) =>
                            const SizedBox.shrink(), // Fail silently for charts
                  ),

                  // Recent Completions Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.recentCompletions,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.history_rounded,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ).animate().fadeIn(delay: 200.ms).slideX(),
                  const SizedBox(height: 16),

                  recentCompletionsAsync.when(
                    data:
                        (completions) =>
                            completions.isEmpty
                                ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 24,
                                    ),
                                    child: Text(
                                      'No puzzles completed yet!',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color:
                                                theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                          ),
                                    ),
                                  ),
                                )
                                : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: completions.length,
                                  separatorBuilder:
                                      (context, index) =>
                                          const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final completion = completions[index];
                                    return _CompletionListTile(
                                      completion: completion,
                                    );
                                  },
                                ),
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Text('Error: $err'),
                  ),
                ],
              ),
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  String _formatTotalTime(int seconds) {
    final duration = Duration(seconds: seconds);
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
    return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
  }
}

class _CompletionListTile extends StatelessWidget {
  const _CompletionListTile({required this.completion});

  final dynamic completion; // Should be PuzzleStat

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_rounded,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Puzzle ${completion.puzzleId.substring(0, 8)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${completion.formattedTime} • ${l10n.accuracy}: ${(completion.accuracy * 100).toInt()}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (completion.isPerfect)
            const Tooltip(
              message: 'Perfect!',
              child: Icon(Icons.star_rounded, color: Colors.amber, size: 28),
            ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }
}
