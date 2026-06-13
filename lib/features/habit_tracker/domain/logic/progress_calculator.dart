import '../entities/habit_entity.dart';

class ProgressStats {
  final int totalHabits;
  final int activeCount;
  final int stalledCount;
  final double avgCompletionRate;
  
  final List<DailyProgress> last30Days; 
  
  final int perfectDays;
  final int partialDays;
  final int missedDays;

  final List<HabitSuccessRate> leaderboard;

  ProgressStats({
    required this.totalHabits,
    required this.activeCount,
    required this.stalledCount,
    required this.avgCompletionRate,
    required this.last30Days,
    required this.perfectDays,
    required this.partialDays,
    required this.missedDays,
    required this.leaderboard,
  });
}

class DailyProgress {
  final DateTime date;
  final double percentage; // 0.0 to 1.0
  DailyProgress(this.date, this.percentage);
}

class HabitSuccessRate {
  final HabitEntity habit;
  final double rate; // 0.0 to 1.0
  HabitSuccessRate(this.habit, this.rate);
}

class ProgressCalculator {
  static ProgressStats calculate(List<HabitEntity> habits) {
    if (habits.isEmpty) {
      return ProgressStats(
        totalHabits: 0, activeCount: 0, stalledCount: 0, avgCompletionRate: 0,
        last30Days: [], perfectDays: 0, partialDays: 0, missedDays: 0, leaderboard: []
      );
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    //  ACTIVE vs STALLED 
    // Rule: "Stalled" if not completed in last 7 days (and was created > 7 days ago)
    int active = 0;
    int stalled = 0;

    for (var habit in habits) {
      bool performedRecently = false;
      for (int i = 0; i < 7; i++) {
        final dateToCheck = today.subtract(Duration(days: i));
        if (habit.isCompletedOn(dateToCheck)) {
          performedRecently = true;
          break;
        }
      }
      if (performedRecently) {
        active++;
      } else {
        stalled++;
      }
    }

    // LAST 30 DAYS DATA (Chart + Box Logic) 
    List<DailyProgress> chartData = [];
    int perfect = 0;
    int partial = 0;
    int missed = 0;
    double totalRateSum = 0;
    int daysWithHabits = 0;

    // Iterate backwards from Today to 29 days ago
    for (int i = 29; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      
      int scheduledCount = 0;
      int completedCount = 0;

      for (var habit in habits) {
        // Only count if habit existed on that date
        bool exists = habit.createdAt == null || !date.isBefore(habit.createdAt!);
        
        if (exists && habit.isScheduledFor(date)) {
          scheduledCount++;
          if (habit.isCompletedOn(date)) {
            completedCount++;
          }
        }
      }

      double dailyRate = 0;
      if (scheduledCount > 0) {
        dailyRate = completedCount / scheduledCount;
        daysWithHabits++;
        totalRateSum += dailyRate;

        // Categorize Day
        if (dailyRate == 1.0) {
          perfect++;
        } else if (dailyRate == 0.0) {
          missed++;
        }
        else {
          partial++;
        }
      }
      
      chartData.add(DailyProgress(date, dailyRate));
    }

    double avgRate = daysWithHabits == 0 ? 0 : (totalRateSum / daysWithHabits);

    // LEADERBOARD 
    // Sort by: (Total Completed) / (Total Scheduled Days since creation)
    List<HabitSuccessRate> ranking = [];
    for (var habit in habits) {
      int totalScheduled = 0;
      int totalCompleted = habit.completedDates.length;
      
      // Calculate how many times it SHOULD have been done since creation
      DateTime startDate = habit.createdAt ?? today.subtract(const Duration(days: 30));
      int daysExisting = today.difference(startDate).inDays + 1;
      
      for(int i=0; i<daysExisting; i++) {
        final d = startDate.add(Duration(days: i));
        if (habit.isScheduledFor(d)) totalScheduled++;
      }

      double rate = totalScheduled == 0 ? 0 : totalCompleted / totalScheduled;
      // Cap at 1.0 (in case of data glitches)
      if (rate > 1.0) rate = 1.0; 
      
      ranking.add(HabitSuccessRate(habit, rate));
    }
    
    // Sort descending (High success first)
    ranking.sort((a, b) => b.rate.compareTo(a.rate));

    return ProgressStats(
      totalHabits: habits.length,
      activeCount: active,
      stalledCount: stalled,
      avgCompletionRate: avgRate,
      last30Days: chartData,
      perfectDays: perfect,
      partialDays: partial,
      missedDays: missed,
      leaderboard: ranking,
    );
  }
}