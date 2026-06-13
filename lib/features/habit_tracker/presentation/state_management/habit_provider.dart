import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/data/models/habit_model.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/habit_entity.dart';
import '../../domain/usecases/get_habits_for_date.dart';
import '../../domain/usecases/toggle_habit_completion.dart';
import '../../domain/usecases/create_habit.dart';
import '../../domain/usecases/delete_habit.dart';
import '../../domain/usecases/update_habit.dart';

// --- NEW: DATE PROVIDER ---
// Stores the currently selected date (Defaults to Today)
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

class HabitState {
  final List<HabitEntity> habits;
  HabitState(this.habits);
}

class HabitNotifier extends StateNotifier<HabitState> {
  final GetHabitsForDate _getHabitsUseCase;
  final ToggleHabitCompletion _toggleUseCase;
  final CreateHabit _createUseCase;
  final DeleteHabit _deleteUseCase;
  final UpdateHabit _updateUseCase;

  HabitNotifier({
    required GetHabitsForDate getHabitsUseCase,
    required ToggleHabitCompletion toggleUseCase,
    required CreateHabit createUseCase,
    required DeleteHabit deleteUseCase,
    required UpdateHabit updateUseCase,
  }) : _getHabitsUseCase = getHabitsUseCase,
       _toggleUseCase = toggleUseCase,
       _createUseCase = createUseCase,
       _deleteUseCase = deleteUseCase,
       _updateUseCase = updateUseCase,
       super(HabitState([]));

  void toggle(HabitEntity habit, DateTime date) async {
    await _toggleUseCase.call(habit, date); 
    loadHabits(date); // Reload that date's data
  }

  void addHabit(HabitEntity habit, DateTime currentDate) async {
    await _createUseCase.call(habit);
    loadHabits(currentDate);
  }

  void updateHabit(HabitEntity habit, DateTime currentDate) async {
    await _updateUseCase.call(habit);
    loadHabits(currentDate);
  }

  void deleteHabit(HabitEntity habit, DateTime currentDate) async {
    await _deleteUseCase.call(habit);
    loadHabits(currentDate);
  }

  Future<void> importHabits(List<HabitEntity> importedHabits) async {
    for (var habit in importedHabits) {
      await _createUseCase.call(habit);
    }

    await loadHabits(DateTime.now());
  }

  Future<void> resetAllProgress() async {
    final currentHabits = state.habits;
    for (var habit in currentHabits) {
      final resetHabit = HabitEntity(
        id: habit.id,
        title: habit.title,
        iconCode: habit.iconCode,
        colorValue: habit.colorValue,
        completedDates: [], 
        frequency: habit.frequency,
        targetDays: habit.targetDays,
        createdAt:
            DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
      );
      await _updateUseCase.call(resetHabit);
    }
    loadHabits(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));
  }

  Future<void> deleteAllData() async {
    await Hive.box<HabitModel>('habits').clear();
    await Hive.box('settings').clear();
    final settingsBox = Hive.box('settings');
    settingsBox.put('onboardingCompleted', true);

    state = HabitState([]);
  }

  Future<void> reorderHabits(int oldIndex, int newIndex) async {
    final currentHabits = List<HabitEntity>.from(state.habits);

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final habit = currentHabits.removeAt(oldIndex);
    currentHabits.insert(newIndex, habit);

    state = HabitState(currentHabits);

    final orderIds = currentHabits.map((h) => h.id).toList();
    final settingsBox = Hive.box('settings');
    await settingsBox.put('habitOrder', orderIds);
  }

  Future<void> loadHabits(DateTime selectedDate) async {
    List<HabitEntity> fetchedHabits = await _getHabitsUseCase.call(
      selectedDate,
    );

    final settingsBox = Hive.box('settings');
    final List<dynamic>? savedOrderDyn = settingsBox.get('habitOrder');

    if (savedOrderDyn != null) {
      final savedOrder = savedOrderDyn.cast<String>();

      fetchedHabits.sort((a, b) {
        int indexA = savedOrder.indexOf(a.id);
        int indexB = savedOrder.indexOf(b.id);

        if (indexA == -1) return 1;
        if (indexB == -1) return -1;

        return indexA.compareTo(indexB);
      });
    }

    state = HabitState(fetchedHabits);
  }
}
