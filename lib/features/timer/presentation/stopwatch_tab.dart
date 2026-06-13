import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_colors.dart';

class StopwatchTab extends StatefulWidget {
  const StopwatchTab({super.key});

  @override
  State<StopwatchTab> createState() => _StopwatchTabState();
}

class _StopwatchTabState extends State<StopwatchTab> {
  late Stopwatch _stopwatch;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
  }

  // Updates the UI every 30 milliseconds to create a smooth millisecond counter
  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (Timer t) {
      if (mounted) setState(() {});
    });
    _stopwatch.start();
  }

  void _pauseTimer() {
    _timer?.cancel();
    _stopwatch.stop();
    setState(() {});
  }

  void _resetTimer() {
    _pauseTimer();
    _stopwatch.reset();
    setState(() {});
  }

  String _formatTime(int milliseconds) {
    int hundreds = (milliseconds / 10).truncate();
    int seconds = (hundreds / 100).truncate();
    int minutes = (seconds / 60).truncate();
    int hours = (minutes / 60).truncate();

    String hoursStr = (hours % 60).toString().padLeft(2, '0');
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    String hundredsStr = (hundreds % 100).toString().padLeft(2, '0');

    if (hours > 0) {
      return "$hoursStr:$minutesStr:$secondsStr.$hundredsStr";
    }
    return "$minutesStr:$secondsStr.$hundredsStr";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              "stopwatch".tr(),
              style: textTheme.displayMedium?.copyWith(fontSize: 24),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Text(
                _formatTime(_stopwatch.elapsedMilliseconds),
                style: textTheme.displayLarge?.copyWith(
                  fontSize: 56,
                  fontWeight: FontWeight.w300,
                  color: colorScheme.onSurface, // Adapts to theme
                  fontFeatures: const [
                    // Keeps numbers aligned perfectly so they don't jitter
                    FontFeature.tabularFigures(),
                    FontFeature.liningFigures(),
                  ],
                ),
                textAlign: TextAlign.left,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Reset Button
                IconButton(
                  onPressed: _stopwatch.elapsedMilliseconds > 0
                      ? _resetTimer
                      : null,
                  icon: const Icon(Icons.refresh),
                  iconSize: 32,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  tooltip: "reset".tr(),
                ),

                const SizedBox(width: 32),

                // Play / Pause Button
                GestureDetector(
                  onTap: _stopwatch.isRunning ? _pauseTimer : _startTimer,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: _stopwatch.isRunning
                          ? Colors.red.shade400
                          : AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:
                              (_stopwatch.isRunning
                                      ? Colors.red
                                      : AppColors.primary)
                                  .withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      _stopwatch.isRunning ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),

                const SizedBox(width: 32),

                // Invisible spacer to balance the row layout
                const SizedBox(width: 48),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
