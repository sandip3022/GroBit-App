import 'dart:developer' as console;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

       static const Map<String, String> _legacyTimezones = {
    'Asia/Calcutta': 'Asia/Kolkata',
    'Asia/Ulaanbaatar': 'Asia/Ulan_Bator',
    'Asia/Katmandu': 'Asia/Kathmandu',
    'America/Indiana/Indianapolis': 'America/Indianapolis',
    'America/Kentucky/Louisville': 'America/Louisville',
    'Pacific/Samoa': 'Pacific/Pago_Pago',
  };

   String _normalizeTimezone(String timezone) {
    return _legacyTimezones[timezone] ?? timezone;
  }

  Future<void> init() async {
    tz.initializeTimeZones();

    final String rawTimezone = await FlutterTimezone.getLocalTimezone();

     final String localTimeZone  = _normalizeTimezone(rawTimezone);
     tz.setLocalLocation(tz.getLocation(localTimeZone));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_notification');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestSoundPermission: false,
          requestBadgePermission: false,
          requestAlertPermission: false,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<bool> requestPermissions() async {
    final bool? androidGranted = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    final bool? iosGranted = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    return (androidGranted ?? false) || (iosGranted ?? false);
  }

  Future<void> scheduleDailyNotification({required TimeOfDay time}) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // ID
      "habitReminderTitle".tr(), 
      "habitReminderBody".tr(), 
      _nextInstanceOfTime(time),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel', // Channel ID
          'Daily Reminders', // Channel Name
          channelDescription: 'Reminds you to check your habits',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    console.log('Scheduled daily notification at ${time.toString()}');
  }

  Future<void> cancelNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  // Helper to calculate the next occurrence of the time
  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
