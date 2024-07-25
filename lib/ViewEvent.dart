import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timesyncr/Home.dart';
import 'package:timesyncr/controller/newtask_controller.dart';
import 'package:timesyncr/editevent.dart';
import 'package:timesyncr/models/NewEvent.dart';
import 'package:timesyncr/them_controler.dart';

class ViewEvent extends StatefulWidget {
  final Event event;
  final Color color;

  ViewEvent({Key? key, required this.event, required this.color})
      : super(key: key);

  @override
  _ViewEventScreenState createState() => _ViewEventScreenState();
}

class _ViewEventScreenState extends State<ViewEvent> {
  final ThemeController themeController = Get.put(ThemeController());
  final NewTaskController task = Get.put(NewTaskController());

  void _confirmDeleteEvent() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Event'),
          content: Text('Are you sure you want to delete this event?'),
          actions: [
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                task.deleteEvent(widget.event);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => Homepage()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      bool isDark = themeController.isDarkTheme.value;
      return Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Homepage(),
                ),
              );
            },
          ),
          title: Text(
            'View Event',
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          backgroundColor: isDark ? Color(0xFF121212) : Colors.white,
          elevation: 0,
          actions: [
            if (widget.event.planevent == "No")
              IconButton(
                icon: Icon(Icons.edit),
                color: isDark ? Colors.white : Colors.black,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditEventScreen(
                        event: widget.event,
                      ),
                    ),
                  );
                },
              ),
            IconButton(
              icon: Icon(Icons.delete),
              color: isDark ? Colors.white : Colors.black,
              onPressed: _confirmDeleteEvent,
            ),
          ],
        ),
        body: Container(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReadOnlyField('Title', widget.event.title, isDark),
                  SizedBox(height: 10),
                  _buildReadOnlyField(
                      'Location or meeting URL', widget.event.location, isDark),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('All-Day-Repeat',
                          style: TextStyle(
                              color: isDark ? Colors.white : Colors.black)),
                      Switch(
                        value: widget.event.isAllDayEvent,
                        onChanged: null,
                        activeColor: Colors.teal,
                      ),
                    ],
                  ),
                  if (widget.event.isAllDayEvent) ...[
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('Start Date:',
                            style: TextStyle(
                                color: isDark ? Colors.white : Colors.black)),
                        SizedBox(
                          width: 150,
                        ),
                        Expanded(
                          child: InputDecorator(
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 5),
                              filled: true,
                              fillColor:
                                  isDark ? Color(0xFF1C1C1C) : Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: Icon(Icons.arrow_drop_down,
                                  color: isDark ? Colors.white : Colors.black),
                            ),
                            child: Text(
                              DateFormat('MMM dd').format(
                                  DateFormat('dd-MM-yyyy')
                                      .parse(widget.event.startDate)),
                              style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text('End Date:',
                            style: TextStyle(
                                color: isDark ? Colors.white : Colors.black)),
                        SizedBox(width: 160),
                        Expanded(
                          child: InputDecorator(
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 5),
                              filled: true,
                              fillColor:
                                  isDark ? Color(0xFF1C1C1C) : Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: Icon(Icons.arrow_drop_down,
                                  color: isDark ? Colors.white : Colors.black),
                            ),
                            child: Text(
                              DateFormat('MMM dd').format(
                                  DateFormat('dd-MM-yyyy')
                                      .parse(widget.event.endDate)),
                              style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text('Start',
                            style: TextStyle(
                                color: isDark ? Colors.white : Colors.black)),
                        SizedBox(width: 80),
                        Expanded(
                          child: InputDecorator(
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 5),
                              filled: true,
                              fillColor:
                                  isDark ? Color(0xFF1C1C1C) : Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: Icon(Icons.arrow_drop_down,
                                  color: isDark ? Colors.white : Colors.black),
                            ),
                            child: Text(
                              DateFormat('MMM dd').format(
                                  DateFormat('dd-MM-yyyy')
                                      .parse(widget.event.startDate)),
                              style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: InputDecorator(
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 5),
                              filled: true,
                              fillColor:
                                  isDark ? Color(0xFF1C1C1C) : Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: Icon(Icons.arrow_drop_down,
                                  color: isDark ? Colors.white : Colors.black),
                            ),
                            child: Text(
                              widget.event.startTime,
                              style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text('End',
                            style: TextStyle(
                                color: isDark ? Colors.white : Colors.black)),
                        SizedBox(width: 90),
                        Expanded(
                          child: InputDecorator(
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 5),
                              filled: true,
                              fillColor:
                                  isDark ? Color(0xFF1C1C1C) : Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: Icon(Icons.arrow_drop_down,
                                  color: isDark ? Colors.white : Colors.black),
                            ),
                            child: Text(
                              DateFormat('MMM dd').format(
                                  DateFormat('dd-MM-yyyy')
                                      .parse(widget.event.endDate)),
                              style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: InputDecorator(
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 5),
                              filled: true,
                              fillColor:
                                  isDark ? Color(0xFF1C1C1C) : Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: Icon(Icons.arrow_drop_down,
                                  color: isDark ? Colors.white : Colors.black),
                            ),
                            child: Text(
                              widget.event.endTime,
                              style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Repetitive event',
                          style: TextStyle(
                              color: isDark ? Colors.white : Colors.black)),
                      Switch(
                        value: widget.event.repetitiveEvent != 'None',
                        onChanged: null,
                        activeColor: Colors.teal,
                      ),
                    ],
                  ),
                  if (widget.event.repetitiveEvent != 'None') ...[
                    SizedBox(height: 10),
                    Text('Repetition:',
                        style: TextStyle(
                            color: isDark ? Colors.white : Colors.black)),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        _buildRepetitionOption(
                            'Daily', widget.event.repetitiveEvent, isDark),
                        SizedBox(width: 10),
                        _buildRepetitionOption(
                            'Weekly', widget.event.repetitiveEvent, isDark),
                        SizedBox(width: 10),
                        _buildRepetitionOption(
                            'Monthly', widget.event.repetitiveEvent, isDark),
                      ],
                    ),
                  ],
                  SizedBox(height: 20),
                  Text('Tags:',
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black)),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildTag('Others', Color(0xFFDEDAF4), isDark),
                      _buildTag('FITNESS', Color(0xFFFFADAD), isDark),
                      _buildTag('ME TIME', Color(0xFFFFD6A5), isDark),
                      _buildTag('FAMILY', Color(0xFFD9EDF8), isDark),
                      _buildTag('FRIENDS', Color(0xFFFFDffb6), isDark),
                      _buildTag('WORK', Color(0xFFFFADAD), isDark),
                      _buildTag('HEALTH', Color(0xFFFFD6A5), isDark),
                      _buildTag('TRAVEL', Color(0xFFDEDAF4), isDark),
                      _buildTag('HOBBY', Color(0xFFFFDffb6), isDark),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text('Notes:',
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black)),
                  SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    decoration: BoxDecoration(
                      color: isDark ? Color(0xFF1C1C1C) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      widget.event.notes,
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildReadOnlyField(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          decoration: BoxDecoration(
            color: isDark ? Color(0xFF1C1C1C) : Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            value,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildRepetitionOption(String label, String value, bool isDark) {
    return GestureDetector(
      onTap: null,
      child: Chip(
        label: Text(
          label,
          style: TextStyle(color: value == label ? Colors.white : Colors.black),
        ),
        backgroundColor: value == label ? Colors.black : Colors.white,
      ),
    );
  }

  Widget _buildTag(String label, Color color, bool isDark) {
    return GestureDetector(
      onTap: null,
      child: Container(
        decoration: BoxDecoration(
          color: widget.event.selectedTag == label ? Colors.black : color,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          label,
          style: TextStyle(
            color:
                widget.event.selectedTag == label ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
