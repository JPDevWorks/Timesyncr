import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'dart:math'; // Import for generating random numbers
import 'package:timesyncr/controller/newtask_controller.dart';
import 'package:timesyncr/models/NewEvent.dart';
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

    final NewTaskController taskController = Get.put(NewTaskController());

    DateTime selectedDate = DateTime.now();
    await taskController.fetchdateEvents(selectedDate);

    List<Event> events = taskController.dateevents.toList();
    Random random = Random();

    for (Event event in events) {
      print('Event: $event');
      DateTime eventDateTime = DateFormat('dd-MM-yyyy hh:mm a')
          .parse('${event.startDate} ${event.startTime}');
      if (eventDateTime.isAfter(DateTime.now())) {
        int randomId = random.nextInt(1000000000); // Generate a random ID
        notificationService.scheduleNotification(
          randomId,
          eventDateTime,
          event.title,
          event.notes,
        );
      }
    }

    return Future.value(true);
  });
}
