import 'package:flutter/material.dart'; // Needed for Color

enum HabitFrequency { daily, weekly, specificDays, specificDates }

class HabitEntity {
  final String id;
  final String title;
  final int iconCode;
  final int colorValue;
  final DateTime? createdAt;
  final DateTime? validUntil;
  final List<DateTime> completedDates;

  final HabitFrequency frequency;
  final List<int> targetDays;

  HabitEntity({
    required this.id,
    required this.title,
    required this.iconCode,
    required this.colorValue,
    this.createdAt,
    this.validUntil,
    required this.frequency,
    required this.targetDays,
    required this.completedDates,
  });

  Color get color => Color(colorValue);

  /// Checks if the habit is completed on a specific date (Year/Month/Day)
  bool isCompletedOn(DateTime date) {
    return completedDates.any(
      (d) => d.year == date.year && d.month == date.month && d.day == date.day,
    );
  }

  /// Checks if the habit should appear on the dashboard for this date
  bool isScheduledFor(DateTime date) {
    if (frequency == HabitFrequency.daily) {
      return true;
    }

    if (frequency == HabitFrequency.specificDays) {
      // DateTime.weekday: 1 = Monday, 7 = Sunday
      return targetDays.contains(date.weekday);
    }

    if (frequency == HabitFrequency.specificDates) {
      return targetDays.contains(date.day);
    }

    return true;
  }

  int get currentStreak {
    int streak = 0;
    DateTime checkDate = DateTime.now();

    // Check up to 365 days back
    for (int i = 0; i < 365; i++) {
      if (isScheduledFor(checkDate)) {
        if (isCompletedOn(checkDate)) {
          streak++;
        } else {
          if (!_isSameDay(checkDate, DateTime.now())) {
            break; 
          }
        }
      }
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    return streak;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
