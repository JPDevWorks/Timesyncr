import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timesyncr/controller/task_controller.dart';
import 'package:timesyncr/editevent.dart';
import 'package:timesyncr/models/Event.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class ViewEvent extends StatefulWidget {
  final Event event;
  final Color color;

  ViewEvent({Key? key, required this.event, required this.color})
      : super(key: key);

  @override
  _ViewEventState createState() => _ViewEventState();
}

class _ViewEventState extends State<ViewEvent> {
  final TaskController task = Get.put(TaskController());

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

                Navigator.pushNamed(context, '/home');
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
      backgroundColor: widget.color, // Background color matching the image
      appBar: AppBar(
        backgroundColor: widget.color, // Dark teal color
        elevation: 0,
        automaticallyImplyLeading: true, // Adds a default back button
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/home');
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: AnimationConfiguration.staggeredList(
            position: 0,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    SizedBox(height: 20),
                    _buildDetailRow(
                      title: 'Additional Description',
                      content: widget.event.eventDescription.toString(),
                    ),
                    SizedBox(height: 20),
                    _buildTimeLeftRow(),
                    SizedBox(height: 20),
                    _buildDetailRow(
                      title: 'StartDate',
                      content: widget.event.startDate, // Use dynamic data
                    ),
                    SizedBox(height: 20),
                    _buildDetailRow(
                      title: 'EndDate',
                      content:
                          widget.event.endDate.toString(), // Use dynamic data
                    ),
                    SizedBox(height: 20),
                    _buildDetailRow(
                      title: 'Repeat',
                      content:
                          widget.event.repeat.toString(), // Use dynamic data
                    ),
                    SizedBox(height: 20),
                    _buildDetailRow(
                      title: 'Remaind',
                      content:
                          '${widget.event.reminderBefore.toString()} minutes early', // Use dynamic data
                    ),
                    SizedBox(height: 40),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            task.updateeventdone(widget.event);
                            Navigator.pushNamed(context, '/home');
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 20),
                        ),
                        child: Text(
                          widget.event.isCompleted == 0 ? "Done" : "Completed",
                          style: TextStyle(
                            color: Colors.white, // Text color of button
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(width: 2.0),
              ),
              child: Text(
                widget.event.category.toString(), // Use dynamic category
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  color: Colors.black,
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditEvent(
                          event: widget.event,
                          selectedDate: DateFormat('dd-MM-yyyy')
                              .parse(widget.event.startDate),
                          startTime: DateFormat('hh:mm a')
                              .parse(widget.event.startTime),
                          endTime:
                              DateFormat('hh:mm a').parse(widget.event.endTime),
                          endDate: DateFormat('dd-MM-yyyy')
                              .parse(widget.event.endDate!),
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
          ],
        ),
        SizedBox(height: 10),
        Text(
          widget.event.eventName
              .toString()
              .toUpperCase(), // Use dynamic event name
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeLeftRow() {
    // Parse the start time and end time using the intl package
    DateTime startTime = DateFormat('hh:mm a').parse(widget.event.startTime);
    DateTime endTime = DateFormat('hh:mm a').parse(widget.event.endTime);

    Duration timeLeft = endTime.difference(startTime);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Duration',
              style: TextStyle(
                color: const Color.fromARGB(126, 0, 0, 0),
                fontSize: 16,
              ),
            ),
            Text(
              '${timeLeft.inHours}h ${timeLeft.inMinutes % 60}m', // Dynamic time left
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow({required String title, required String content}) {
    return Container(
      padding: EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: Colors.transparent, // Dark teal color
          width: 1,
        ),
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
              color:
                  const Color.fromARGB(255, 125, 123, 123), // Dark teal color
            ),
          ),
          SizedBox(height: 5),
          Text(
            content,
            style: TextStyle(
              fontSize: 23,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
