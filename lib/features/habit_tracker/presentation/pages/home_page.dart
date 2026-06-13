import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/pages/journal_page.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/pages/account_page.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/pages/progress_page.dart';
import 'package:habit_tracker_app_2026/main.dart';
import '../state_management/habit_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

final pagelist = [JournalPage(), const ProgressPage(), const AccountPage()];

class _HomePageState extends ConsumerState<HomePage> {
  var _selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final date = ref.read(selectedDateProvider);
      ref.read(habitNotifierProvider.notifier).loadHabits(date);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: pagelist[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: _selectedIndex == 0
                ? Icon(Icons.book)
                : Icon(Icons.book_outlined),
            label: 'journal'.tr(),
          ),
          BottomNavigationBarItem(
            icon: _selectedIndex == 1
                ? Icon(Icons.bar_chart)
                : Icon(Icons.bar_chart_outlined),
            label: 'progress'.tr(),
          ),
          BottomNavigationBarItem(
            icon: _selectedIndex == 2
                ? Icon(Icons.account_circle)
                : Icon(Icons.account_circle_outlined),
            label: 'account'.tr(),
          ),
        ],
      ),
    );
  }
}
