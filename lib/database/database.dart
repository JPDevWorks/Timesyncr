import 'dart:typed_data';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:timesyncr/models/NewEvent.dart';
import 'package:timesyncr/models/user.dart';
import 'package:timesyncr/service/NotificationService.dart';

class Databasee {
  static const int _version = 1;
  static const String _dbname = "timesyncrdatabase";

  static Future<Database> getdb() async {
    return openDatabase(
      join(await getDatabasesPath(), _dbname),
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE Event (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          location TEXT,
          startDate TEXT,
          startTime TEXT,
          endDate TEXT,
          endTime TEXT,
          isAllDayEvent INTEGER,
          repetitiveEvent TEXT,
          selectedTag TEXT,
          notes TEXT,
          planevent TEXT,
          isCompleted INTEGER,
          color INTEGER,
          numberOfDays INTEGER
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
    final List<Map<String, dynamic>> maps = await db.query('Event');
    if (maps.isEmpty) {
      return getEvents();
    }
    return List.generate(maps.length, (i) {
      return Event.fromMap(maps[i]);
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
      if (event.repetitiveEvent == 'Daily') {
        return true;
      }
      if (event.repetitiveEvent == 'Weekly' &&
          selectedDate.weekday == startDate.weekday) {
        return true;
      }
      if (event.repetitiveEvent == 'Monthly' &&
          selectedDate.day == startDate.day) {
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

    // Combine date and time correctly
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
    print(event.startDate);
    print(event.startTime);
    print(dateTime);

    final db = await getdb();

    if (event.numberOfDays! > 0) {
      if (event.repetitiveEvent != "Daily" &&
          event.repetitiveEvent != "Weekly" &&
          event.repetitiveEvent != "Monthly") {
        event.repetitiveEvent = "Bettween";
      } else if (event.repetitiveEvent == "Daily") {
        event.repetitiveEvent = "BettweenDaily";
      } else if (event.repetitiveEvent == "Weekly") {
        event.repetitiveEvent = "BettweenWeekly";
      } else if (event.repetitiveEvent == "Monthly") {
        event.repetitiveEvent = "BettweenMonthly";
      }
    }

    if (event.repetitiveEvent == "BettweenDaily" ||
        event.repetitiveEvent == "Bettween") {
      for (int i = 0; i < event.numberOfDays!; i++) {
        DateTime notificationTime = dateTime.add(Duration(days: i));
        print(notificationTime);

        Event dailyEvent = Event(
          title: event.title,
          location: event.location,
          startDate: DateFormat('dd-MM-yyyy').format(notificationTime),
          startTime: DateFormat('hh:mm a').format(notificationTime),
          endDate: DateFormat('dd-MM-yyyy').format(notificationTime),
          endTime: event.endTime,
          isAllDayEvent: event.isAllDayEvent,
          repetitiveEvent: event.repetitiveEvent,
          selectedTag: event.selectedTag,
          notes: event.notes,
          color: event.color,
          planevent: event.planevent,
          isCompleted: event.isCompleted,
          numberOfDays: event.numberOfDays,
        );

        int id = await db.insert(
          'Event',
          dailyEvent.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        print(dailyEvent.toMap());
        print('Bettween Remainder added successfully ');

        NotificationService().scheduleNotification(id, notificationTime,
            event.title.toString(), event.notes.toString());
      }
    } else if (event.repetitiveEvent == "BettweenWeekly") {
      for (int i = 0; i < event.numberOfDays!; i += 7) {
        DateTime notificationTime = dateTime.add(Duration(days: i));
        print(notificationTime);

        Event weeklyEvent = Event(
          title: event.title,
          location: event.location,
          startDate: DateFormat('dd-MM-yyyy').format(notificationTime),
          startTime: DateFormat('hh:mm a').format(notificationTime),
          endDate: DateFormat('dd-MM-yyyy').format(notificationTime),
          endTime: event.endTime,
          isAllDayEvent: event.isAllDayEvent,
          repetitiveEvent: event.repetitiveEvent,
          selectedTag: event.selectedTag,
          notes: event.notes,
          color: event.color,
          planevent: event.planevent,
          isCompleted: event.isCompleted,
          numberOfDays: event.numberOfDays,
        );

        int id = await db.insert(
          'Event',
          weeklyEvent.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        print(weeklyEvent.toMap());
        print('Bettween Weekly Remainder added successfully ');

        NotificationService().scheduleNotification(id, notificationTime,
            event.title.toString(), event.notes.toString());
      }
    } else if (event.repetitiveEvent == "BettweenWeekly") {
      for (int i = 0; i < event.numberOfDays!; i += 30) {
        DateTime notificationTime =
            DateTime(dateTime.year, dateTime.month + (i ~/ 30), dateTime.day);
        print(notificationTime);

        Event monthlyEvent = Event(
          title: event.title,
          location: event.location,
          startDate: DateFormat('dd-MM-yyyy').format(notificationTime),
          startTime: DateFormat('hh:mm a').format(notificationTime),
          endDate: DateFormat('dd-MM-yyyy').format(notificationTime),
          endTime: event.endTime,
          isAllDayEvent: event.isAllDayEvent,
          repetitiveEvent: event.repetitiveEvent,
          selectedTag: event.selectedTag,
          notes: event.notes,
          color: event.color,
          planevent: event.planevent,
          isCompleted: event.isCompleted,
          numberOfDays: event.numberOfDays,
        );

        int id = await db.insert(
          'Event',
          monthlyEvent.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        print(monthlyEvent.toMap());
        print('Bettween Monthly Remainder added successfully ');

        NotificationService().scheduleNotification(id, notificationTime,
            event.title.toString(), event.notes.toString());
      }
    } else {
      int id = await db.insert(
        'Event',
        event.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      DateTime getReminderTime(DateTime eventTime, int minutesBefore) {
        return eventTime.subtract(Duration(minutes: minutesBefore));
      }

      // if (event.reminderBefore > 0) {
      //   DateTime reminderDateTime =
      //       getReminderTime(dateTime, event.reminderBefore);
      //   print('Reminder set for: $reminderDateTime');
      //   dateTime = reminderDateTime;
      //   print('Reminder set for: $dateTime');
      // }
      if (event.repetitiveEvent == "Daily") {
        print('Daily Remainder added successfully ');
        NotificationService().scheduleDailyNotification(
            id, dateTime, event.title.toString(), event.notes.toString());
      } else if (event.repetitiveEvent == "Weekly") {
        print('Weekly Remainder added successfully ');
        NotificationService().scheduleWeeklyNotification(
            id, dateTime, event.title.toString(), event.notes.toString());
      } else if (event.repetitiveEvent == "Monthly") {
        print('Monthly Remainder added successfully ');
        NotificationService().scheduleMonthlyNotification(
            id, dateTime, event.title.toString(), event.notes.toString());
      } else {
        print('Remaind :$dateTime');
        NotificationService().scheduleNotification(
            id, dateTime, event.title.toString(), event.notes.toString());
      }
      return id;
    }
    return 1;
  }

  // static Future<int> insertchildEvent(Event event) async {
  //   if (event.startDate != event.endDate) {
  //     event.repetitiveEvent = "bettween";
  //   }
  //   final db = await getdb();
  //   List<Map<String, dynamic>> existingEvent = await db.query(
  //     'Event',
  //     where: 'id = ?',
  //     whereArgs: [event.id],
  //   );

  //   if (existingEvent.isNotEmpty) {
  //     await db.update(
  //       'Event',
  //       {'planevent': 'Yes'},
  //       where: 'id = ?',
  //       whereArgs: [event.id],
  //     );
  //   }

  //   // Calculate the scheduled date for the child event notification
  //   DateTime scheduledDateTime =
  //       parseDateTime(event.startDate, event.startTime);

  //   print('Scheduled Date Time: $scheduledDateTime');
  //   print('Current Date Time: ${DateTime.now()}');

  //   // Ensure that the scheduled date is in the future
  //   if (scheduledDateTime.isAfter(DateTime.now())) {
  //     int id = event.id! + 1;

  //     DateTime getReminderTime(DateTime eventTime, int minutesBefore) {
  //       return eventTime.subtract(Duration(minutes: minutesBefore));
  //     }

  //     // if (event.reminderBefore > 0) {
  //     //   DateTime reminderDateTime =
  //     //       getReminderTime(scheduledDateTime, event.reminderBefore);
  //     //   print('Reminder set for: $reminderDateTime');
  //     //   scheduledDateTime = reminderDateTime;
  //     //   print('Reminder set for: $scheduledDateTime');
  //     // }

  //     if (event.repetitiveEvent == "Daily") {
  //       NotificationService().scheduleDailyNotification(id, scheduledDateTime,
  //           event.title.toString(), event.notes.toString());
  //     } else if (event.repetitiveEvent == "Weekly") {
  //       NotificationService().scheduleWeeklyNotification(id, scheduledDateTime,
  //           event.title.toString(), event.notes.toString());
  //     } else if (event.repetitiveEvent == "Monthly") {
  //       NotificationService().scheduleMonthlyNotification(id, scheduledDateTime,
  //           event.title.toString(), event.notes.toString());
  //     } else {
  //       if (DateFormat('dd-MM-yyyy')
  //           .parse(event.endDate)
  //           .isAfter(DateFormat('dd-MM-yyyy').parse(event.startDate))) {
  //         print('Remaind :$scheduledDateTime');
  //         NotificationService().scheduleNotificationUptoEnd(
  //             event.id!,
  //             scheduledDateTime,
  //             event.title.toString(),
  //             event.notes.toString(),
  //             event);
  //       } else {
  //         print('Remaind :$scheduledDateTime');
  //         NotificationService().scheduleNotification(id, scheduledDateTime,
  //             event.title.toString(), event.notes.toString());
  //       }
  //     }

  //     return id;
  //   } else {
  //     // If scheduled date is not in the future, handle accordingly (e.g., display an error message)
  //     return -1; // Return a sentinel value to indicate an error
  //   }
  // }

  static Future<Event> getSingleEventId(int id) async {
    final Database db = await getdb();
    final List<Map<String, dynamic>> maps =
        await db.query('Event', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Event.fromMap(maps.first);
    }
    return Event(
      id: null,
      title: "null",
      location: "null",
      startDate: "null",
      startTime: "null",
      endDate: "null",
      endTime: "null",
      isAllDayEvent: false,
      repetitiveEvent: "null",
      selectedTag: "null",
      notes: "null",
      color: 0,
      planevent: "null",
      isCompleted: 0,
      numberOfDays: 0,
    );
  }

  static Future<Event> getSingleEvent(Event event) async {
    final Database db = await getdb();
    final List<Map<String, dynamic>> maps =
        await db.query('Event', where: 'id = ?', whereArgs: [event.id]);

    if (maps.isNotEmpty) {
      return Event.fromMap(maps.first);
    }
    return Event(
      id: null,
      title: "null",
      location: "null",
      startDate: "null",
      startTime: "null",
      endDate: "null",
      endTime: "null",
      isAllDayEvent: false,
      repetitiveEvent: "null",
      selectedTag: "null",
      notes: "null",
      color: 0,
      planevent: "null",
      isCompleted: 0,
      numberOfDays: 0,
    );
  }

  // Update an existing event in the database
  static Future<int> updateEvent(Event event) async {
    DateTime dateTime = parseDateTime(event.startDate, event.startTime);
    final db = await getdb();
    await db.update(
      'Event',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
    return event.id!;
  }

  static Future<void> updateeventdone(Event event) async {
    event.isCompleted = 1;
    NotificationService.notificationsPlugin.cancel(event.id!);
    final db = await getdb();
    await db.update(
      'Event',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  static Future<int> deleteEvent(int? id) async {
    Database db = await getdb();

    NotificationService.notificationsPlugin.cancel(id!);

    return await db.delete('Event', where: 'id = ?', whereArgs: [id]);
  }

  // static Future<void> deleteafterdate() async {
  //   Database db = await getdb();
  //   DateTime now = DateTime.now();

  //   // Query events with date less than today and repeat equal to None
  //   List<Map<String, dynamic>> eventsToDelete = await db.query(
  //     'events',
  //     where: 'startDate < ? AND repeat = ?',
  //     whereArgs: [now.toString(), 'None'],
  //   );

  //   // Iterate through the events and delete them
  //   for (Map<String, dynamic> event in eventsToDelete) {
  //     await db.delete(
  //       'events',
  //       where: 'id = ?',
  //       whereArgs: [event['id']],
  //     );
  //     print(event);
  //   }
  // }
}
