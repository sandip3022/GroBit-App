import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker_app_2026/core/constants/app_icons.dart';
import 'package:habit_tracker_app_2026/core/utils/validators.dart';
import 'package:habit_tracker_app_2026/main.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/habit_entity.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/state_management/habit_provider.dart';

class AddHabitPage extends ConsumerStatefulWidget {
  final HabitEntity? habitToEdit;

  const AddHabitPage({super.key, this.habitToEdit});

  @override
  ConsumerState<AddHabitPage> createState() => _AddHabitPageState();
}

class _AddHabitPageState extends ConsumerState<AddHabitPage> {
  final _titleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late Color _selectedColor;
  late IconData _selectedIcon;

  HabitFrequency _frequency = HabitFrequency.daily;
  List<int> _selectedDays = [];

  final List<Color> _colorOptions = [
    AppColors.airForceBlue,
    AppColors.softCoral,
    AppColors.purple,
    AppColors.teal,
    AppColors.blue,
    AppColors.orange,
    AppColors.pink,
  ];

  final List<String> _colorNames = [
    "color_midnight".tr(),
    "color_coral".tr(),
    "color_purple".tr(),
    "color_teal".tr(),
    "color_blue".tr(),
    "color_orange".tr(),
    "color_pink".tr(),
  ];

  final List<String> _iconNames = [
    "icon_book".tr(),
    "icon_fitness".tr(),
    "icon_water".tr(),
    "icon_code".tr(),
    "icon_meditation".tr(),
    "icon_running".tr(),
    "icon_food".tr(),
    "icon_sleep".tr(),
    "icon_savings".tr(),
    "icon_art".tr(),
    "icon_music".tr(),
    "icon_check".tr(),
  ];

