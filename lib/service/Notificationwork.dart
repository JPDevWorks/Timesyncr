import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone_updated_gradle/flutter_native_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationServiceWork {
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

  Future<void> initializeTimeZone() async {
    tz.initializeTimeZones();
    String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
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
}
