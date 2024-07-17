import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timesyncr/ViewEvent.dart';
import 'package:timesyncr/controller/newtask_controller.dart';
import 'package:timesyncr/them_controler.dart';
import 'package:intl/intl.dart';

class MonthView extends StatefulWidget {
  final NewTaskController taskController;
  final ThemeController themeController;

  const MonthView({
    Key? key,
    required this.taskController,
    required this.themeController,
  }) : super(key: key);

  @override
  _MonthViewState createState() => _MonthViewState();
}

class _MonthViewState extends State<MonthView> {
  late List _selectedEvents;
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late Map<DateTime, List> _events;

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _selectedEvents = [];
    _fetchEventsForSelectedDay();
    _events = _getEventMap();
  }

  void _onMonthTapped(DateTime selectedDate) {
    if (selectedDate.isAfter(DateTime.now()) ||
        (selectedDate.day == DateTime.now().day &&
            selectedDate.month == DateTime.now().month &&
            selectedDate.year == DateTime.now().year)) {
      Navigator.pop(context);
      Navigator.pushNamed(
        context,
        '/newEvent',
        arguments: {
          'initialStartDate': selectedDate,
          'initialStartTime': TimeOfDay.fromDateTime(selectedDate),
        },
      );
    }
  }

  Future<void> _fetchEventsForSelectedDay() async {
    await widget.taskController.fetchdateEvents(_selectedDay);
    setState(() {
      _selectedEvents = widget.taskController.dateevents;
    });
  }

  Map<DateTime, List> _getEventMap() {
    final events = <DateTime, List>{};
    final dateFormat = DateFormat('dd-MM-yyyy');

    for (var event in widget.taskController.events) {
      final eventDate = dateFormat.parse(event.startDate.toString());

      final normalizedDate =
          DateTime.utc(eventDate.year, eventDate.month, eventDate.day);

      if (events[normalizedDate] == null) {
        events[normalizedDate] = [];
      }
      events[normalizedDate]!.add(event.title);

      if (event.repetitiveEvent == 'Daily') {
        for (var i = 1; i <= 365; i++) {
          final repeatDate = normalizedDate.add(Duration(days: i));
          if (events[repeatDate] == null) {
            events[repeatDate] = [];
          }
          events[repeatDate]!.add(event.title);
        }
      } else if (event.repetitiveEvent == 'Weekly') {
        for (var i = 1; i <= 52; i++) {
          final repeatDate = normalizedDate.add(Duration(days: 7 * i));
          if (events[repeatDate] == null) {
            events[repeatDate] = [];
          }
          events[repeatDate]!.add(event.title);
        }
      } else if (event.repetitiveEvent == 'Monthly') {
        for (var i = 1; i <= 12; i++) {
          final repeatDate = DateTime(
            normalizedDate.year,
            normalizedDate.month + i,
            normalizedDate.day,
          );
          if (events[repeatDate] == null) {
            events[repeatDate] = [];
          }
          events[repeatDate]!.add(event.title);
        }
      }
    }

    return events;
  }

  List _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime.utc(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    _fetchEventsForSelectedDay();
  }

  void _showBottomSheet(BuildContext context, dynamic event, Color color) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          width: MediaQuery.of(context).size.width, // Full-width container
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // Make buttons full-width
            children: [
              Text(
                event.title.toString().toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the bottom sheet
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewEvent(
                          event: event, color: color), // Pass color here
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.themeController.isDarkTheme.value
                      ? Colors.white
                      : Colors.black,
                  minimumSize: const Size(double.infinity,
                      50), // Full-width button with fixed height
                ),
                child: Text(
                  'View Event Details',
                  style: TextStyle(
                    color: widget.themeController.isDarkTheme.value
                        ? Colors.black
                        : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          GestureDetector(
            onDoubleTap: () => _onMonthTapped(_selectedDay),
            child: TableCalendar(
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: _onDaySelected,
              eventLoader: _getEventsForDay,
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: widget.themeController.isDarkTheme.value
                      ? Colors.black
                      : Colors.black,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: widget.themeController.isDarkTheme.value
                      ? Colors.white60
                      : Colors.grey,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 1, // Ensure only one dot is displayed
                weekendTextStyle: TextStyle(
                  color: widget.themeController.isDarkTheme.value
                      ? Colors.white
                      : Colors.black,
                ),
                outsideTextStyle: TextStyle(
                  color: Colors.grey,
                ),
                defaultTextStyle: TextStyle(
                  color: widget.themeController.isDarkTheme.value
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: widget.themeController.isDarkTheme.value
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Container(
            width: double.infinity,
            height: 50,
            color: widget.themeController.isDarkTheme.value
                ? Colors.grey[900]
                : Colors.black26, // Color(0xFFFF3D3D),
            child: Center(
              child: Text(
                '${DateFormat('MMMM dd, yyyy').format(_selectedDay)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: widget.themeController.isDarkTheme.value
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Obx(() {
            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: widget.taskController.dateevents.length,
              itemBuilder: (context, index) {
                final event = widget.taskController.dateevents[index];
                final eventStartDate =
                    DateFormat('dd-MM-yyyy').parse(event.startDate);
                final startTime = DateFormat('hh:mm a').parse(event.startTime);
                final endTime = DateFormat('hh:mm a').parse(event.endTime);
                Color color = Color(event.color);

                if (eventStartDate.isBefore(_selectedDay) ||
                    eventStartDate.isAtSameMomentAs(_selectedDay)) {
                  return GestureDetector(
                    onTap: () => _showBottomSheet(context, event, color),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: widget.themeController.isDarkTheme.value
                              ? Colors.white
                              : Colors.black,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 80,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12.0),
                                bottomLeft: Radius.circular(12.0),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListTile(
                              title: Text('${event.title}'),
                              subtitle: Text(
                                'Start: ${DateFormat('hh:mm a').format(startTime)}\nEnd: ${DateFormat('hh:mm a').format(endTime)}',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return SizedBox.shrink();
                }
              },
            );
          }),
        ],
      ),
    );
  }
}
