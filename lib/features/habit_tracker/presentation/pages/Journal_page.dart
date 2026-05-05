import 'package:confetti/confetti.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:habit_tracker_app_2026/features/habit_tracker/domain/entities/habit_entity.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/pages/add_habit_page.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/pages/habit_history_page.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/state_management/habit_provider.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/widgets/app_bar.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/widgets/date_selector.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/widgets/habit_tile.dart';
import 'package:habit_tracker_app_2026/features/onboarding/presentation/state_management/user_provider.dart';
import 'package:habit_tracker_app_2026/features/timer/presentation/timer_home.dart';
import 'package:habit_tracker_app_2026/main.dart';

class JournalPage extends ConsumerStatefulWidget {
  const JournalPage({super.key});

  @override
  ConsumerState<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends ConsumerState<JournalPage> {
  late ConfettiController _confettiController;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final date = ref.read(selectedDateProvider);
      ref.read(habitNotifierProvider.notifier).loadHabits(date);
    });

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  HabitState get habitState => ref.watch(habitNotifierProvider);

  DateTime get selectedDate => ref.watch(selectedDateProvider);
  void _changeDate(int days) {
    final currentDate = ref.read(selectedDateProvider);
    final newDate = currentDate.add(Duration(days: days));

    ref.read(selectedDateProvider.notifier).state = newDate;

    ref.read(habitNotifierProvider.notifier).loadHabits(newDate);
  }

  @override
  Widget build(BuildContext context) {
    final userName = ref.watch(userProvider);
    return Scaffold(
      appBar: HomeAppBar(
        userName: userName.name,
        onTimerTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TimerHome()),
          );
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            DateSelector(
              selectedDate: selectedDate,
              onPrevious: () => _changeDate(-1),
              onNext: () => _changeDate(1),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: habitState.habits.isEmpty
                  ? _buildEmptyState()
                  : ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: habitState.habits.length,
                      onReorder: (oldIndex, newIndex) {
                        ref
                            .read(habitNotifierProvider.notifier)
                            .reorderHabits(oldIndex, newIndex);
                        HapticFeedback.lightImpact();
                      },

                      proxyDecorator:
                          (
                            Widget child,
                            int index,
                            Animation<double> animation,
                          ) {
                            return Material(
                              color: Colors.transparent,
                              elevation: 0,
                              child: child,
                            );
                          },

                      itemBuilder: (context, index) {
                        final habit = habitState.habits[index];

                        return Container(
                          key: ValueKey(habit.id),
                          child: HabitTile(
                            habit: habit,
                            isCompletedToday: habit.isCompletedOn(selectedDate),
                            confettiController: _confettiController,
                            onToggle: () {
                              if (!habit.isCompletedOn(selectedDate)) {
                                _confettiController.play();
                              }

                              ref
                                  .read(habitNotifierProvider.notifier)
                                  .toggle(habit, selectedDate);
                            },
                            onLongPressBody: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      HabitHistoryPage(habit: habit),
                                ),
                              );
                            },
                            onEdit: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AddHabitPage(habitToEdit: habit),
                                ),
                              );
                            },
                            onDelete: () {
                              _showDeleteConfirmation(
                                context,
                                habit,
                                habit.title,
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(
          Icons.add,
          color: Colors.white,
          semanticLabel: "add_new_habit".tr(),
        ),
        onPressed: () async {
          // Pass selectedDate to refresh properly after adding
          final current = ref.read(selectedDateProvider);
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddHabitPage()),
          );
          ref.read(habitNotifierProvider.notifier).loadHabits(current);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 60,
            color: Colors.grey[300],
            semanticLabel: "empty_calendar_icon".tr(),
          ),
          const SizedBox(height: 16),
          Text(
            "no_habits_for_this_day".tr(),
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    HabitEntity habit,
    String title,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("delete_habit").tr(),
        content: Text("delete_habit_confirmation".tr(args: [title])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.inverseSurface,
            ),
            child: const Text("cancel").tr(),
          ),
          TextButton(
            onPressed: () {
              final date = ref.read(selectedDateProvider);
              ref.read(habitNotifierProvider.notifier).deleteHabit(habit, date);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text("delete").tr(),
          ),
        ],
      ),
    );
  }
}
