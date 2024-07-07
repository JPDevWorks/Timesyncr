import 'dart:typed_data';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:timesyncr/models/Event.dart';
import 'package:timesyncr/models/user.dart';
import 'package:timesyncr/service/Notification.dart'; 

class DatabaseService {
  static const int _version = 1;
  static const String _dbname = "timesyncrdb";

  static Future<Database> getdb() async {
    return openDatabase(
      join(await getDatabasesPath(), _dbname),
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE events (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          eventName TEXT NOT NULL,
          eventDescription TEXT,
          startDate TEXT NOT NULL,
          endDate TEXT,
          startTime TEXT NOT NULL,
          endTime TEXT NOT NULL,
          category TEXT,
          repeat TEXT,
          planevent TEXT,
          inviteGmails TEXT,
          reminderBefore INTEGER,
          isCompleted INTEGER,
          color INTEGER
        )
      ''');

        await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          email TEXT,
          profileImage TEXT,
          phonenumber TEXT,
          password TEXT,
          status TEXT
        )
      ''');
      },
      version: _version,
    );
  }

  static Future<bool> userAdd(Userdetials user) async {
    final Database db = await getdb();
    await db.insert(
      'users',
      user.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return true;
  }

  static Future<void> deleteAllUsers() async {
    final Database db = await getdb();
    await db.delete('users');
  }

  static Future<Userdetials?> getUserDetailsByEmail(String email) async {
    try {
      DatabaseReference usersRef =
          FirebaseDatabase.instance.ref().child('Users');
      DatabaseEvent databaseEvent = await usersRef.once();
      DataSnapshot dataSnapshot = databaseEvent.snapshot;

      print(
          'DataSnapshot value: ${dataSnapshot.value}'); // Print dataSnapshot.value

      // Check if dataSnapshot.value is not null
      if (dataSnapshot.value != null) {
        // Explicitly cast dataSnapshot.value to Map<dynamic, dynamic>
        Map<dynamic, dynamic> usersData =
            dataSnapshot.value as Map<dynamic, dynamic>;

        print('Users data: $usersData'); // Print usersData

        for (var userId in usersData.keys) {
          var userData = usersData[userId];
          String dbEmail = userData['email'].toString().trim();
          print(
              'Checking email: $dbEmail against $email'); // Print emails being compared
          if (dbEmail == email.trim()) {
            print('User data found: $userData'); // Print userData
            return Userdetials(
              name: userData['name'],
              email: userData['email'],
              phonenumber: userData['phonenumber'],
              password: userData['password'],
              status: userData['status'],
              profileImage: userData['profileImage'],
            );
          }
        }
      }

      return null;
    } catch (e) {
      print('Error fetching user details: $e');
      return null;
    }
  }

  static DatabaseReference usersRef =
      FirebaseDatabase.instance.ref().child('Users');

  static Future<void> updateUserDetailsByEmail({
    required String email,
    required String name,
    required String phoneNumber,
    Uint8List? profileImage,
  }) async {
    DatabaseEvent databaseEvent = await usersRef.once();
    DataSnapshot dataSnapshot = databaseEvent.snapshot;

    if (dataSnapshot.value != null) {
      Map<dynamic, dynamic> usersData =
          dataSnapshot.value as Map<dynamic, dynamic>;

      for (var userId in usersData.keys) {
        var userData = usersData[userId];
        if (userData['email'] == email) {
          if (profileImage != null) {
            // Upload the image and get the URL
            String imageUrl = await uploadImageToStorage(profileImage, email);
            usersRef.child(userId).update({
              'name': name,
              'phonenumber': phoneNumber,
              'profileImage': imageUrl,
            });
          } else {
            usersRef.child(userId).update({
              'name': name,
              'phonenumber': phoneNumber,
            });
          }
          return;
        }
      }
    }
  }

  static Future<String> uploadImageToStorage(
      Uint8List image, String email) async {
    // Sanitize the email to use it as a filename
    final sanitizedEmail = email.replaceAll(RegExp(r'[^\w\s]+'), '');
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('profileImages/$sanitizedEmail.png');
    final uploadTask = storageRef.putData(image);
    final taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }

  static Future<Userdetials?> userGet() async {
    final Database db = await getdb();
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      orderBy: 'id DESC',
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Userdetials.fromJson(maps.first);
    } else {
      return null;
    }
  }

  static Future<List<Event>> getEvents() async {
    final db = await getdb();
    final List<Map<String, dynamic>> maps = await db.query('events');
    if (maps.isEmpty) {
      return getEvents();
    }
    return List.generate(maps.length, (i) {
      return Event.fromJson(maps[i]);
    });
  }

  static Future<List<Event>> getdateEvents(DateTime selectedDate) async {
    final List<Event> allEvents = await getEvents();
    final DateFormat dateFormat = DateFormat('dd-MM-yyyy');
    final String formattedDate = dateFormat.format(selectedDate);

    List<Event> filteredEvents = allEvents.where((event) {
      DateTime startDate = dateFormat.parse(event.startDate);
      DateTime endDate = dateFormat.parse(event.endDate!);
      if (selectedDate.isAfter(startDate) && selectedDate.isBefore(endDate) ||
          selectedDate.isAtSameMomentAs(startDate) ||
          selectedDate.isAtSameMomentAs(endDate)) {
        return true;
      }
      if (event.repeat == 'Daily') {
        return true;
      }
      if (event.repeat == 'Weekly' &&
          selectedDate.weekday == startDate.weekday) {
        return true;
      }
      if (event.repeat == 'Monthly' && selectedDate.day == startDate.day) {
        return true;
      }
      return formattedDate == event.startDate;
    }).toList();

    return filteredEvents;
  }

  static DateTime parseDateTime(String date, String time) {
    DateFormat dateFormat = DateFormat('dd-MM-yyyy');
    DateFormat timeFormat =
        DateFormat('hh:mm a'); // 'hh:mm a' for 12-hour format with AM/PM

    DateTime parsedDate = dateFormat.parse(date);
    DateTime parsedTime = timeFormat.parse(time);

    DateTime combinedDateTime = DateTime(
      parsedDate.year,
      parsedDate.month,
      parsedDate.day,
      parsedTime.hour,
      parsedTime.minute,
    );

    return combinedDateTime;
  }

  static Future<int> insertEvent(Event event) async {
    DateTime dateTime = parseDateTime(event.startDate, event.startTime);
    if (event.startDate != event.endDate) {
      event.repeat = "bettween";
    }
    final db = await getdb();
    int id = await db.insert(
      'events',
      event.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    DateTime getReminderTime(DateTime eventTime, int minutesBefore) {
      return eventTime.subtract(Duration(minutes: minutesBefore));
    }

    if (event.reminderBefore > 0) {
      DateTime reminderDateTime =
          getReminderTime(dateTime, event.reminderBefore);
      print('Reminder set for: $reminderDateTime');
      dateTime = reminderDateTime;
      print('Reminder set for: $dateTime');
    }
    if (event.repeat == "Daily") {
      NotificationService().scheduleDailyNotification(id, dateTime,
          event.eventName.toString(), event.eventDescription.toString());
    } else if (event.repeat == "Weekly") {
      NotificationService().scheduleWeeklyNotification(id, dateTime,
          event.eventName.toString(), event.eventDescription.toString());
    } else if (event.repeat == "Monthly") {
      NotificationService().scheduleMonthlyNotification(id, dateTime,
          event.eventName.toString(), event.eventDescription.toString());
    } else {
      if (DateFormat('dd-MM-yyyy')
          .parse(event.endDate!)
          .isAfter(DateFormat('dd-MM-yyyy').parse(event.startDate))) {
        print('Remaind :$dateTime');
        NotificationService().scheduleNotificationUptoEnd(
            id,
            dateTime,
            event.eventName.toString(),
            event.eventDescription.toString(),
            event);
      } else {
        print('Remaind :$dateTime');
        NotificationService().scheduleNotification(id, dateTime,
            event.eventName.toString(), event.eventDescription.toString());
      }
    }
    return id;
  }

  static Future<int> insertchildEvent(Event event) async {

    if (event.startDate != event.endDate) {
      event.repeat = "bettween";
    }
    final db = await getdb();
    List<Map<String, dynamic>> existingEvent = await db.query(
      'events',
      where: 'id = ?',
      whereArgs: [event.id],
    );

    if (existingEvent.isNotEmpty) {
      await db.update(
        'events',
        {'planevent': 'Yes'},
        where: 'id = ?',
        whereArgs: [event.id],
      );
    }

    // Calculate the scheduled date for the child event notification
    DateTime scheduledDateTime =
        parseDateTime(event.startDate, event.startTime);

    print('Scheduled Date Time: $scheduledDateTime');
    print('Current Date Time: ${DateTime.now()}');

    // Ensure that the scheduled date is in the future
    if (scheduledDateTime.isAfter(DateTime.now())) {
      int id = event.id! + 1;

      DateTime getReminderTime(DateTime eventTime, int minutesBefore) {
        return eventTime.subtract(Duration(minutes: minutesBefore));
      }

      if (event.reminderBefore > 0) {
        DateTime reminderDateTime =
            getReminderTime(scheduledDateTime, event.reminderBefore);
        print('Reminder set for: $reminderDateTime');
        scheduledDateTime = reminderDateTime;
        print('Reminder set for: $scheduledDateTime');
      }

      if (event.repeat == "Daily") {
        NotificationService().scheduleDailyNotification(id, scheduledDateTime,
            event.eventName.toString(), event.eventDescription.toString());
      } else if (event.repeat == "Weekly") {
        NotificationService().scheduleWeeklyNotification(id, scheduledDateTime,
            event.eventName.toString(), event.eventDescription.toString());
      } else if (event.repeat == "Monthly") {
        NotificationService().scheduleMonthlyNotification(id, scheduledDateTime,
            event.eventName.toString(), event.eventDescription.toString());
      } else {
        if (DateFormat('dd-MM-yyyy')
            .parse(event.endDate!)
            .isAfter(DateFormat('dd-MM-yyyy').parse(event.startDate))) {
          print('Remaind :$scheduledDateTime');
          NotificationService().scheduleNotificationUptoEnd(
              event.id!,
              scheduledDateTime,
              event.eventName.toString(),
              event.eventDescription.toString(),
              event);
        } else {
          print('Remaind :$scheduledDateTime');
          NotificationService().scheduleNotification(id, scheduledDateTime,
              event.eventName.toString(), event.eventDescription.toString());
        }
      }

      return id;
    } else {
      // If scheduled date is not in the future, handle accordingly (e.g., display an error message)
      return -1; // Return a sentinel value to indicate an error
    }
  }

  static Future<Event> getSingleEvent(Event event) async {
    final Database db = await getdb();
    final List<Map<String, dynamic>> maps =
        await db.query('events', where: 'id = ?', whereArgs: [event.id]);

    if (maps.isNotEmpty) {
      return Event.fromJson(maps.first);
    }
    return Event(
      eventName: "null",
      eventDescription: "null",
      planevent: "null",
      startDate: "null",
      endDate: "null",
      startTime: "null",
      endTime: "null",
      category: "null",
      repeat: "null",
      inviteGmails: "null",
      reminderBefore: 0,
    );
  }

  // Update an existing event in the database
  static Future<int> updateEvent(Event event) async {
    DateTime dateTime = parseDateTime(event.startDate, event.startTime);
    final db = await getdb();
    NotificationService.notificationsPlugin.cancel(event.id!);

    await db.update(
      'events',
      event.toJson(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
    DateTime getReminderTime(DateTime eventTime, int minutesBefore) {
      return eventTime.subtract(Duration(minutes: minutesBefore));
    }

    if (event.reminderBefore > 0) {
      DateTime reminderDateTime =
          getReminderTime(dateTime, event.reminderBefore);
      print('Reminder set for: $reminderDateTime');
      dateTime = reminderDateTime;
      print('Reminder set for: $dateTime');
    }
    if (event.repeat == "Daily") {
      NotificationService().scheduleDailyNotification(event.id!, dateTime,
          event.eventName.toString(), event.eventDescription.toString());
    } else if (event.repeat == "Weekly") {
      NotificationService().scheduleWeeklyNotification(event.id!, dateTime,
          event.eventName.toString(), event.eventDescription.toString());
    } else if (event.repeat == "Monthly") {
      NotificationService().scheduleMonthlyNotification(event.id!, dateTime,
          event.eventName.toString(), event.eventDescription.toString());
    } else {
      if (DateFormat('dd-MM-yyyy')
          .parse(event.endDate!)
          .isAfter(DateFormat('dd-MM-yyyy').parse(event.startDate))) {
        print('Remaind :$dateTime');
        NotificationService().scheduleNotificationUptoEnd(
            event.id!,
            dateTime,
            event.eventName.toString(),
            event.eventDescription.toString(),
            event);
      } else {
        print('Remaind :$dateTime');
        NotificationService().scheduleNotification(event.id!, dateTime,
            event.eventName.toString(), event.eventDescription.toString());
      }
    }

    return event.id!;
  }

  static Future<void> updateeventdone(Event event) async {
    event.isCompleted = 1;
    NotificationService.notificationsPlugin.cancel(event.id!);
    final db = await getdb();
    await db.update(
      'events',
      event.toJson(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  static Future<int> deleteEvent(int? id) async {
    Database db = await getdb();

    NotificationService.notificationsPlugin.cancel(id!);

    return await db.delete('events', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteafterdate() async {
    Database db = await getdb();
    DateTime now = DateTime.now();

    // Query events with date less than today and repeat equal to None
    List<Map<String, dynamic>> eventsToDelete = await db.query(
      'events',
      where: 'startDate < ? AND repeat = ?',
      whereArgs: [now.toString(), 'None'],
    );

    // Iterate through the events and delete them
    for (Map<String, dynamic> event in eventsToDelete) {
      await db.delete(
        'events',
        where: 'id = ?',
        whereArgs: [event['id']],
      );
      print(event);
    }
  }
}
