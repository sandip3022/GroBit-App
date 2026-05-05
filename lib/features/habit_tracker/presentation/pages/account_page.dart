import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker_app_2026/core/services/export_service.dart';
import 'package:habit_tracker_app_2026/core/services/import_service.dart';
import 'package:habit_tracker_app_2026/core/services/notification_service.dart';
import 'package:habit_tracker_app_2026/core/services/user_provider.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/pages/privacy_lock_page.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/state_management/notification_provider.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/state_management/privacy_provider.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/widgets/settings_widget.dart';
import 'package:habit_tracker_app_2026/features/onboarding/presentation/pages/login_screen.dart';
import 'package:habit_tracker_app_2026/main.dart';
import 'package:hive/hive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key});

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  bool _isNotificationOn = false;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  void _loadNotificationSettings() {
    final box = Hive.box('settings');

    setState(() {
      _isNotificationOn = box.get('isNotificationOn', defaultValue: false);

      String? savedTime = box.get('notificationTime');

      if (savedTime != null && savedTime.contains(':')) {
        final parts = savedTime.split(':');
        _notificationTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      } else {
        // Fallback to default 9:00 AM if nothing is saved
        _notificationTime = const TimeOfDay(hour: 9, minute: 0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. WATCH THE THEME PROVIDER
    final currentTheme = ref.watch(themeProvider);
    final notifState = ref.watch(notificationProvider);
    final isDarkMode = currentTheme == ThemeMode.dark;
    final String _userName = ref.watch(userProvider);

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "account".tr(),
          style: textTheme.displayMedium?.copyWith(fontSize: 24),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildProfileSection(textTheme, colorScheme, _userName),

            const SizedBox(height: 40),
            BuildSettingsCard(
              title: "daily_reminder".tr(),
              icon: Icons.notifications_outlined,
              trailing: ExcludeSemantics(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (notifState.isNotificationOn)
                      Text(
                        _notificationTime.format(context),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    Switch(
                      value: notifState.isNotificationOn,
                      activeThumbColor: AppColors.secondary,
                      onChanged: (val) => _toggleNotifications(val),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            BuildSettingsCard(
              title: "dark_mode".tr(),
              icon: Icons.dark_mode_outlined,
              trailing: ExcludeSemantics(
                child: Switch(
                  value: isDarkMode,
                  activeThumbColor: AppColors.secondary,
                  onChanged: (val) {
                    ref.read(themeProvider.notifier).toggleTheme(val);
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            BuildSettingsCard(
              title: "language".tr(),
              icon: Icons.language_outlined,
              trailing: ExcludeSemantics(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Locale>(
                    value: context.locale,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    dropdownColor: colorScheme.surface,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                    onChanged: (Locale? newLocale) {
                      if (newLocale != null) {
                        // This instantly changes the app language and saves the preference!
                        context.setLocale(newLocale);
                      }
                    },
                    items: const [
                      DropdownMenuItem(
                        value: Locale('en'),
                        child: Text("English"),
                      ),
                      DropdownMenuItem(
                        value: Locale('mr'),
                        child: Text("मराठी"),
                      ),
                      DropdownMenuItem(
                        value: Locale('hi'),
                        child: Text("हिंदी"),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            BuildSettingsCard(
              title: "privacy_lock".tr(),
              icon: Icons.lock_outline,
              trailing: ExcludeSemantics(
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrivacyLockPage()),
                );
              },
            ),
            const SizedBox(height: 16),
            BuildSettingsCard(
              title: "export_to_csv".tr(),
              icon: Icons.download_outlined,
              trailing: ExcludeSemantics(
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ),
              onTap: () async {
                final currentHabits = ref.read(habitNotifierProvider).habits;

                if (currentHabits.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("No habits to export yet!")),
                  );
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Preparing your file...")),
                );

                try {
                  bool success = await ExportService.exportHabitsToCSV(
                    currentHabits,
                  );

                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Export saved successfully!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Oops, export failed. Please try again."),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 16),
            BuildSettingsCard(
              title: "restore_from_backup".tr(),
              icon: Icons.upload_file_outlined,
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
              onTap: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("select_backup_file".tr())),
                );

                try {
                  final importedHabits =
                      await ImportService.importHabitsFromCSV();

                  if (!context.mounted) return;

                  if (importedHabits == null) {
                    return;
                  }

                  if (importedHabits.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "invalid_backup_file".tr(),
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  await ref
                      .read(habitNotifierProvider.notifier)
                      .importHabits(importedHabits);

                  // 3. Success Feedback
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "successfully_restored_habits".tr(
                          args: [importedHabits.length.toString()],
                        ),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 16),
            BuildSettingsCard(
              title: "log_out".tr(),
              icon: Icons.logout_outlined,
              trailing: ExcludeSemantics(
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ),
              onTap: () {
                final privacyState = ref.read(privacyProvider);

                if (privacyState.isPinEnabled ||
                    privacyState.isBiometricEnabled) {
                  ref.read(privacyProvider.notifier).lockApp();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("please_setup_security_first".tr()),
                      backgroundColor: colorScheme.errorContainer,
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 40),

            Text(
              "data_management".tr(),
              style: textTheme.labelSmall?.copyWith(
                color: isDarkMode
                    ? Colors.grey
                    : AppColors.textSecondary, // Dynamic Color
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),

            BuildDestructiveCard(
              title: "reset_progress".tr(),
              subtitle: "keep_habits_but_clear_history".tr(),
              buttonLabel: "resetCap".tr(),
              onTap: () => _showConfirmationSheet(
                context: context,
                title: "reset_all_progress".tr(),
                message: "reset_all_progress_message".tr(),
                confirmLabel: "reset".tr(),
                onConfirm: () {
                  ref.read(habitNotifierProvider.notifier).resetAllProgress();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("progress_reset_successfully".tr())),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            BuildDestructiveCard(
              title: "delete_everything".tr(),
              subtitle: "delete_everything_message".tr(),
              buttonLabel: "delete".tr(),
              isCritical: true,
              onTap: () => _showConfirmationSheet(
                context: context,
                title: "delete_everything_question".tr(),
                message: "this_action_cannot_be_undone".tr(),
                confirmLabel: "delete_all".tr(),
                isCritical: true,
                onConfirm: () {
                  ref.read(habitNotifierProvider.notifier).deleteAllData();
                  Navigator.pop(context); // Go back to Home
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "All data deleted".tr(),
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UPDATED WIDGETS ---

  Widget _buildProfileSection(
    TextTheme textTheme,
    ColorScheme colorScheme,
    String _userName,
  ) {
    return Semantics(
      label: "user_profile".tr(
        args: [_userName],
      ), // Add to JSON: "User Profile: {}"
      excludeSemantics: true,
      child: Column(
        children: [
          // 1. Circle Avatar with Initials
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              _getInitials(_userName),
              style: textTheme.displayMedium?.copyWith(
                color: AppColors.secondary,
                fontSize: 32,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _userName,
            // Use 'onSurface' so it is Black in Light Mode, White in Dark Mode
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return "";
    List<String> nameParts = name.trim().split(" ");
    if (nameParts.length > 1) {
      return "${nameParts[0][0]}${nameParts[1][0]}".toUpperCase();
    } else {
      // Just First letter
      return nameParts[0][0].toUpperCase();
    }
  }

  void _showConfirmationSheet({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmLabel,
    required VoidCallback onConfirm,
    bool isCritical = false,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            ExcludeSemantics(
              child: Icon(
                Icons.warning_amber_rounded,
                size: 48,
                color: isCritical ? Colors.red : Colors.orange,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onConfirm,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isCritical
                          ? Colors.red
                          : AppColors.primary,
                    ),
                    child: Text(
                      confirmLabel,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleNotifications(bool value) async {
    // 1. Get the notifier from Riverpod
    final notifier = ref.read(notificationProvider.notifier);

    if (value) {
      final bool granted = await NotificationService().requestPermissions();
      if (!granted) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Permission denied")));
        return;
      }

      if (!mounted) return;
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: ref.read(notificationProvider).selectedTime,
        builder: (context, child) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Theme(
            data: isDark
                ? ThemeData.dark()
                : ThemeData.light().copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppColors.primary,
                    ),
                  ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        await notifier.updateTime(picked);
        await notifier.toggleNotification(true);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "reminder_set".tr(args: [picked.format(context)]),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          ),
        );
      }
    } else {
      await notifier.toggleNotification(false);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "reminders_turned_off".tr(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ),
      );
    }
  }
}
