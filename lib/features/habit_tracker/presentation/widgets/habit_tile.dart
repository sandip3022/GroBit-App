import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker_app_2026/core/constants/app_icons.dart';
import '../../domain/entities/habit_entity.dart';
import '../../../../core/theme/app_colors.dart';

class HabitTile extends StatelessWidget {
  final HabitEntity habit;
  final bool isCompletedToday;
  final VoidCallback onToggle;
  final VoidCallback onLongPressBody;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ConfettiController confettiController;

  const HabitTile({
    super.key,
    required this.habit,
    required this.isCompletedToday,
    required this.onToggle,
    required this.onLongPressBody,
    required this.onEdit,
    required this.onDelete,
    required this.confettiController,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Get Theme Data for Dynamic Colors
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final habitColor = Color(habit.colorValue);

    return Stack(
      children: [
         Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Semantics(
              hint: "view_habit_history".tr(),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onLongPress: onLongPressBody,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // --- 1. THEMED ICON BOX ---
                      _buildIconBox(habitColor),
        
                      const SizedBox(width: 16),
        
                      // --- 2. TITLE & STREAK INFO ---
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              habit.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                decoration: isCompletedToday
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: isCompletedToday
                                    ? colorScheme.onSurface.withValues(alpha: 0.5)
                                    : colorScheme.onSurface,
                              ),
                            ),
        
                            const SizedBox(height: 6),
        
                            // Streak Badge
                            if (habit.currentStreak > 0)
                              Row(
                                children: [
                                  ExcludeSemantics(
                                    child: Icon(
                                      Icons.local_fire_department_rounded,
                                      size: 14,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "habit_streak".tr(
                                      args: [habit.currentStreak.toString()],
                                    ),
                                    style: textTheme.labelSmall?.copyWith(
                                      color: AppColors.secondary,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Text(
                                "start_your_journey_today".tr(),
                                style: textTheme.bodySmall?.copyWith(
                                  fontSize: 12,
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
        
                      // --- 3. CHECK BUTTON ---
                      Semantics(
                        button: true,
                        checked: isCompletedToday,
                        label: "toggle_completion".tr(args: [habit.title]),
                        child: GestureDetector(
                          onTap: onToggle,
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _buildCheckButton(
                              habitColor,
                              colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
        
                      const SizedBox(width: 8),
        
                      // --- 4. MENU ---
                      Semantics(
                        label: "habit_options_menu".tr(),
                        child: _buildOptionsMenu(context, colorScheme),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
            
         
        Align(
        alignment: AlignmentGeometry.topCenter,
        child: ConfettiWidget(confettiController: confettiController,
        blastDirection: pi,
        emissionFrequency: 0.02,
        numberOfParticles: 20,
        gravity: 0.4,
        shouldLoop: false,
        blastDirectionality: BlastDirectionality.explosive,
        createParticlePath: (size) => drawStar(size),          
        ),
      ),
    
      ]
      
      
    
    );
  }

  Widget _buildIconBox(Color color) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        // Dynamic Tint
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child:
          Icon(AppIcons.getIcon(habit.iconCode), color: color, size: 26),
    );
  }

  Widget _buildCheckButton(Color color, Color borderColor) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      height: 32,
      width: 32,
      decoration: BoxDecoration(
        color: isCompletedToday ? color : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          // Border adapts to theme when unchecked (Greyish on both modes)
          color: isCompletedToday ? color : borderColor.withValues(alpha: 0.3),
          width: 2.5,
        ),
      ),
      child: isCompletedToday
          ? const Icon(Icons.check, size: 20, color: Colors.white)
          : null,
    );
  }

  Widget _buildOptionsMenu(BuildContext context, ColorScheme colorScheme) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: colorScheme.onSurface.withValues(alpha: 0.5),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: colorScheme.surface, // Dynamic Menu Background
      elevation: 4,
      // Tooltip provides native accessibility labels automatically
      tooltip: "show_options".tr(),
      onSelected: (value) {
        if (value == 'edit') onEdit();
        if (value == 'delete') onDelete();
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 20, color: colorScheme.onSurface),
              const SizedBox(width: 12),
              Text('edit'.tr(), style: TextStyle(color: colorScheme.onSurface)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              const Icon(
                Icons.delete_outline,
                size: 20,
                color: AppColors.error,
              ),
              const SizedBox(width: 12),
              Text('delete'.tr(), style: TextStyle(color: AppColors.error)),
            ],
          ),
        ),
      ],
    );
  }

 Path drawStar(Size size){
  final Path path = Path();

  double width = size.width;
  double halfWidth = width/ 2;

  const int points = 5;

  final double externalRadius = halfWidth;
  final double internalRadius = halfWidth * 0.45;

  for (int i = 0; i < points*2;i++){
    final radius = i.isEven ? externalRadius : internalRadius;

    final angle = (pi/points) * i - pi*2;

    final x = halfWidth + radius * cos(angle);
    final y = halfWidth + radius * sin(angle);

    if (i == 0){
      path.moveTo(x, y);
    } else{
      path.lineTo(x, y);
    }
  }
  path.close();

  return path;
 }
}
