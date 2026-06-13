import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker_app_2026/features/onboarding/presentation/state_management/user_provider.dart';
import '../../../../core/theme/app_colors.dart'; 

class HomeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String userAvatarUrl; 
  final VoidCallback onTimerTap; 

  const HomeAppBar({
    super.key,
    this.userAvatarUrl = "", 
    required this.onTimerTap,
  });

  @override
  Widget build(BuildContext context,ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(userProvider);

    final String dateText = DateFormat('EEEE, MMM d').format(DateTime.now()).toUpperCase();

    return AppBar(
      elevation: 0,
      toolbarHeight: 80,
      automaticallyImplyLeading: false, 
      
      title: Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. DATE (Subtitle)
            Text(
              dateText, 
              style: textTheme.labelSmall?.copyWith(
                // Adaptive Grey: Lighter in dark mode for readability
                color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
            
            const SizedBox(height: 4),
            
            // 2. MAIN HEADING
            Text(
              "${getSalutation()}, ${user.name}",
              style: textTheme.displayMedium?.copyWith(
                fontSize: 28, 
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
      
      actions: [
        // 3. TIMER BUTTON
        Padding(
          padding: const EdgeInsets.only(right: 20.0, top: 10.0),
          child: GestureDetector(
            onTap: onTimerTap,
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: colorScheme.surface, 
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? Colors.transparent : AppColors.textSecondary.withValues(alpha: 0.1),
                ),
                boxShadow: [
                  // Shadow only for Light Mode
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                ],
              ),
              child: Icon(
                Icons.timer_outlined,
                color: isDark ? AppColors.surface : AppColors.primary, // Brand color always stays consistent
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);

    String getSalutation() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "good_morning".tr();
    } else if (hour < 17) {
      return "good_afternoon".tr();
    } else {
      return "good_evening".tr();
    }
  }
}