import 'package:croiz/features/statistics/models/puzzle_stat.dart';
import 'package:croiz/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

/// A heatmap calendar similar to GitHub contributions.
/// Shows activity for the last 365 days.
class StreakCalendar extends StatelessWidget {
  const StreakCalendar({required this.completions, super.key});

  final List<PuzzleStat> completions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Process data: Map<DateString, Count>
    final activityMap = <String, int>{};
    for (final stat in completions) {
      final dateKey = _formatDate(stat.completedAt);
      activityMap[dateKey] = (activityMap[dateKey] ?? 0) + 1;
    }

    final now = DateTime.now();
    // Start from one year ago (approx 52 weeks)
    // Adjust to start on a Sunday/Monday depending on locale?
    // For simplicity, let's just show last 16 weeks (approx 4 months) to fit on mobile nicely
    // or maybe vertically scrolling?
    // Let's do a horizontal scrollable view of the last year.

    // Total columns = 52 weeks
    const weeksToShow = 20;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.activityLevel, // "Activity"
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: true, // Show most recent on right
          child: Row(
            children: List.generate(weeksToShow, (weekIndex) {
              // Week 0 is current week
              final weekStart = now.subtract(
                Duration(days: (weeksToShow - 1 - weekIndex) * 7),
              );

              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Column(
                  children: List.generate(7, (dayIndex) {
                    final date = weekStart
                        .subtract(Duration(days: weekStart.weekday - 1))
                        .add(Duration(days: dayIndex));
                    // Check if future
                    if (date.isAfter(now)) {
                      return const SizedBox(width: 12, height: 12);
                    }

                    final dateKey = _formatDate(date);
                    final count = activityMap[dateKey] ?? 0;

                    return Tooltip(
                      message: '${DateFormat.yMMMd().format(date)}: $count',
                      child: Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: _getColorForCount(count, theme),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ).animate().fadeIn().slideX(),
      ],
    );
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Color _getColorForCount(int count, ThemeData theme) {
    if (count == 0) {
      return theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
    }

    // Scale color based on intensity
    if (count == 1) {
      return theme.colorScheme.primary.withValues(alpha: 0.4);
    }
    if (count == 2) {
      return theme.colorScheme.primary.withValues(alpha: 0.6);
    }
    if (count == 3) {
      return theme.colorScheme.primary.withValues(alpha: 0.8);
    }
    return theme.colorScheme.primary;
  }
}
