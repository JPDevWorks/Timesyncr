import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:flutter_native_timezone_updated_gradle/flutter_native_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timesyncr/models/NewEvent.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  static final DarwinInitializationSettings iosSettings =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestCriticalPermission: true,
    requestSoundPermission: true,
  );

  static final InitializationSettings initializationSettings =
      InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  static Future<void> initialize() async {
    await notificationsPlugin.initialize(initializationSettings);
    _requestPermissions();
  }

  static void _requestPermissions() {
    _requestIOSPermissions();
    _requestAndroidPermissions();
  }

  static void _requestIOSPermissions() {
    notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  static void _requestAndroidPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  void scheduleNotification(int id, DateTime dateTime, String eventName,
      String eventDescription) async {
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      "time-syncer",
      "timename",
      channelDescription: "timesyncr-description",
      autoCancel: false,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      priority: Priority.high,
      importance: Importance.max,
      audioAttributesUsage: AudioAttributesUsage.notificationRingtone,
      sound: RawResourceAndroidNotificationSound('alarm'.split('.').first),
      ongoing: true,
      playSound: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
    );

    DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await notificationsPlugin.zonedSchedule(
      id,
      eventName,
      eventDescription,
      tz.TZDateTime.from(dateTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
    );
  }

  // void scheduleNotificationUptoEnd(
  //   int id,
  //   DateTime dateTime,
  //   String eventName,
  //   String eventDescription,
  //   Event event,
  // ) async {
  //   AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
  //     "time-syncer",
  //     "timename",
  //     channelDescription: "timesyncr-description",
  //     autoCancel: false,
  //     enableVibration: true,
  //     vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
  //     priority: Priority.high,
  //     importance: Importance.max,
  //     sound: RawResourceAndroidNotificationSound('alarm'.split('.').first),
  //     ongoing: true,
  //     playSound: true,
  //     fullScreenIntent: true,
  //     category: AndroidNotificationCategory.alarm,
  //   );

  //   DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
  //     presentAlert: true,
  //     presentBadge: true,
  //     presentSound: true,
  //   );

  //   NotificationDetails notificationDetails = NotificationDetails(
  //     android: androidDetails,
  //     iOS: iosDetails,
  //   );

  //   DateTime enddate = DateFormat('dd-MM-yyyy').parse(event.endDate!);
  //   DateTime startdate = DateFormat('dd-MM-yyyy').parse(event.startDate);

  //   while (startdate.isBefore(enddate) || startdate.isAtSameMomentAs(enddate)) {
  //     print('Reminder: $dateTime');
  //     print('StartDate: $startdate');
  //     print('EndDate: ${event.endDate}');
  //     tz.TZDateTime scheduledTime = await _nextInstanceOfTime(dateTime);
  //     await notificationsPlugin.zonedSchedule(
  //       id,
  //       event.title,
  //       event.notes,
  //       scheduledTime,
  //       notificationDetails,
  //       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  //       uiLocalNotificationDateInterpretation:
  //           UILocalNotificationDateInterpretation.absoluteTime,
  //       matchDateTimeComponents: DateTimeComponents.time,
  //     );
  //     id++;
  //     startdate = startdate.add(Duration(days: 1));
  //     dateTime = dateTime.add(Duration(days: 1));
  //   }
  // }

  Future<void> initializeTimeZone() async {
    tz.initializeTimeZones();
    String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  Future<tz.TZDateTime> _nextInstanceOfTime(DateTime dateTime) async {
    String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    final tz.TZDateTime now = tz.TZDateTime.now(tz.getLocation(timeZoneName));

    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.getLocation(timeZoneName),
      now.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    print('Scheduled date: $scheduledDate');
    print('Current time (now): $now');
    return scheduledDate;
  }

  void scheduleDailyNotification(int id, DateTime dateTime, String eventName,
      String eventDescription) async {
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      "time-syncer-daily",
      "timename-daily",
      channelDescription: "timesyncr-daily-description",
      autoCancel: false,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      priority: Priority.max,
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound('alarm'.split('.').first),
      ongoing: true,
      playSound: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
    );

    DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails, iOS: iosDetails);
    tz.TZDateTime scheduledTime = await _nextInstanceOfTime(dateTime);
    await notificationsPlugin.zonedSchedule(
      id,
      eventName,
      eventDescription,
      scheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  void scheduleWeeklyNotification(int id, DateTime dateTime, String eventName,
      String eventDescription) async {
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      "time-syncer-weekly",
      "timename-weekly",
      channelDescription: "timesyncr-weekly-description",
      autoCancel: false,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      priority: Priority.max,
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound('alarm'.split('.').first),
      ongoing: true,
      playSound: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
    );

    DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    tz.TZDateTime scheduledTime = _nextInstanceOfWeek(dateTime);
    await notificationsPlugin.zonedSchedule(
      id,
      eventName,
      eventDescription,
      scheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  void scheduleMonthlyNotification(int id, DateTime dateTime, String eventName,
      String eventDescription) async {
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      "time-syncer-monthly",
      "timename-monthly",
      channelDescription: "timesyncr-monthly-description",
      autoCancel: false,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      priority: Priority.high,
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('alarm'.split('.').first),
      ongoing: true,
      playSound: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
    );

    DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    tz.TZDateTime scheduledTime = _nextInstanceOfMonth(dateTime);
    await notificationsPlugin.zonedSchedule(
      id,
      eventName,
      eventDescription,
      scheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
    );
  }

  tz.TZDateTime _nextInstanceOfWeek(DateTime dateTime) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      dateTime.hour,
      dateTime.minute,
    );

    while (scheduledDate.weekday != dateTime.weekday) {
      scheduledDate = scheduledDate.add(Duration(days: 1));
    }

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    return scheduledDate;
  }

  tz.TZDateTime _nextInstanceOfMonth(DateTime dateTime) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month + 1,
        dateTime.day,
        dateTime.hour,
        dateTime.minute,
      );
    }

    return scheduledDate;
  }

  void periodic(int id, DateTime dateTime, String eventName,
      String eventDescription) async {
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      "time-syncer",
      "timename",
      channelDescription: "timesyncr-description",
      autoCancel: false,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      priority: Priority.high,
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('alarm'.split('.').first),
      ongoing: true,
      playSound: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
    );

    DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await notificationsPlugin.periodicallyShow(
      id++,
      eventName,
      eventDescription,
      RepeatInterval.hourly,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

   static Future<List<Map<String, String>>> getPendingNotificationDetails() async {
    List<PendingNotificationRequest> pendingNotifications = await notificationsPlugin.pendingNotificationRequests();
    print('Total pending notifications: ${pendingNotifications.length}');

    List<Map<String, String>> notificationDetails = [];
    for (var notification in pendingNotifications) {
      print('Notification ID: ${notification.id}');
      print('Title: ${notification.title}');
      print('Body: ${notification.body}');
      print('Payload: ${notification.payload}');
      print('---');

      notificationDetails.add({
        'id': notification.id.toString(),
        'title': notification.title ?? '',
        'body': notification.body ?? '',
      });
    }
    return notificationDetails;
  }
}
