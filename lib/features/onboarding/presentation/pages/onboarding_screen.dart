import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker_app_2026/core/constants/app_icons.dart';
import 'package:habit_tracker_app_2026/core/services/import_service.dart';
import 'package:habit_tracker_app_2026/core/theme/theme_provider.dart';
import 'package:habit_tracker_app_2026/core/utils/validators.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/domain/entities/habit_entity.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/pages/home_page.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/pages/privacy_lock_page.dart';
import 'package:habit_tracker_app_2026/main.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/theme/app_colors.dart';
import '../state_management/user_provider.dart';
import 'package:uuid/uuid.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  String newName = "Guest";
  bool isImporting = false;

  int _currentPage = 0;
  final Set<String> _selectedHabits = {};

  // Pre-defined habits for Step 2
  final List<Map<String, dynamic>> _starterHabits = [
    {'title': "exercise".tr(), 'icon': 57997, 'color': 0xFF0984E3}, // Blue
    {'title': "read_books".tr(), 'icon': 58333, 'color': 0xFF6C5CE7}, // Purple
    {
      'title': "healthy_eating".tr(),
      'icon': 58674,
      'color': 0xFFFF6B6B,
    }, // Coral
    {'title': "meditation".tr(), 'icon': 58735, 'color': 0xFF00B894}, // Teal
    {'title': "journaling".tr(), 'icon': 57535, 'color': 0xFFE17055}, // Orange
    {
      'title': "Early_sleep".tr(),
      'icon': 57559,
      'color': 0xFF0984E3,
    }, // Midnight
  ];

  void _nextPage() {
    if (ref.read(userProvider).isOnboardingCompleted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finishOnboarding() async {
    for (var habitData in _starterHabits) {
      if (_selectedHabits.contains(habitData['title'])) {
        final habit = HabitEntity(
          id: const Uuid().v4(),
          title: habitData['title'],
          iconCode: habitData['icon'],
          colorValue: habitData['color'],
          completedDates: [],
          frequency: HabitFrequency.daily,
          targetDays: [],
          createdAt: DateTime.now(),
        );
        ref
            .read(habitNotifierProvider.notifier)
            .addHabit(habit, DateTime.now());
      }
    }

    await ref.read(userProvider.notifier).setName(_nameController.text.trim());
    await ref.read(userProvider.notifier).completeOnboarding();

    // 3. Go Home
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Semantics(
                label: "onboarding_progress".tr(
                  args: [(_currentPage + 1).toString(), "4"],
                ),
                value: "${((_currentPage + 1) / 4 * 100).toInt()}%",
                child: LinearProgressIndicator(
                  value: (_currentPage + 1) / 4,
                  backgroundColor: Colors.grey[200],
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                children: [
                  _buildWelcomeStep(),
                  _buildNameStep(),
                  _buildHabitStep(),
                  _buildSecurityStep(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- STEP 1: NAME ---
  Widget _buildNameStep() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "let_get_started".tr(),
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "what_should_we_call_you".tr(),
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _nameController,
            inputFormatters: [...Validators.nameInputFormatters],
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: "your_name".tr(),
              hintStyle: TextStyle(color: Colors.grey[300]),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            onChanged: (val) => setState(() {}), // Rebuild to enable button
          ),
          const Spacer(),

          isImporting
              ? Center(
                  child: Lottie.asset(
                    isDark
                        ? 'assets/animations/file_loading_lottie_dark.json'
                        : 'assets/animations/file_loading_lottie.json',
                    height: 300,
                    width: 300,
                  ),
                )
              :
                // Spacing
                AbsorbPointer(
                  absorbing: ref
                      .watch(userProvider)
                      .isBackRestored, // Disable if backup is restored
                  child: TextButton(
                    child: Text(
                      "already_have_backup".tr(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () async {
                      setState(() {
                        isImporting = true;
                      });
                      try {
                        final importedHabits =
                            await ImportService.importHabitsFromCSV();

                        if (!context.mounted) return;

                        if (importedHabits == null) {
                          return; // User canceled the picker
                        }

                        if (importedHabits.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("invalid_backup_file".tr()),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("restoring_your_habits".tr()),
                            backgroundColor: AppColors.primary,
                          ),
                        );

                        await ref
                            .read(habitNotifierProvider.notifier)
                            .importHabits(importedHabits);

                        if (!context.mounted) return;

                        await ref
                            .read(userProvider.notifier)
                            .setisBackRestored(true);
                        final enteredName = _nameController.text.trim();
                        if (enteredName.isNotEmpty) {
                          await ref
                              .read(userProvider.notifier)
                              .setName(enteredName);
                          await ref
                              .read(userProvider.notifier)
                              .completeOnboarding();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "welcome_back_restored_habits".tr(
                                  args: [importedHabits.length.toString()],
                                ),
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "error_restoring_backup".tr(
                                  args: [e.toString()],
                                ),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } finally {
                        setState(() {
                          isImporting = false;
                        });
                      }
                    },
                  ),
                ),

          Visibility(
            visible: ref.watch(userProvider).isBackRestored,
            child: Column(
              children: [
                SizedBox(height: 16),

                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: colorScheme.onSurface,
                      width: 1.5,
                    ),
                  ),
                  child: Semantics(
                    button: true,
                    label: "backup_file_imported".tr(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.done_sharp,
                          size: 16,
                          color: colorScheme.onPrimary,
                        ),
                        const SizedBox(width: 20),
                        Text(
                          "backup_file_imported".tr(),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontSize: 16,
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                if (_nameController.text.isNotEmpty && !isImporting) {
                  newName = _nameController.text.trim();
                  await ref.read(userProvider.notifier).setName(newName);

                  if (ref.read(userProvider).isBackRestored) {
                    await ref.read(userProvider.notifier).completeOnboarding();
                  }
                  _nextPage();
                } else {
                  null;
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    (_nameController.text.isNotEmpty && !isImporting)
                    ? AppColors.primary
                    : colorScheme.primary.withValues(alpha: 0.6),
              ),
              child: Text(
                (ref.watch(userProvider).isBackRestored)
                    ? "go_to_home_page".tr()
                    : "next_step".tr(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- STEP 2: HABITS ---
  Widget _buildHabitStep() {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "kickstart_your_journey".tr(),
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "pick_some_habits".tr(),
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 8),
          Text(
            "you_can_edit_later".tr(),
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
          const SizedBox(height: 32),

          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.3,
              ),
              itemCount: _starterHabits.length,
              itemBuilder: (context, index) {
                final habit = _starterHabits[index];
                final isSelected = _selectedHabits.contains(habit['title']);
                return Semantics(
                  button: true,
                  selected: isSelected,
                  label: habit['title'],
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedHabits.remove(habit['title']);
                        } else {
                          _selectedHabits.add(habit['title']);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : Colors.grey[200]!,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: ExcludeSemantics(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              AppIcons.getIcon(habit['icon']),
                              color: Color(habit['color']),
                              size: 26,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              habit['title'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? colorScheme.onPrimaryContainer
                                    : colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Row(
            children: [
              TextButton(
                onPressed: _nextPage,
                child: Text(
                  "skip".tr(),
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _nextPage,
                child: Text("next_step".tr()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- STEP 3: SECURITY ---
  Widget _buildSecurityStep() {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline_rounded, size: 80, color: AppColors.primary),
          const SizedBox(height: 24),
          Text(
            "protect_your_privacy".tr(),
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            "secure_your_journal".tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 48),

          // Setup Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Push Privacy Page, then finish on return
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrivacyLockPage()),
                ).then((_) => _finishOnboarding());
              },
              child: const Text("set_up_security").tr(),
            ),
          ),
          const SizedBox(height: 16),

          // Skip Button
          TextButton(
            onPressed: _finishOnboarding,
            child: Text(
              "skip_security".tr(),
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- STEP 1: WELCOME & PREFERENCES ---
  Widget _buildWelcomeStep() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "welcome_to_growbit".tr(), // Add this to JSON!
            style: textTheme.displayMedium,
          ),
          const SizedBox(height: 8),
          Text(
            "personalize_experience".tr(), // Add this to JSON!
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 48),

          // --- LANGUAGE SELECTOR ---
          Text(
            "choose_language".tr(), // Add this to JSON!
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Locale>(
                isExpanded: true,
                value: context.locale,
                dropdownColor: colorScheme.surface,
                icon: const Icon(Icons.language, color: Colors.grey),
                items: const [
                  DropdownMenuItem(value: Locale('en'), child: Text("English")),
                  DropdownMenuItem(value: Locale('mr'), child: Text("मराठी")),
                  DropdownMenuItem(value: Locale('hi'), child: Text("हिंदी")),
                ],
                onChanged: (Locale? newLocale) {
                  if (newLocale != null) {
                    context.setLocale(
                      newLocale,
                    ); // Instantly translates the page!
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 32),

          // --- THEME SELECTOR ---
          Text(
            "choose_theme".tr(), // Add this to JSON!
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildThemeCard(
                  title: "light".tr(),
                  icon: Icons.wb_sunny_outlined,
                  isSelected: !isDark,
                  onTap: () =>
                      ref.read(themeProvider.notifier).toggleTheme(false),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildThemeCard(
                  title: "dark".tr(),
                  icon: Icons.nightlight_round,
                  isSelected: isDark,
                  onTap: () =>
                      ref.read(themeProvider.notifier).toggleTheme(true),
                ),
              ),
            ],
          ),

          const Spacer(),

          // --- NEXT BUTTON ---
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextPage,
              child: Text("next_step".tr()),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget for the Theme Cards
  Widget _buildThemeCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.primary : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primary : colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
