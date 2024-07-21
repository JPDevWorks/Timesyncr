import 'package:intl/intl.dart';

class Event {
  int? id;
  String title;
  String location;
  String startDate;
  String startTime;
  String endDate;
  String endTime;
  bool isAllDayEvent;
  String repetitiveEvent;
  String selectedTag;
  String notes;
  int color;
  String? planevent;
  int? isCompleted;
  int? numberOfDays;
  String? uniquestr;

  Event(
      {this.id,
      required this.title,
      required this.location,
      required this.startDate,
      required this.startTime,
      required this.endDate,
      required this.endTime,
      required this.isAllDayEvent,
      required this.repetitiveEvent,
      required this.selectedTag,
      required this.notes,
      required this.color,
      required this.planevent,
      required this.isCompleted,
      required this.numberOfDays,
      required this.uniquestr,
      });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'startDate': startDate,
      'startTime': startTime,
      'endDate': endDate,
      'endTime': endTime,
      'isAllDayEvent': isAllDayEvent ? 1 : 0,
      'repetitiveEvent': repetitiveEvent,
      'selectedTag': selectedTag,
      'notes': notes,
      'color': color,
      'planevent': planevent,
      'isCompleted': isCompleted,
      'numberOfDays': numberOfDays,
      'uniquestr': uniquestr,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      title: map['title'],
      location: map['location'],
      startDate: map['startDate'],
      startTime: map['startTime'],
      endDate: map['endDate'],
      endTime: map['endTime'],
      isAllDayEvent: map['isAllDayEvent'] == 1,
      repetitiveEvent: map['repetitiveEvent'],
      selectedTag: map['selectedTag'],
      notes: map['notes'],
      color: map['color'],
      planevent: map['planevent'],
      isCompleted: map['isCompleted'],
      numberOfDays: map['numberOfDays'],
      uniquestr: map['uniquestr'],
    );
  }
}
