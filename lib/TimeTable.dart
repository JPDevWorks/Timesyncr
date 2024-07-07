import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timesyncr/Addevent.dart';

import 'package:timesyncr/TimeTable/Day.dart';
import 'package:timesyncr/TimeTable/Month.dart';
import 'package:timesyncr/TimeTable/Week.dart';
import 'package:timesyncr/ViewSomeEvents.dart';
import 'package:timesyncr/models/Event.dart';
import 'package:timesyncr/controller/newtask_controller.dart';
import 'package:timesyncr/them_controler.dart';

class TimeTable extends StatefulWidget {
  const TimeTable({Key? key}) : super(key: key);

  @override
  State<TimeTable> createState() => _TimeTableState();
}

class _TimeTableState extends State<TimeTable> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);
  final CalendarController _calendarController = CalendarController();
  final NewTaskController _taskController = Get.put(NewTaskController());
  late ThemeController _themeController;

  @override
  void initState() {
    super.initState();
    _themeController = Get.find<ThemeController>();
    _calendarController.selectedDate = DateTime.now();
    _taskController.fetchEvents(); // Initial fetch
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  void _onDateTapped(DateTime selectedDate, bool select) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPopupButton(
                context,
                "View Events on that Day",
                () {
                  Navigator.pop(context);
                  _taskController.fetchdateEvents(selectedDate);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ViewSomeEvents(),
                    ),
                  );
                },
              ),
              if (select) // Only display if select is true
                _buildPopupButton(
                  context,
                  "Add Event",
                  () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      '/newEvent',
                      arguments: {
                        'initialStartDate': selectedDate,
                        'initialStartTime':
                            TimeOfDay.fromDateTime(selectedDate),
                      },
                    );
                  },
                ),
            ],
          ),
        );
      },
      isScrollControlled: true,
    );
  }

  Widget _buildPopupButton(
      BuildContext context, String text, VoidCallback onPressed) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          backgroundColor: _themeController.isDarkTheme.value
              ? Colors.white //const Color(0xFF0D6E6E)
              : Colors.black, //const Color(0xFFFF3D3D),
          foregroundColor: const Color.fromARGB(255, 8, 69, 69),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: _themeController.isDarkTheme.value
                ? Colors.black //const Color(0xFF0D6E6E)
                : Colors.white,
          ),
        ),
      ),
    );
  }

  void _onMonthTapped(CalendarTapDetails details) {
    if (details.targetElement == CalendarElement.calendarCell) {
      DateTime selectedDate = details.date!;

      if (selectedDate.isAfter(DateTime.now()) ||
          (selectedDate.day == DateTime.now().day &&
              selectedDate.month == DateTime.now().month &&
              selectedDate.year == DateTime.now().year)) {
        _onDateTapped(selectedDate, true);
      } else {
        _onDateTapped(selectedDate, false);
      }
    }
  }

  void _onWeekTapped(CalendarTapDetails details) {
    if (details.targetElement == CalendarElement.calendarCell) {
      DateTime selectedDate = details.date!;
      if (selectedDate.isAfter(DateTime.now()) ||
          (selectedDate.day == DateTime.now().day &&
              selectedDate.month == DateTime.now().month &&
              selectedDate.year == DateTime.now().year)) {
        _onDateTapped(selectedDate, true);
      } else {
        _onDateTapped(selectedDate, false);
      }
    }
  }

  CalendarDataSource _getCalendarDataSource() {
    final DateFormat dateFormat = DateFormat('dd-MM-yyyy hh:mm a');
    List<Appointment> appointments = [];

    for (var event in _taskController.events) {
      Color color = Color(event.color!);
      DateTime startTime =
          dateFormat.parse('${event.startDate} ${event.startTime}');
      DateTime endTime = dateFormat.parse('${event.endDate} ${event.endTime}');
      DateTime currentDate = startTime;

      while (currentDate.isBefore(endTime) ||
          currentDate.isAtSameMomentAs(endTime)) {
        DateTime startOfCurrentDay = DateTime(
            currentDate.year,
            currentDate.month,
            currentDate.day,
            startTime.hour,
            startTime.minute);
        DateTime endOfCurrentDay = DateTime(currentDate.year, currentDate.month,
            currentDate.day, endTime.hour, endTime.minute);

        // Ensure the appointment does not exceed the event's end time
        if (endOfCurrentDay.isAfter(endTime)) {
          endOfCurrentDay = endTime;
        }

        appointments.add(Appointment(
          startTime: startOfCurrentDay,
          endTime: endOfCurrentDay,
          subject: event.title,
          color: color,
        ));

        currentDate = currentDate.add(Duration(days: 1));
      }

      // Handle recurring events
      if (event.repetitiveEvent == 'Daily') {
        for (int i = 1; i <= 365; i++) {
          DateTime newStartTime = startTime.add(Duration(days: i));
          DateTime newEndTime = endTime.add(Duration(days: i));
          appointments.add(Appointment(
            startTime: newStartTime,
            endTime: newEndTime,
            subject: event.title,
            color: color,
          ));
        }
      } else if (event.repetitiveEvent == 'Weekly') {
        for (int i = 1; i <= 52; i++) {
          DateTime newStartTime = startTime.add(Duration(days: i * 7));
          DateTime newEndTime = endTime.add(Duration(days: i * 7));
          appointments.add(Appointment(
            startTime: newStartTime,
            endTime: newEndTime,
            subject: event.title,
            color: color,
          ));
        }
      } else if (event.repetitiveEvent == 'Monthly') {
        DateTime nextMonthDate =
            DateTime(startTime.year, startTime.month + 1, startTime.day);
        int daysInNextMonth =
            DateTime(nextMonthDate.year, nextMonthDate.month + 1, 0).day;

        for (int i = 1; i <= daysInNextMonth; i++) {
          DateTime newStartTime =
              DateTime(startTime.year, startTime.month + 1, i);
          DateTime newEndTime = DateTime(endTime.year, endTime.month + 1, i);
          appointments.add(Appointment(
            startTime: newStartTime,
            endTime: newEndTime,
            subject: event.title,
            color: color,
          ));
        }
      }
    }

    return AppointmentDataSource(appointments);
  }

  Widget _monthCellBuilder(BuildContext context, MonthCellDetails details) {
    List<Appointment> appointments = details.appointments.cast<Appointment>();
    DateTime now = DateTime.now();
    bool isPastDate =
        details.date.isBefore(DateTime(now.year, now.month, now.day));

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: _themeController.isDarkTheme.value
              ? Colors.white
              : const Color.fromARGB(255, 82, 81, 81),
          width: 0.5,
        ),
        color: isPastDate
            ? Colors.grey
            : null, // Set background color for past dates
      ),
      child: Column(
        children: [
          Text(
            details.date.day.toString(),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: _themeController.isDarkTheme.value
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          if (appointments.isNotEmpty)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: appointments.map((appointment) {
                    return Container(
                      padding: const EdgeInsets.all(4),
                      margin: const EdgeInsets.symmetric(vertical: 1),
                      color: appointment.color,
                      child: Text(
                        appointment.subject,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          _themeController.isDarkTheme.value ? Colors.black : Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_view_month),
                label: 'Month',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_view_week),
                label: 'Week',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_view_day),
                label: 'Day',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: _themeController.isDarkTheme.value
                ? Colors.white
                : const Color.fromARGB(255, 0, 0, 0),
            onTap: _onItemTapped,
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              children: [
                MonthView(
                  taskController: _taskController,
                  themeController: _themeController,
                ),
                WeekView(
                  calendarController: _calendarController,
                  taskController: _taskController,
                  themeController: _themeController,
                  onTap: _onWeekTapped,
                  dataSource: _getCalendarDataSource(),
                  monthCellBuilder: _monthCellBuilder,
                ),
                DayView(
                  calendarController: _calendarController,
                  taskController: _taskController,
                  themeController: _themeController,
                  onTap: _onWeekTapped,
                  dataSource: _getCalendarDataSource(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
