import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/logic/progress_calculator.dart';

class ProgressBarChart extends StatelessWidget {
  final List<DailyProgress> data;

  const ProgressBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    const double chartHeight = 150.0;

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = colorScheme.onSurface.withValues(
      alpha: 0.6,
    ); // Adaptive Grey

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Y-Axis Label
              RotatedBox(
                quarterTurns: -1,
                child: Text(
                  "percent_completion".tr(),
                  style: TextStyle(
                    fontSize: 10,
                    color: labelColor, // Dynamic
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              SizedBox(
                height: chartHeight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildYLabel("hundred".tr(), labelColor),
                    _buildYLabel("sevety_five".tr(), labelColor),
                    _buildYLabel("fifty".tr(), labelColor),
                    _buildYLabel("twenty_five".tr(), labelColor),
                    _buildYLabel("zero".tr(), labelColor),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: data.asMap().entries.map((entry) {
                    final index = entry.key;
                    final day = entry.value;

                    return Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // THE BAR
                          SizedBox(
                            height: chartHeight,
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Tooltip(
                                  message:
                                      "${DateFormat('MMM d').format(day.date)}: ${(day.percentage * 100).toInt()}%",
                                  child: Container(
                                    width: 4,
                                    height: day.percentage == 0.0
                                        ? 4
                                        : chartHeight * day.percentage,
                                    decoration: BoxDecoration(
                                      color: _getBarColor(
                                        day.percentage,
                                        isDark,
                                        colorScheme,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          SizedBox(
                            height: 16,
                            child: ((data.length - 1 - index) % 5 == 0)
                                ? RotatedBox(
                                    quarterTurns: -1,
                                    child: Text(
                                      DateFormat('d').format(day.date),
                                      style: TextStyle(
                                        fontSize: 5,
                                        color: labelColor,
                                        fontWeight: FontWeight.w800,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            "days".tr(),
            style: TextStyle(
              fontSize: 11,
              color: labelColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYLabel(String text, Color color) {
    return Text(text, style: TextStyle(fontSize: 10, color: color));
  }

  Color _getBarColor(double percentage, bool isDark, ColorScheme colorScheme) {
    if (percentage == 1.0) return AppColors.secondary; // Perfect

    if (percentage == 0.0) return isDark ? Colors.white10 : Colors.grey[300]!;

    return colorScheme.onSurface.withValues(alpha: 0.6); // Partial
  }
}
