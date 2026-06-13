import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class DateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Get Theme Data
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    final isToday = CalendarUtils.isSameDay(selectedDate, DateTime.now());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      // Dynamic Background (White in Light Mode, Dark Slate in Dark Mode)
      color: colorScheme.surface, 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new, 
              size: 20, 
              color: colorScheme.onSurface.withValues(alpha: 0.5)
            ),
            onPressed: onPrevious,
          ),

          // DATE DISPLAY
          Column(
            children: [
              Text(
                isToday ? "today".tr() : DateFormat('EEEE').format(selectedDate),
                style: textTheme.labelSmall?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  // Dynamic Grey
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 4),
                Visibility(visible: isToday,child: SizedBox(width: 40), ), 
              Text(
                DateFormat('MMM d, yyyy').format(selectedDate),
                style: textTheme.headlineSmall?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Serif', 
                  // Dynamic Text Color (Black vs White)
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),

          // NEXT BUTTON
                   IconButton(
            icon: Icon(
              Icons.arrow_forward_ios, 
              size: 20, 
              color: colorScheme.onSurface.withValues(alpha: isToday ? 0.15 : 0.5)
            ),
            onPressed: isToday ? null : onNext,
          )
        ],
      ),
    );
  }
}

// Simple Utility to check dates
class CalendarUtils {
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}