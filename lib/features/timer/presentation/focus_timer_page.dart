import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../state_management/timer_provider.dart';

class FocusTimerPage extends ConsumerWidget {
  const FocusTimerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final timerNotifier = ref.read(timerProvider.notifier);

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // --- TIME PRESETS ---
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTimeBadge(context, ref, 1, "Short Break"),
                const SizedBox(width: 12),
              _buildTimeBadge(context, ref, 2, "Pomodoro"),
              const SizedBox(width: 12),
              _buildTimeBadge(context, ref, 15, "Deep Work"),
              const SizedBox(width: 12),
              _buildCustomTimeBadge(context, ref),
            ],
          ),),

          const SizedBox(height: 60),

          // --- CIRCULAR TIMER ---
          Stack(
            alignment: Alignment.center,
            children: [
              // Background Circle
              SizedBox(
                width: 280,
                height: 280,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.05),
                ),
              ),
              // Progress Circle
              SizedBox(
                width: 280,
                height: 280,
                child: CircularProgressIndicator(
                  value: timerState.progress,
                  strokeWidth: 12,
                  backgroundColor: Colors.transparent,
                  color: AppColors.primary,
                  strokeCap: StrokeCap.round,
                ),
              ),
              // Time Text
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timerState.timeString,
                    style: textTheme.displayLarge?.copyWith(
                      fontSize: 64,
                      color: colorScheme.onSurface,
                      fontFeatures: const [
                        FontFeature.tabularFigures(),
                      ], // Keeps text from jumping
                    ),
                  ),
                  Text(
                    timerState.isRunning ? "focusing".tr() : "paused".tr(),
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 80),

          // --- CONTROLS ---
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Reset Button
              IconButton(
                iconSize: 32,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                icon: const Icon(Icons.replay_rounded),
                onPressed: () => timerNotifier.stop(),
              ),
              const SizedBox(width: 32),

              // Play/Pause Button
              GestureDetector(
                onTap: () {
                  if (timerState.isRunning) {
                    timerNotifier.pause();
                  } else {
                    timerNotifier.start();
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: timerState.isRunning
                        ? colorScheme.surface
                        : AppColors.primary,
                    shape: BoxShape.circle,
                    border: timerState.isRunning
                        ? Border.all(color: AppColors.primary, width: 2)
                        : null,
                    boxShadow: [
                      if (!timerState.isRunning)
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                    ],
                  ),
                  child: Icon(
                    timerState.isRunning
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    size: 40,
                    color: timerState.isRunning
                        ? AppColors.primary
                        : Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 32),

              // Placeholder for symmetry
              const SizedBox(width: 48),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBadge(
    BuildContext context,
    WidgetRef ref,
    int minutes,
    String label,
  ) {
    final timerState = ref.watch(timerProvider);
    final isSelected = timerState.totalSeconds == minutes * 60;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => ref.read(timerProvider.notifier).setDuration(minutes),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondary.withValues(alpha: 0.1)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.secondary
                : colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          "minutes".tr(args: [minutes.toString()]), 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected
                ? AppColors.secondary
                : colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTimeBadge(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // Check if the current time is a custom time (not 5, 25, or 50)
    final int minutes = timerState.totalSeconds ~/ 60;
    final bool isCustomSelected =
        minutes != 5 && minutes != 25 && minutes != 50;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showCustomTimeDialog(context, ref);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isCustomSelected
              ? AppColors.secondary.withValues(alpha: 0.1)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCustomSelected
                ? AppColors.secondary
                : colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.add,
              size: 16,
              color: isCustomSelected
                  ? AppColors.secondary
                  : colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 4),
            Text(
              isCustomSelected
                  ? "minutes".tr(args: [minutes.toString()])
                  : "custom".tr(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isCustomSelected
                    ? AppColors.secondary
                    : colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomTimeDialog(BuildContext context, WidgetRef ref) {
    final TextEditingController controller = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "custom_time".tr(),
            style: TextStyle(color: colorScheme.onSurface),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: "mins".tr(),
              hintStyle: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "cancel".tr(),
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                final int? minutes = int.tryParse(controller.text);
                if (minutes != null && minutes > 0) {
                  ref.read(timerProvider.notifier).setDuration(minutes);
                  Navigator.pop(context);
                }
              },
              child: Text(
                "set_timer".tr(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
