import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class WorkoutNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // 1. تهيئة خدمة الإشعارات والمناطق الزمنية
  static Future<void> initNotification() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  // 2. جدولة الإشعارات كل 4 ساعات (10:00, 14:00, 18:00, 22:00)
  static Future<void> scheduleWorkoutReminder() async {
    await _notificationsPlugin.cancelAll();

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'zabet_workout_channel',
      'Workout Reminders',
      channelDescription: 'Reminders for heavy workout sessions',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    // مواعيد الإشعارات (10 صباحاً - 2 ظهراً - 6 مساءً - 10 مساءً)
    final List<int> reminderHours = [10, 14, 18, 22];

    for (int i = 0; i < reminderHours.length; i++) {
      await _notificationsPlugin.zonedSchedule(
        i,
        'workout_notif_title'.tr(),
        'workout_notif_body'.tr(),
        _nextInstanceOfHour(reminderHours[i]),
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // تكرار يومي في نفس المواعيد
      );
    }
  }

  static tz.TZDateTime _nextInstanceOfHour(int hour) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
    tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}