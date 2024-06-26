import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timesyncr/database/database_service.dart';
import 'package:timesyncr/models/Event.dart';

class TaskController extends GetxController {
  var events = <Event>[].obs;
  var dateevents = <Event>[].obs;

  @override
  void onInit() {
    super.onInit();

    fetchEvents();
    fetchtodayEvents();
  }

  Future<void> fetchEvents() async {
    events.value = await DatabaseService.getEvents();
  }

  

  Future<void> fetchtodayEvents() async {
    dateevents.value = await DatabaseService.getdateEvents(DateTime.now());
  }

  Future<void> fetchdateEvents(DateTime selectedDate) async {
    dateevents.value = await DatabaseService.getdateEvents(selectedDate);
  }

  Future<int> addEvent(Event event) async {
    int id = await DatabaseService.insertEvent(event);
    await fetchEvents(); // Refresh the events list after insertion
    return id;
  }

  Future<int> addchildEvent(Event event) async {
    int id = await DatabaseService.insertchildEvent(event);
    await fetchEvents(); // Refresh the events list after insertion
    return id;
  }

  void deleteEvent(Event event) async {
    await DatabaseService.deleteEvent(event.id);

    events.removeWhere((e) => e.id == event.id);
    dateevents.removeWhere((e) => e.id == event.id);
  }

  Future<Event> getEventsById(Event event) async {
    try {
      return await DatabaseService.getSingleEvent(event);
    } catch (e) {
      print('Error fetching events: $e');
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
  }

  Future<int> updateEvent(Event event) async {
    return await DatabaseService.updateEvent(event);
  }

  Future<void> updateeventdone(Event event) async {
    return await DatabaseService.updateeventdone(event);
  }

  Future<void> deleteafter() async {
    return await DatabaseService.deleteafterdate();
  }
}