  final List<IconData> _iconOptions = [
    Icons.auto_stories,
    Icons.fitness_center,
    Icons.water_drop,
    Icons.code,
    Icons.self_improvement,
    Icons.directions_run,
    Icons.restaurant,
    Icons.bed,
    Icons.savings,
    Icons.palette,
    Icons.music_note,
    Icons.check_circle,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.habitToEdit != null) {
      _titleController.text = widget.habitToEdit!.title;
      _selectedColor = Color(widget.habitToEdit!.colorValue);
      _selectedIcon = AppIcons.getIcon(widget.habitToEdit!.iconCode);
      _frequency = widget.habitToEdit!.frequency;
      _selectedDays = List.from(widget.habitToEdit!.targetDays);
    } else {
      _selectedColor = _colorOptions[0];
      _selectedIcon = _iconOptions[0];
    }
  }

  void _saveHabit() {
    if (_formKey.currentState?.validate() != true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("please_enter_habit_name".tr())));
      return;
    }

    if (_frequency == HabitFrequency.specificDays && _selectedDays.isEmpty) {
      _frequency = HabitFrequency.daily;
    }

    final currentDate = ref.read(selectedDateProvider);

    if (widget.habitToEdit != null) {
      final updatedHabit = HabitEntity(
        id: widget.habitToEdit!.id,
        title: _titleController.text.trim(),
        iconCode: _selectedIcon.codePoint,
        colorValue: _selectedColor.value,
        completedDates: widget.habitToEdit!.completedDates,
        frequency: _frequency,
        targetDays: _selectedDays,
        createdAt: widget.habitToEdit!.createdAt,
      );
      ref
          .read(habitNotifierProvider.notifier)
          .updateHabit(updatedHabit, currentDate);
    } else {
      final newHabit = HabitEntity(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        iconCode: _selectedIcon.codePoint,
        colorValue: _selectedColor.value,
        completedDates: [],
        frequency: _frequency,
        targetDays: _selectedDays,
        createdAt: DateTime.now(),
      );
      ref
          .read(habitNotifierProvider.notifier)
          .addHabit(newHabit, currentDate);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final labelColor = isDark ? Colors.grey[400] : AppColors.textSecondary;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.habitToEdit != null ? "edit_habit".tr() : "new_habit".tr(),
        ),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: colorScheme.onSurface),
          tooltip: "close".tr(),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveHabit,
            child: Text(
              "save".tr(),
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurface,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TITLE INPUT
            Text(
              "what_do_you_want_to_do".tr(),
              style: textTheme.labelSmall?.copyWith(
                color: labelColor,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Form(
                key: _formKey,
                child: TextFormField(
                  controller: _titleController,
                  style: textTheme.bodyLarge?.copyWith(
                    fontSize: 18,
                    color: colorScheme.onSurface,
                  ),
                  validator: (value) {
                    return Validators.validateName(value);
                  },
                  errorBuilder: (context, error) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                      child: Text(
                        error,
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.error,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                      ),
                    );
                  },
                  onChanged: (_) {
                    if (_formKey.currentState?.validate() == true) {
                      setState(() {});
                    }
                  },
                  decoration: InputDecoration(
                    hintText: "example_habit".tr(),
                    hintStyle: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    border: InputBorder.none,
                    icon: Icon(
                      Icons.edit_outlined,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // FREQUENCY
            Text(
              "frequency_all_cap".tr(),
              style: textTheme.labelSmall?.copyWith(
                color: labelColor,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            _buildFrequencyToggle(colorScheme),

            if (_frequency == HabitFrequency.specificDays) ...[
              const SizedBox(height: 16),
              _buildDaySelector(colorScheme),
            ],
            if (_frequency == HabitFrequency.specificDates) ...[
              const SizedBox(height: 16),
              _buildDateSelector(colorScheme),
            ],

            const SizedBox(height: 32),

            Text(
              "appearance_all_cap".tr(),
              style: textTheme.labelSmall?.copyWith(
                color: labelColor,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _colorOptions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final color = _colorOptions[index];
                  final isSelected = _selectedColor == color;
                  return Semantics(
                    button: true,
                    selected: isSelected,
                    label: _colorNames[index],
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isSelected ? 48 : 40,
                        height: isSelected ? 48 : 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(
                                  color: colorScheme.onSurface,
                                  width: 2.5,
                                )
                              : null,
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: color.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                          ],
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              )
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _iconOptions.length,
              itemBuilder: (context, index) {
                final iconData = _iconOptions[index];
                final isSelected =
                    _selectedIcon.codePoint == iconData.codePoint;

                return Semantics(
                  button: true,
                  selected: isSelected,
                  label: _iconNames[index],
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedIcon = iconData),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _selectedColor.withValues(alpha: 0.15)
                            : colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: _selectedColor, width: 2)
                            : Border.all(color: Colors.transparent),
                      ),
                      child: ExcludeSemantics(
                        child: Icon(
                          iconData,
                          color: isSelected
                              ? _selectedColor
                              : colorScheme.onSurface.withValues(alpha: 0.5),
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveHabit,
                child: Text("save".tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencyToggle(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surface, // <--- Dynamic
        borderRadius: BorderRadius.circular(12),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _buildToggleOption(
              "every_day".tr(),
              HabitFrequency.daily,
              colorScheme,
            ),
            _buildToggleOption(
              "specific_days".tr(),
              HabitFrequency.specificDays,
              colorScheme,
            ),
            _buildToggleOption(
              "specific_dates".tr(),
              HabitFrequency.specificDates,
              colorScheme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleOption(
    String label,
    HabitFrequency val,
    ColorScheme colorScheme,
  ) {
    final isSelected = _frequency == val;
    return Expanded(
      child: GestureDetector(
          onTap: () {
          if (_frequency != val) {
            setState(() {
              _frequency = val;
              _selectedDays.clear(); 
            });
          }
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              // Selected: White | Unselected: Theme Text Color
              color: isSelected
                  ? Colors.white
                  : colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDaySelector(ColorScheme colorScheme) {
    final days = [
      "Mon".tr(),
      "Tue".tr(),
      "Wed".tr(),
      "Thu".tr(),
      "Fri".tr(),
      "Sat".tr(),
      "Sun".tr(),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(7, (index) {
        final dayIndex = index + 1;
        final isSelected = _selectedDays.contains(dayIndex);
        return ChoiceChip(
          label: Text(days[index]),
          selected: isSelected,
          showCheckmark: false,
          selectedColor: AppColors.secondary,
          backgroundColor: colorScheme.surface, // <--- Dynamic
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          // Removing default border if you want a cleaner look, or keeping it
          side: isSelected
              ? BorderSide.none
              : BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.1)),
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedDays.add(dayIndex);
              } else {
                _selectedDays.remove(dayIndex);
              }
            });
          },
        );
      }),
    );
  }

  Widget _buildDateSelector(ColorScheme colorScheme) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: List.generate(31, (index) {
        final date = index + 1;
        final isSelected = _selectedDays.contains(date);
        return ChoiceChip(
          label: Text(date.toString()),
          selected: isSelected,
          shape: CircleBorder(),
          showCheckmark: false,
          selectedColor: AppColors.secondary,
          backgroundColor: colorScheme.surface,
           
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          side: isSelected
              ? BorderSide.none
              : BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.1)),
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedDays.add(date);
              } else {
                _selectedDays.remove(date);
              }
            });
          },
        );
      }),
    );
  }
}
