import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:timesyncr/ViewEvent.dart';
import 'package:timesyncr/controller/task_controller.dart';
import 'package:timesyncr/editevent.dart';
import 'package:timesyncr/models/Event.dart';
import 'package:timesyncr/them_controler.dart';

class DashBoard extends StatefulWidget {
  int count;
  DashBoard({Key? key, required this.count}) : super(key: key);

  @override
  State<DashBoard> createState() => _DashboardState();
}

class _DashboardState extends State<DashBoard> {
  final TaskController task = Get.put(TaskController());
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
              _buildDateHeader(),
              _buildWeeklyCalendar(),
              _buildEventList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateHeader() {
    final String currentDay = DateFormat('EEEE').format(DateTime.now());
    final String currentDate =
        DateFormat('dd MMMM yyyy').format(DateTime.now());

    return Obx(() {
      return Container(
        decoration: BoxDecoration(
          color: themeController.isDarkTheme.value
              ? Color(0xFF0D6E6E)
              : Color(0xFFFF3D3D),
          borderRadius: BorderRadius.circular(0),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$currentDay,',
                  style: TextStyle(
                    fontSize: 28,
                    color: themeController.isDarkTheme.value
                        ? Colors.black
                        : Colors.white,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 0),
                  child: Text(
                    currentDate,
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(
                  Icons.assignment,
                  color: themeController.isDarkTheme.value
                      ? Colors.white
                      : Colors.black,
                  size: 30,
                ),
                SizedBox(width: 5),
                Obx(() => Text(
                      '${task.dateevents.length} Tasks',
                      style: TextStyle(
                        fontSize: 20,
                        color: themeController.isDarkTheme.value
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildWeeklyCalendar() {
    DateTime now = DateTime.now();
    int today = now.weekday;
    DateTime firstDayOfWeek = now.subtract(Duration(days: today - 1));
    List<DateTime> weekDays =
        List.generate(7, (index) => firstDayOfWeek.add(Duration(days: index)));

    return Obx(() {
      return Container(
        color: themeController.isDarkTheme.value ? Colors.black : Colors.white,
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: weekDays.map((date) {
            bool isSelected = date.day == selectedDate.day &&
                date.month == selectedDate.month &&
                date.year == selectedDate.year;
            bool isToday = date.day == now.day &&
                date.month == now.month &&
                date.year == now.year;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedDate = date;
                  task.fetchdateEvents(selectedDate).then((_) {
                    if (mounted) {
                      setState(() {
                        widget.count = task.dateevents.length;
                      });
                    }
                  });
                });
              },
              child: Column(
                children: [
                  Text(
                    DateFormat('EEE').format(date),
                    style: TextStyle(
                      fontSize: 16,
                      color: isSelected
                          ? themeController.isDarkTheme.value
                              ? Color(0xFF0D6E6E)
                              : Color(0xFFFF3D3D)
                          : themeController.isDarkTheme.value
                              ? Colors.white
                              : Colors.black,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    DateFormat('d').format(date),
                    style: TextStyle(
                      fontSize: 16,
                      color: isSelected
                          ? themeController.isDarkTheme.value
                              ? Color(0xFF0D6E6E)
                              : Color(0xFFFF3D3D)
                          : themeController.isDarkTheme.value
                              ? Colors.white
                              : Colors.black,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (isToday)
                    Container(
                      margin: EdgeInsets.only(top: 4),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: themeController.isDarkTheme.value
                            ? Color(0xFF0D6E6E)
                            : Color(0xFFFF3D3D),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _buildEventList() {
    final List<Color> colors = [
      Color(0xFFFFF3E0),
      Color(0xFFFFFDE7),
      Color(0xFFE1F5FE),
      Color(0xFFF3E5F5),
      Color(0xFFE8F5E9),
      Color(0xFFFFEBEE),
      Color(0xFFFFF9C4),
    ];

    return Obx(() {
      return Container(
        color: themeController.isDarkTheme.value ? Colors.black : Colors.white,
        padding: const EdgeInsets.all(15.0),
        child: task.dateevents.isEmpty
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
            : ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: task.dateevents.length,
                itemBuilder: (context, index) {
                  final event = task.dateevents[index];
                  Color color = Color(event.color!);
                  return GestureDetector(
                    // onTap: () => _showBottomSheet(context, event, color),
                    child: _buildEventCard(event, index),
                  );
                },
              ),
      );
    });
  }

  Widget _buildEventCard(Event event, int index) {
    final startTime = DateFormat('hh:mm a').parse(event.startTime);
    final endTime = DateFormat('hh:mm a').parse(event.endTime);
    final duration = endTime.difference(startTime);
    final durationText =
        "${duration.inHours}h ${duration.inMinutes.remainder(60)}m";

    final eventDate = DateFormat('dd-MM-yyyy').parse(event.startDate);

    final currentDate = DateTime.now();
    final isToday = selectedDate.year == currentDate.year &&
        selectedDate.month == currentDate.month &&
        selectedDate.day == currentDate.day;

    Color color = Color(event.color!);

    return Container(
      height: 170,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                color,
                themeController.isDarkTheme.value ? Colors.black : Colors.white,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.eventName.toString().toUpperCase(),
                  style: GoogleFonts.aDLaMDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 1),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${event.startDate.toString()}",
                      style: TextStyle(
                          fontSize: 15,
                          color: themeController.isDarkTheme.value
                              ? Colors.white
                              : Colors.black),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    // Text(
                    //   "${event.endDate.toString()}",
                    //   style: TextStyle(
                    //       fontSize: 15,
                    //       color: themeController.isDarkTheme.value
                    //           ? Colors.white
                    //           : Colors.black),
                    // ),
                  ],
                ),
                SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            event.startTime,
                            style: TextStyle(
                                fontSize: 14,
                                color: themeController.isDarkTheme.value
                                    ? Colors.white
                                    : Colors.black),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "-",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 10),
                        Container(
                          child: Text(
                            event.endTime,
                            style: TextStyle(
                                fontSize: 14,
                                color: themeController.isDarkTheme.value
                                    ? Colors.white
                                    : Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditEvent(
                                  event: event,
                                  selectedDate: DateFormat('dd-MM-yyyy')
                                      .parse(event.startDate),
                                  startTime: DateFormat('hh:mm a')
                                      .parse(event.startTime),
                                  endTime: DateFormat('hh:mm a')
                                      .parse(event.endTime),
                                  endDate: DateFormat('dd-MM-yyyy')
                                      .parse(event.endDate!),
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(10),
                            foregroundColor: themeController.isDarkTheme.value
                                ? Color(0xFF0D6E6E)
                                : Color(0xFFFF3D3D),
                            backgroundColor: themeController.isDarkTheme.value
                                ? Colors.black
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            "Postpone",
                            style: TextStyle(
                              fontSize: 12,
                              color: themeController.isDarkTheme.value
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              task.updateeventdone(event);
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(10),
                            backgroundColor: themeController.isDarkTheme.value
                                ? Colors.black
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                event.isCompleted == 0 ? "Done" : "Completed",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: themeController.isDarkTheme.value
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.check,
                                size: 16,
                                color: themeController.isDarkTheme.value
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                          color: themeController.isDarkTheme.value
                              ? Colors.white
                              : Colors.black,
                          borderRadius: BorderRadius.circular(30)),
                      child: IconButton(
                          icon: Icon(
                            Icons.north_east,
                            color: themeController.isDarkTheme.value
                                ? Colors.black
                                : Colors.white,
                          ),
                          onPressed: () => {
                                Navigator.pop(context),
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ViewEvent(event: event, color: color),
                                  ),
                                )
                              }
                          //_showBottomSheet(context, event, color),
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context, Event event, Color color) {
    DateTime eventStartDateTime = DateFormat('dd-MM-yyyy hh:mm a')
        .parse('${event.startDate} ${event.startTime}');
    bool canEditEvent = eventStartDateTime.isAfter(DateTime.now());

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                event.eventName.toString().toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  task.deleteEvent(event);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeController.isDarkTheme.value
                      ? Color(0xFF0D6E6E)
                      : Color(0xFFFF3D3D),
                  foregroundColor: themeController.isDarkTheme.value
                      ? Color.fromARGB(255, 60, 188, 188)
                      : Color.fromARGB(255, 179, 80, 80),
                ),
                child: Text(
                  'Delete Event',
                  style: TextStyle(
                    color: themeController.isDarkTheme.value
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ViewEvent(event: event, color: color),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeController.isDarkTheme.value
                      ? Color(0xFF0D6E6E)
                      : Color(0xFFFF3D3D),
                  foregroundColor: themeController.isDarkTheme.value
                      ? Color.fromARGB(255, 60, 188, 188)
                      : Color.fromARGB(255, 179, 80, 80),
                ),
                child: Text(
                  'View Event Details',
                  style: TextStyle(
                    color: themeController.isDarkTheme.value
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 10),
              if (canEditEvent)
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditEvent(
                          event: event,
                          selectedDate:
                              DateFormat('dd-MM-yyyy').parse(event.startDate),
                          startTime:
                              DateFormat('hh:mm a').parse(event.startTime),
                          endTime: DateFormat('hh:mm a').parse(event.endTime),
                          endDate:
                              DateFormat('dd-MM-yyyy').parse(event.endDate!),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeController.isDarkTheme.value
                        ? Color(0xFF0D6E6E)
                        : Color(0xFFFF3D3D),
                    foregroundColor: themeController.isDarkTheme.value
                        ? Color.fromARGB(255, 60, 188, 188)
                        : Color.fromARGB(255, 179, 80, 80),
                  ),
                  child: Text(
                    'Edit Event Details',
                    style: TextStyle(
                      color: themeController.isDarkTheme.value
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
