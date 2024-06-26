import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:timesyncr/controller/task_controller.dart';
import 'package:timesyncr/models/Event.dart';
import 'package:timesyncr/service/Notificationwork.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    await GetStorage.init();

    NotificationServiceWork notificationService = NotificationServiceWork();
    await notificationService.initializeTimeZone();

    final TaskController taskController = Get.put(TaskController());
    await taskController.fetchEvents();

    List<Event> events = taskController.events.toList();

    DateTime now = DateTime.now();

    for (Event event in events) {
      print('Event: $event');
      if (event.repeat == 'Daily' ||
          (event.repeat == 'Weekly' && now.weekday == DateFormat('EEEE').parse(event.startDate).weekday) ||
          (event.repeat == 'Monthly' && now.day == DateFormat('dd-MM-yyyy').parse(event.startDate).day) ||
          (event.repeat == 'from_date_to_date' && now.isAfter(DateFormat('dd-MM-yyyy').parse(event.startDate)) &&
          now.isBefore(DateFormat('dd-MM-yyyy').parse(event.endDate.toString())))) {
        List<String> timeParts = event.startTime.split(':');
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);
        DateTime notificationDateTime =
        DateTime(now.year, now.month, now.day, hour, minute);
        notificationService.scheduleNotification(
          event.id!,
          notificationDateTime,
          event.eventName!,
          event.eventDescription!,
        );
      }
    }

    return Future.value(true);
  });
}
