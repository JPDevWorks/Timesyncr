import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timesyncr/Addevent.dart';
import 'package:timesyncr/controller/newtask_controller.dart';
import 'package:timesyncr/models/NewEvent.dart';
import 'package:timesyncr/them_controler.dart';

class EditEventScreen extends StatefulWidget {
  final int eventId;
  EditEventScreen({required this.eventId});

  @override
  _EditEventScreenState createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final NewTaskController taskController = Get.find<NewTaskController>();
  final NewEventController controller = Get.put(NewEventController());
  final TextEditingController titleController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  late Future<Event> futureEvent;

  @override
  void initState() {
    super.initState();
    futureEvent = _fetchEventDetails();
  }

  Future<Event> _fetchEventDetails() async {
    Event fetchedEvent = await taskController.getEventsByIdonly(widget.eventId);
    titleController.text = fetchedEvent.title;
    locationController.text = fetchedEvent.location;
    notesController.text = fetchedEvent.notes;
    controller.selectedTag.value = fetchedEvent.selectedTag;
    return fetchedEvent;
  }

  Future<void> _updateEvent(BuildContext context, Event event) async {
    event.title = titleController.text;
    event.location = locationController.text;
    event.notes = notesController.text;
    event.selectedTag = controller.selectedTag.value;

    int result = await taskController.updateEvent(event);

    if (result > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Event updated successfully.'),
        ),
      );
      Navigator.pushNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update event.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
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
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Edit Event',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        backgroundColor: isDark ? Color(0xFF121212) : Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<Event>(
        future: futureEvent,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading event details'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Event not found'));
          } else {
            Event event = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: 'Title',
                        hintStyle: TextStyle(
                            color: isDark ? Colors.grey : Colors.black),
                        filled: true,
                        fillColor:
                            isDark ? Color(0xFF1C1C1C) : Colors.grey[300],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: locationController,
                      decoration: InputDecoration(
                        hintText: 'Location or meeting URL',
                        hintStyle: TextStyle(
                            color: isDark ? Colors.grey : Colors.black),
                        filled: true,
                        fillColor:
                            isDark ? Color(0xFF1C1C1C) : Colors.grey[300],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black),
                    ),
                    SizedBox(height: 20),
                    Text('Tags:',
                        style: TextStyle(
                            color: isDark ? Colors.white : Colors.black)),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildTag('FITNESS', Color(0xFFFFADAD)),
                        _buildTag('ME TIME', Color(0xFFFFD6A5)),
                        _buildTag('FAMILY', Color(0xFFD9EDF8)),
                        _buildTag('FRIENDS', Color(0xFFFFDffb6)),
                        _buildTag('WORK', Color(0xFFDEDAF4)),
                        _buildTag('HEALTH', Color(0xFFFFD6A5)),
                        _buildTag('TRAVEL', Color(0xFFE4F1EE)),
                        _buildTag('HOBBY', Color(0xFFFFDffb6)),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text('Notes:',
                        style: TextStyle(
                            color: isDark ? Colors.white : Colors.black)),
                    SizedBox(height: 10),
                    TextField(
                      controller: notesController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: '',
                        filled: true,
                        fillColor: isDark ? Colors.white : Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextStyle(
                          color: isDark ? Colors.black : Colors.black),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _updateEvent(context, event);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            disabledBackgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                          ),
                          child: Text('Update Event',
                              style: TextStyle(fontSize: 18)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Obx(() => GestureDetector(
          onTap: () {
            controller.selectedTag.value = label;
          },
          child: Container(
            decoration: BoxDecoration(
              color:
                  controller.selectedTag.value == label ? Colors.black : color,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              label,
              style: TextStyle(
                color: controller.selectedTag.value == label
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
        ));
  }
}
