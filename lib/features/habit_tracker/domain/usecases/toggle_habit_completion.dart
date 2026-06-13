import '../repositories/i_habit_repository.dart';
import '../entities/habit_entity.dart';

class ToggleHabitCompletion {
  final IHabitRepository repository;

  ToggleHabitCompletion(this.repository);

  Future<void> call(HabitEntity habit, DateTime date) async {
    // 1. Business Logic: Check if date exists
    final isCompleted = habit.completedDates.any((d) => 
       d.year == date.year && d.month == date.month && d.day == date.day
    );

    List<DateTime> updatedDates = List.from(habit.completedDates);
    
    if (isCompleted) {
      updatedDates.removeWhere((d) => 
        d.year == date.year && d.month == date.month && d.day == date.day
      );
    } else {
      updatedDates.add(date);
    }

    // Create new Entity (Immutability)
    final updatedHabit = HabitEntity(
      id: habit.id,
      title: habit.title,
      iconCode: habit.iconCode,
      colorValue: habit.colorValue,
      completedDates: updatedDates,
      frequency: habit.frequency,
      targetDays: habit.targetDays,
      createdAt: habit.createdAt,
    );

    // Save via Repository
    await repository.updateHabit(updatedHabit);
  }
}