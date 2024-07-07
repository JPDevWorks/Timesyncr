import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timesyncr/ViewEvent.dart';
import 'package:timesyncr/models/NewEvent.dart';
import 'package:timesyncr/them_controler.dart';
import 'package:timesyncr/controller/newtask_controller.dart';

class DashBoard extends StatefulWidget {
  int count;
  DashBoard({Key? key, required this.count}) : super(key: key);

  @override
  State<DashBoard> createState() => _DashboardState();
}

class _DashboardState extends State<DashBoard> {
  final NewTaskController task = Get.put(NewTaskController());
  final ThemeController themeController = Get.put(ThemeController());
  late DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    task.fetchdateEvents(selectedDate).then((_) {
      if (mounted) {
        setState(() {
          widget.count = task.dateevents.length;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          themeController.isDarkTheme.value ? Colors.black : Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildEventList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventList() {
    return Obx(() {
      final today = DateTime.now();
      final todayEvents = task.dateevents.where((event) {
        final eventDate = DateFormat('dd-MM-yyyy').parse(event.startDate);
        return eventDate.isSameDay(today) || shouldRepeatToday(event, today);
      }).toList();

      final upcomingEvents = task.events.where((event) {
        final eventDate = DateFormat('dd-MM-yyyy').parse(event.startDate);
        return eventDate.isAfter(today);
      }).toList()
        ..sort((a, b) {
          final dateA = DateFormat('dd-MM-yyyy').parse(a.startDate);
          final dateB = DateFormat('dd-MM-yyyy').parse(b.startDate);
          return dateA.compareTo(dateB);
        });

      // Sort events by start time
      todayEvents.sort((a, b) => _compareStartTime(a.startTime, b.startTime));

      // Group upcoming events by date
      final groupedEvents = _groupEventsByDate(upcomingEvents);

      return Container(
        color: themeController.isDarkTheme.value ? Colors.black : Colors.white,
        padding: const EdgeInsets.all(15.0),
        child: todayEvents.isEmpty && upcomingEvents.isEmpty
            ? Center(
                child: Text(
                  'No events found.',
                  style: TextStyle(
                    color: themeController.isDarkTheme.value
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              )
            : Column(
                children: [
                  SizedBox(height: 10),
                  _buildDateAndEvents(today, todayEvents),
                  Divider(
                    color: themeController.isDarkTheme.value
                        ? Colors.white
                        : Colors.black,
                    thickness: 1,
                  ),
                  for (final date in groupedEvents.keys) ...[
                    _buildDateAndEvents(date, groupedEvents[date]!),
                    Divider(
                      color: themeController.isDarkTheme.value
                          ? Colors.white
                          : Colors.black,
                      thickness: 1,
                    ),
                  ],
                ],
              ),
      );
    });
  }

  Map<DateTime, List<Event>> _groupEventsByDate(List<Event> events) {
    final Map<DateTime, List<Event>> groupedEvents = {};
    final dateFormat = DateFormat('dd-MM-yyyy');

    for (final event in events) {
      final eventDate = dateFormat.parse(event.startDate);
      final normalizedDate = DateTime.utc(
        eventDate.year,
        eventDate.month,
        eventDate.day,
      );

      if (!groupedEvents.containsKey(normalizedDate)) {
        groupedEvents[normalizedDate] = [];
      }

      groupedEvents[normalizedDate]!.add(event);
    }

    return groupedEvents;
  }

  int _compareStartTime(String startTimeA, String startTimeB) {
    final timeFormat = DateFormat('hh:mm a');
    final timeA = timeFormat.parse(startTimeA);
    final timeB = timeFormat.parse(startTimeB);
    return timeA.compareTo(timeB);
  }

  bool shouldRepeatToday(Event event, DateTime today) {
    final eventDate = DateFormat('dd-MM-yyyy').parse(event.startDate);
    final nowDate =
        DateFormat('dd-MM-yyyy').parse(DateFormat('dd-MM-yyyy').format(today));

    if (nowDate.isAfter(eventDate)) {
      if (event.repetitiveEvent == 'Daily') {
        return true;
      } else if (event.repetitiveEvent == 'Weekly') {
        return eventDate.weekday == today.weekday;
      } else if (event.repetitiveEvent == 'Monthly') {
        return eventDate.day == today.day;
      }
    }

    return false;
  }

  Widget _buildDateAndEvents(DateTime date, List<Event> events) {
    final isToday = date.isSameDay(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: 65, // Fixed width for alignment
                    height: isToday ? 70 : 50,
                    decoration: BoxDecoration(
                      color: isToday
                          ? themeController.isDarkTheme.value
                              ? Colors.white
                              : Colors.black
                          : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('dd').format(date),
                          style: TextStyle(
                            fontSize: isToday ? 30 : 22,
                            fontWeight: FontWeight.bold,
                            color: isToday
                                ? themeController.isDarkTheme.value
                                    ? Colors.black
                                    : Colors.white
                                : Colors.white,
                          ),
                        ),
                        Text(
                          DateFormat('MMM').format(date),
                          style: TextStyle(
                            fontSize: 12,
                            color: isToday
                                ? themeController.isDarkTheme.value
                                    ? Colors.black
                                    : Colors.white
                                : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 1,
                  ),
                ],
              ),
              SizedBox(width: 1), // Adjusted space for alignment
              Expanded(
                child: Column(
                  children: events.map((event) {
                    return Column(
                      children: [
                        if (events.indexOf(event) != 0)
                          Divider(
                            color: themeController.isDarkTheme.value
                                ? Colors.transparent
                                : Colors.transparent,
                            thickness: 0,
                          ),
                        _buildEventDetails(event),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventDetails(Event event) {
    Color color = Color(event.color!);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0),
      child: Container(
        margin: EdgeInsets.only(left: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        event.startTime,
                        style: TextStyle(
                          fontSize: 14,
                          color: themeController.isDarkTheme.value
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "-",
                        style: TextStyle(
                          color: themeController.isDarkTheme.value
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        event.endTime,
                        style: TextStyle(
                          fontSize: 14,
                          color: themeController.isDarkTheme.value
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        event.title,
                        style: GoogleFonts.aDLaMDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: themeController.isDarkTheme.value
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      if (event.planevent == "Yes")
                        Text(
                          "(Prep)",
                          style: GoogleFonts.aDLaMDisplay(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: themeController.isDarkTheme.value
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      SizedBox(
                        width: 5,
                      ),
                      if (event.isAllDayEvent)
                        Icon(
                          Icons.star,
                          size: 20,
                          color: themeController.isDarkTheme.value
                              ? Colors.red
                              : Colors.red,
                        ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      event.selectedTag,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.arrow_forward,
                color: themeController.isDarkTheme.value
                    ? Colors.white
                    : Colors.black,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewEvent(event: event, color: color),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

extension DateTimeExtension on DateTime {
  bool isSameDay(DateTime other) {
    return this.year == other.year &&
        this.month == other.month &&
        this.day == other.day;
  }
}
