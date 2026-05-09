import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/pages/pin_screen.dart';
import '../../../../core/theme/app_colors.dart';
import '../state_management/privacy_provider.dart';

class PrivacyLockPage extends ConsumerWidget {
  const PrivacyLockPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final privacyState = ref.watch(privacyProvider);
    final notifier = ref.read(privacyProvider.notifier);

    // 1. Access Theme Data
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Helper text color (Grey in Light, Lighter Grey in Dark)
    final labelColor = isDark ? Colors.grey[400] : AppColors.textSecondary;

    return Scaffold(
      // No fixed background color (Scaffold uses Theme default)
      appBar: AppBar(
        title: Text(
          "privacy_lock".tr(),
          style: textTheme.displayMedium?.copyWith(fontSize: 22),
        ),
        elevation: 0,
        leading: IconButton(
          // Dynamic Icon Color
          icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "secure_your_habits".tr(),
              style: textTheme.labelSmall?.copyWith(
                color: labelColor,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),

            // --- OPTION 1: BIOMETRIC ---
            _buildToggleCard(
              context,
              title: "biometric_unlock".tr(),
              subtitle: "fingerprint".tr(),
              icon: Icons.fingerprint,
              value: privacyState.isBiometricEnabled,
              onChanged: (val) {
                notifier.toggleBiometric(val);
              },
            ),

            const SizedBox(height: 16),

            // --- OPTION 2: PIN CODE ---
            _buildToggleCard(
              context,
              title: "pin_code_subtitle".tr(),
              subtitle: "",
              icon: Icons.dialpad,
              value: privacyState.isPinEnabled,
              onChanged: (val) {
                if (val) {
                  // ENABLE: Go to Set PIN Screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PinScreen(
                        mode: PinMode.create,
                        onSuccess: (pin) {
                          notifier.setPin(pin);
                          Navigator.pop(context); // Close Pin Screen
                        },
                      ),
                    ),
                  );
                } else {
                  // DISABLE: Confirm current PIN first
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PinScreen(
                        mode: PinMode.verify,
                        onSuccess: (_) {
                          notifier.removePin();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  );
                }
              },
            ),

            // --- RESET OPTION (Only visible if PIN is on) ---
            if (privacyState.isPinEnabled) ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  // Change PIN Logic: Verify Old -> Set New
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PinScreen(
                        mode: PinMode.verify,
                        title: "enter_old_pin".tr(),
                        onSuccess: (_) {
                          // Old PIN correct, navigate to Set New
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PinScreen(
                                mode: PinMode.create,
                                onSuccess: (newPin) {
                                  notifier.setPin(newPin);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("PIN Updated"),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface, // <--- Dynamic Surface
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lock_reset, color: colorScheme.onPrimary),
                      const SizedBox(width: 16),
                      // Dynamic Text Color
                      Text(
                        "change_pin".tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: colorScheme.onPrimary.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildToggleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    // Access Theme Colors
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface, 
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          // Shadow mostly for light mode
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: colorScheme.onSurface), // Dynamic Icon Color
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dynamic Text Color
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                // Dynamic Subtitle Color
                Text(
                  subtitle,
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: colorScheme.secondary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
