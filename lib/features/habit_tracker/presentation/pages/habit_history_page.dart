import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker_app_2026/core/constants/app_icons.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../domain/entities/habit_entity.dart';

class HabitHistoryPage extends StatefulWidget {
  final HabitEntity habit;

  const HabitHistoryPage({super.key, required this.habit});

  @override
  State<HabitHistoryPage> createState() => _HabitHistoryPageState();
}

class _HabitHistoryPageState extends State<HabitHistoryPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    // PERFORMANCE UPGRADE: Convert list of DateTimes to a Set of YYYY-MM-DD strings for O(1) lookup
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(widget.habit.colorValue);

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface, // Clean white look for calendar
      appBar: AppBar(
        title: Text(
          "habit_details".tr(),
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHabitInfo(),
            _buildDivider(),
            _buildCalendar(primaryColor, colorScheme),
            _buildDivider(),
            _buildSummary(primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(Color color, ColorScheme colorScheme) {
    return TableCalendar(
      firstDay: DateTime.utc(2026, 1, 2),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(color: colorScheme.onSurface, fontSize: 18),
        leftChevronIcon: Icon(Icons.chevron_left, color: colorScheme.onSurface),
        rightChevronIcon: Icon(
          Icons.chevron_right,
          color: colorScheme.onSurface,
        ),
      ),

      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: colorScheme.onSurface),
        weekendStyle: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),

      // LOGIC: Show colored circles on days where habit matches history
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) => _buildDayCell(day, color),
        todayBuilder: (context, day, focusedDay) =>
            _buildDayCell(day, color, isToday: true),
        selectedBuilder: (context, day, focusedDay) =>
            _buildDayCell(day, color), // Handle selection same as default
      ),
    );
  }

  Container? _buildDayCell(DateTime day, Color color, {bool isToday = false}) {
    // Check if day exists in Entity's completedDates
    // IMPORTANT: Compare Y/M/D only
    final isCompleted = widget.habit.completedDates.any(
      (d) => d.year == day.year && d.month == day.month && d.day == day.day,
    );

    if (isCompleted) {
      return Container(
        margin: const EdgeInsets.all(6.0),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Center(
          child: Text(
            '${day.day}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    if (isToday) {
      return Container(
        margin: const EdgeInsets.all(6.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Center(
          child: Text(
            '${day.day}',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return null; // Default styling
  }

  Widget _buildSummary(Color color) {
    final total = widget.habit.completedDates.length;
    final streak = widget.habit.currentStreak;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24,
      vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
           _statCard("streak".tr(), "$streak", color),
          _statCard("total".tr(), "$total", color),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 18, color: Colors.grey)),
      ],
    );
  }

  Widget _buildHabitInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Color(widget.habit.colorValue).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              AppIcons.getIcon(widget.habit.iconCode),
              color: Color(widget.habit.colorValue),
              size: 26,
            ),
          ),

          const SizedBox(width: 32),

          Text(
            widget.habit.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
     // Push content to edges
        ],
      ),
    );
  }


  Widget _buildDivider() {
    return Container(
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
