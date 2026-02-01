import 'package:croiz/features/statistics/models/puzzle_stat.dart';
import 'package:croiz/l10n/app_localizations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class CompletionChart extends StatelessWidget {
  const CompletionChart({required this.completions, super.key});

  final List<PuzzleStat> completions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Process data: Last 7 days counts
    final now = DateTime.now();
    final dayCounts = <int, int>{};

    // Initialize last 7 days with 0
    for (var i = 0; i < 7; i++) {
      dayCounts[i] = 0;
    }

    for (final stat in completions) {
      final difference = now.difference(stat.completedAt).inDays;
      if (difference < 7 && difference >= 0) {
        // 0 is today, 6 is 7 days ago
        // We want to map it so index 6 is today, 0 is 7 days ago for the chart x-axis
        final index = 6 - difference;
        dayCounts[index] = (dayCounts[index] ?? 0) + 1;
      }
    }

    // Find max Y for scaling
    var maxY = 0;
    for (final count in dayCounts.values) {
      if (count > maxY) {
        maxY = count;
      }
    }
    // Add some padding to Y axis
    maxY = (maxY < 5) ? 5 : maxY + 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.weeklyActivity, // "Weekly Activity"
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY.toDouble(),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor:
                      (_) => theme.colorScheme.surfaceContainerHighest,

                  getTooltipItem:
                      (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                        rod.toY.round().toString(),
                        TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index > 6) {
                        return const SizedBox.shrink();
                      }

                      // Calculate date for label
                      // index 6 is today
                      // index 0 is 6 days ago
                      final day = now.subtract(Duration(days: 6 - index));
                      final label =
                          DateFormat.E().format(day)[0]; // First letter of day

                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(7, (index) {
                final count = dayCounts[index] ?? 0;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: count.toDouble(),
                      color: theme.colorScheme.primary,
                      width: 16,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: maxY.toDouble(),
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),
      ],
    );
  }
}
