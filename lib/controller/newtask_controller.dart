import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timesyncr/database/database.dart';
import 'package:timesyncr/models/NewEvent.dart';

class NewTaskController extends GetxController {
  var events = <Event>[].obs;
  var dateevents = <Event>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchEvents();
    fetchtodayEvents();
  }

  Future<void> fetchEvents() async {
    events.value = await Databasee.getEvents();
  }

  Future<void> fetchtodayEvents() async {
    dateevents.value = await Databasee.getdateEvents(DateTime.now());
  }

  Future<void> fetchdateEvents(DateTime selectedDate) async {
    dateevents.value = await Databasee.getdateEvents(selectedDate);
  }

  Future<int> addEvent(Event event) async {
    int id = await Databasee.insertEvent(event);
    await fetchEvents();
    return id;
  }

  // Future<int> addchildEvent(Event event) async {
  //   int id = await Databasee.insertchildEvent(event);
  //   await fetchEvents(); // Refresh the events list after insertion
  //   return id;
  // }

  void deleteEvent(Event event) async {
    await Databasee.deleteEvent(event.id);

    events.removeWhere((e) => e.id == event.id);
    dateevents.removeWhere((e) => e.id == event.id);
  }

  Future<Event> getEventsByIdonly(int id) async {
    try {
      return await Databasee.getSingleEventId(id);
    } catch (e) {
      print('Error fetching events: $e');
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
  }

  Future<Event> getEventsById(Event event) async {
    try {
      return await Databasee.getSingleEvent(event);
    } catch (e) {
      print('Error fetching events: $e');
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
  }

  Future<int> updateEvent(Event event) async {
    return await Databasee.updateEvent(event);
  }

  Future<void> updateeventdone(Event event) async {
    return await Databasee.updateeventdone(event);
  }

  // Future<void> deleteafter() async {
  //   return await DatabaseService.deleteafterdate();
  // }
}
