import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker_app_2026/core/constants/app_icons.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/data/models/habit_model.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/pages/habit_history_page.dart';
import 'package:hive/hive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/logic/progress_calculator.dart';
import '../widgets/progress_bar_chart.dart';

class ProgressPage extends ConsumerWidget {
  const ProgressPage({super.key});
 

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final box = Hive.box<HabitModel>('habits');
    final allHabitEntities = box.values.map((model) => model.toEntity()).toList();
    final stats = ProgressCalculator.calculate(allHabitEntities);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final labelColor = colorScheme.onSurface.withValues(alpha: 0.6);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "progress_insights".tr(),
          style: textTheme.displayMedium?.copyWith(fontSize: 24),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildSummaryBox(
                    context,
                    "all_habits".tr(),
                    "${stats.totalHabits}",
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryBox(
                    context,
                    "active".tr(),
                    "${stats.activeCount}",
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryBox(
                    context,
                    "stalled".tr(),
                    "${stats.stalledCount}",
                    Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Semantics(
              label: "average_completion_rate".tr(
                args: [(stats.avgCompletionRate * 100).toStringAsFixed(1)],
              ),
              excludeSemantics: true,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "completion_rate".tr(),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "last_30_days".tr(),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "${(stats.avgCompletionRate * 100).toStringAsFixed(1)}%",
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            Text(
              "consistency_trend".tr(),
              style: textTheme.labelSmall?.copyWith(
                color: labelColor,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Semantics(
              label: "chart_consistency_trend".tr(),
              child: ProgressBarChart(data: stats.last30Days),
            ),

            const SizedBox(height: 32),

            // ROW 4: DAY BREAKDOWN
            Row(
              children: [
                Expanded(
                  child: _buildSummaryBox(
                    context,
                    "perfect_days".tr(),
                    "${stats.perfectDays}",
                    AppColors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryBox(
                    context,
                    "partial_days".tr(),
                    "${stats.partialDays}",
                    AppColors.yellow,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryBox(
                    context,
                    "missed_days".tr(),
                    "${stats.missedDays}",
                    AppColors.error,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // LEADERBOARD
            Text(
              "habit_success_rate".tr(),
              style: textTheme.labelSmall?.copyWith(
                color: labelColor,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            ...stats.leaderboard.map(
              (item) => _buildLeaderboardTile(context, item),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBox(
    BuildContext context,
    String title,
    String value,
    Color color,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: "$title: $value",
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: colorScheme.surface, // <--- Dynamic Surface
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardTile(BuildContext context, HabitSuccessRate item) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HabitHistoryPage(habit: item.habit),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface, // <--- Dynamic Surface
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Semantics(
              label: "habit_success_status".tr(
                args: [item.habit.title, (item.rate * 100).toString()],
              ),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(item.habit.colorValue).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  AppIcons.getIcon(item.habit.iconCode),
                  color: Color(item.habit.colorValue),
                  size: 26,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                item.habit.title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: colorScheme.onSurface,
                ), 
              ),
            ),
            Text(
              "${(item.rate * 100).toInt()}%",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: item.rate > 0.8
                    ? AppColors.green
                    : (item.rate > 0.5 ? AppColors.yellow : AppColors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
