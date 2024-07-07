import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:timesyncr/TimeTable.dart';
import 'package:timesyncr/controller/newtask_controller.dart';
import 'package:timesyncr/them_controler.dart';

class WeekView extends StatelessWidget {
  final CalendarController calendarController;
  final NewTaskController taskController;
  final ThemeController themeController;
  final Function(CalendarTapDetails) onTap;
  final CalendarDataSource dataSource;
  final Widget Function(BuildContext, MonthCellDetails) monthCellBuilder;

  const WeekView({
    Key? key,
    required this.calendarController,
    required this.taskController,
    required this.themeController,
    required this.onTap,
    required this.dataSource,
    required this.monthCellBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final DateTime startOfDay = DateTime(now.year, now.month, now.day, 6, 20);

    return SfCalendar(
      view: CalendarView.week,
      firstDayOfWeek: startOfDay.weekday,
      initialDisplayDate: startOfDay,
      todayHighlightColor:
          themeController.isDarkTheme.value ? Colors.white : Colors.black,
      headerStyle: CalendarHeaderStyle(
        textAlign: TextAlign.center,
        textStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 25,
          color:
              themeController.isDarkTheme.value ? Colors.white : Colors.black,
        ),
      ),
      dataSource: dataSource,
      monthCellBuilder: monthCellBuilder,
      onTap: onTap,
      timeSlotViewSettings: TimeSlotViewSettings(
        timeIntervalHeight: 50,
        timeTextStyle: TextStyle(
          fontSize: 16,
          color:
              themeController.isDarkTheme.value ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
