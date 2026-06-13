import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker_app_2026/core/constants/app_constants.dart';

class ClockTab extends StatefulWidget {
  const ClockTab({super.key});

  @override
  State<ClockTab> createState() => _ClockTabState();
}

class _ClockTabState extends State<ClockTab> {
  DateTime _currentTime = DateTime.now();

  void _runClock() {
    Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void initState() {
    _runClock();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withAlpha(100),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat(AppConstants.day).format(_currentTime),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            Text(
                              DateFormat(
                                AppConstants.dateFormat,
                              ).format(_currentTime),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        Text(
                          AppConstants.timeZone,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              DateFormat(
                                AppConstants.timeFormat,
                              ).format(_currentTime),
                              style: TextStyle(
                                fontFamily: 'ShareTechMono',
                                fontSize: 48,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              AppConstants.am,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color:
                                    DateFormat(
                                          ' a',
                                        ).format(_currentTime).trim() ==
                                        AppConstants.am
                                    ? Theme.of(context).colorScheme.secondary
                                    : Theme.of(
                                        context,
                                      ).colorScheme.onPrimary.withAlpha(50),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              AppConstants.pm,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color:
                                    DateFormat(
                                          ' a',
                                        ).format(_currentTime).trim() ==
                                        AppConstants.pm
                                    ? Theme.of(context).colorScheme.secondary
                                    : Theme.of(
                                        context,
                                      ).colorScheme.onPrimary.withAlpha(50),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
