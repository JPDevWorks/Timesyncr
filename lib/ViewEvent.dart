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
  _ViewEventState createState() => _ViewEventState();
}

class _ViewEventState extends State<ViewEvent> {
  final NewTaskController task = Get.put(NewTaskController());
  final ThemeController _themeController = Get.put(ThemeController());

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
    return Scaffold(
      backgroundColor:
          _themeController.isDarkTheme.value ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: widget.color,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/home');
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            color: Colors.black,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditEventScreen(
                    eventId: widget.event.id!,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            color: Colors.black,
            onPressed: _confirmDeleteEvent,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 20),
              _buildDetailSection(
                icon: Icons.description,
                title: 'Notes',
                content: widget.event.notes.toString(),
              ),
              _buildTimeSection(),
              _buildDetailSection(
                icon: Icons.calendar_today,
                title: 'Start Date',
                content: widget.event.startDate,
              ),
              _buildDetailSection(
                icon: Icons.calendar_today,
                title: 'End Date',
                content: widget.event.endDate.toString(),
              ),
              _buildDetailSection(
                icon: Icons.repeat,
                title: 'Repeat',
                content: widget.event.repetitiveEvent.toString(),
              ),
              _buildTimeLeftCard(),
              const SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      task.updateeventdone(widget.event);
                      Navigator.pushNamed(context, '/home');
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _themeController.isDarkTheme.value
                        ? widget.event.isCompleted == 1
                            ? Colors.grey
                            : Colors.white70
                        : widget.event.isCompleted == 1
                            ? Colors.grey
                            : Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  ),
                  child: Text(
                    widget.event.isCompleted == 0
                        ? "Mark as Done"
                        : "Completed",
                    style: TextStyle(
                      color: _themeController.isDarkTheme.value
                          ? Colors.black
                          : Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Chip(
              label: Text(
                widget.event.selectedTag.toString(),
                style: TextStyle(
                  color: _themeController.isDarkTheme.value
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              backgroundColor: widget.color.withOpacity(0.2),
            ),
            SizedBox(width: 10),
            if (widget.event.planevent == "Yes")
              Chip(
                label: Text(
                  "PREP EVENT",
                  style: TextStyle(
                    color: _themeController.isDarkTheme.value
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                backgroundColor: widget.color.withOpacity(0.2),
              ),
          ],
        ),
        SizedBox(height: 10),
        Text(
          widget.event.title.toString().toUpperCase(),
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: _themeController.isDarkTheme.value
                ? Colors.white
                : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: _themeController.isDarkTheme.value
                ? Colors.white70
                : Colors.black54,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _themeController.isDarkTheme.value
                    ? Colors.white12
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _themeController.isDarkTheme.value
                          ? Colors.white70
                          : Colors.black54,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 20,
                      color: _themeController.isDarkTheme.value
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(
            Icons.access_time,
            color: _themeController.isDarkTheme.value
                ? Colors.white70
                : Colors.black54,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _themeController.isDarkTheme.value
                          ? Colors.white12
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start Time',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _themeController.isDarkTheme.value
                                ? Colors.white70
                                : Colors.black54,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          widget.event.startTime,
                          style: TextStyle(
                            fontSize: 20,
                            color: _themeController.isDarkTheme.value
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _themeController.isDarkTheme.value
                          ? Colors.white12
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'End Time',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _themeController.isDarkTheme.value
                                ? Colors.white70
                                : Colors.black54,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          widget.event.endTime,
                          style: TextStyle(
                            fontSize: 20,
                            color: _themeController.isDarkTheme.value
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeLeftCard() {
    DateTime startDate = DateFormat('dd-MM-yyyy').parse(widget.event.startDate);
    DateTime startTime = DateFormat('hh:mm a').parse(widget.event.startTime);
    DateTime endDate = DateFormat('dd-MM-yyyy').parse(widget.event.endDate);
    DateTime endTime = DateFormat('hh:mm a').parse(widget.event.endTime);

    DateTime startDateTime = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      startTime.hour,
      startTime.minute,
    );

    DateTime endDateTime = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      endTime.hour,
      endTime.minute,
    );

    Duration timeLeft = endDateTime.difference(startDateTime);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(
            Icons.timer,
            color: _themeController.isDarkTheme.value
                ? Colors.white70
                : Colors.black54,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _themeController.isDarkTheme.value
                    ? Colors.white12
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Duration',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _themeController.isDarkTheme.value
                          ? Colors.white70
                          : Colors.black54,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '${timeLeft.inDays}d ${timeLeft.inHours}h ${timeLeft.inMinutes % 60}m',
                    style: TextStyle(
                      fontSize: 20,
                      color: _themeController.isDarkTheme.value
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
