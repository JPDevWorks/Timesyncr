import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:timesyncr/TimeTable.dart';
import 'package:timesyncr/controller/newtask_controller.dart';
import 'package:timesyncr/them_controler.dart';

class DayView extends StatelessWidget {
  final CalendarController calendarController;
  final NewTaskController taskController;
  final ThemeController themeController;
  final Function(CalendarTapDetails) onTap;
  final CalendarDataSource dataSource;

  const DayView({
    Key? key,
    required this.calendarController,
    required this.taskController,
    required this.themeController,
    required this.onTap,
    required this.dataSource,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final DateTime startOfDay = DateTime(now.year, now.month, now.day, 6, 50);

    return SfCalendar(
      view: CalendarView.day,
      initialDisplayDate: startOfDay,
      todayHighlightColor:
          themeController.isDarkTheme.value ? Colors.white : Colors.black,
      headerDateFormat: 'dd-MM-yy EEEE',
      headerHeight: 52,
      headerStyle: CalendarHeaderStyle(
        backgroundColor:
            themeController.isDarkTheme.value ? Colors.black : Colors.white,
        textAlign: TextAlign.center,
        textStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 25,
          color:
              themeController.isDarkTheme.value ? Colors.white : Colors.black,
        ),
      ),
      dataSource: dataSource,
      appointmentTextStyle: TextStyle(color: Colors.black),
      onTap: onTap,
      timeSlotViewSettings: TimeSlotViewSettings(
        timeIntervalHeight: 55,
        timeTextStyle: TextStyle(
          fontSize: 16,
          color:
              themeController.isDarkTheme.value ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
