import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timesyncr/Addevent.dart';
import 'package:timesyncr/controller/newtask_controller.dart';
import 'package:timesyncr/models/NewEvent.dart';
import 'package:timesyncr/them_controler.dart';

class AddPlanEventScreen extends StatefulWidget {
  final int eventId;
  AddPlanEventScreen({required this.eventId});

  @override
  _AddPlanEventScreenState createState() => _AddPlanEventScreenState();
}

class _AddPlanEventScreenState extends State<AddPlanEventScreen> {
  final NewTaskController taskController = Get.find<NewTaskController>();
  final NewEventController controller = Get.put(NewEventController());
  late Future<Event> futureEvent;

  @override
  void initState() {
    super.initState();
    futureEvent = _fetchEventDetails();
  }

  Future<Event> _fetchEventDetails() async {
    Event fetchedEvent = await taskController.getEventsByIdonly(widget.eventId);
    controller.setInitialValues(
      DateFormat('dd-MM-yyyy').parse(fetchedEvent.startDate),
      TimeOfDay.fromDateTime(
          DateFormat('hh:mm a').parse(fetchedEvent.startTime)),
    );
    return fetchedEvent;
  }

  Future<void> _addPlanEvent(BuildContext context, Event event) async {
    DateTime startDateTime = DateTime(
      controller.startDate.value.year,
      controller.startDate.value.month,
      controller.startDate.value.day,
      controller.startTime.value.hour,
      controller.startTime.value.minute,
    );

    DateTime endDateTime = DateTime(
      controller.endDate.value.year,
      controller.endDate.value.month,
      controller.endDate.value.day,
      controller.endTime.value.hour,
      controller.endTime.value.minute,
    );

    DateTime eventStartDateTime = DateFormat('dd-MM-yyyy hh:mm a')
        .parse('${event.startDate} ${event.startTime}');
    DateTime eventEndDateTime = DateFormat('dd-MM-yyyy hh:mm a')
        .parse('${event.endDate} ${event.endTime}');

    if (endDateTime.isBefore(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('End time must be after start time.'),
        ),
      );
      return;
    }

    if ((startDateTime.isBefore(eventStartDateTime) &&
            endDateTime.isAfter(eventStartDateTime)) ||
        (startDateTime.isBefore(eventEndDateTime) &&
            endDateTime.isAfter(eventEndDateTime))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Event times overlap with existing event.'),
        ),
      );
      return;
    }

    event.startDate = DateFormat('dd-MM-yyyy').format(startDateTime);
    event.startTime = DateFormat('hh:mm a').format(startDateTime);
    event.endDate = DateFormat('dd-MM-yyyy').format(endDateTime);
    event.endTime = DateFormat('hh:mm a').format(endDateTime);
    event.planevent = "Yes";
    event.id = null;
    await taskController.addEvent(event);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Prep Event added successfully.'),
      ),
    );

    Navigator.pushNamed(context, '/home');
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
          'Prep Event',
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
                    _buildUneditableField('Title', event.title, isDark),
                    SizedBox(height: 10),
                    _buildUneditableField(
                        'Location or meeting URL', event.location, isDark),
                    SizedBox(height: 20),
                    _buildEditableFields(isDark),
                    SizedBox(height: 20),
                    _buildUneditableField('Notes', event.notes, isDark),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _addPlanEvent(context, event);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isDark ? Colors.white : Colors.black,
                            disabledBackgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                          ),
                          child: Center(
                            child: Text('Add Prep Event',
                                style: TextStyle(
                                    fontSize: 18,
                                    color:
                                        isDark ? Colors.black : Colors.white)),
                          ),
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

  Widget _buildUneditableField(String label, String value, bool isDark) {
    return TextField(
      enabled: false,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: isDark ? Color(0xFF1C1C1C) : Colors.grey[300],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
      ),
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      controller: TextEditingController(text: value),
    );
  }

  Widget _buildEditableFields(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     Text('All day event',
        //         style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        //     Obx(() => Switch(
        //           value: controller.isAllDayEvent.value,
        //           onChanged: (value) {
        //             controller.isAllDayEvent.value = value;
        //           },
        //           activeColor: Colors.teal,
        //         )),
        //   ],
        // ),
        Obx(() {
          if (!controller.isAllDayEvent.value) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Row(
                  children: [
                    Text('Start',
                        style: TextStyle(
                            color: isDark ? Colors.white : Colors.black)),
                    SizedBox(width: 80),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDate(context, true),
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
                            DateFormat('MMM dd')
                                .format(controller.startDate.value),
                            style: TextStyle(
                                color: isDark ? Colors.white : Colors.black),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectTime(context, true),
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
                            controller.startTime.value.format(context),
                            style: TextStyle(
                                color: isDark ? Colors.white : Colors.black),
                          ),
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
                      child: GestureDetector(
                        onTap: () => _selectDate(context, false),
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
                            DateFormat('MMM dd')
                                .format(controller.endDate.value),
                            style: TextStyle(
                                color: isDark ? Colors.white : Colors.black),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectTime(context, false),
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
                            controller.endTime.value.format(context),
                            style: TextStyle(
                                color: isDark ? Colors.white : Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }
          return SizedBox.shrink();
        }),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Repetitive event',
                style: TextStyle(color: isDark ? Colors.white : Colors.black)),
            Obx(() => Switch(
                  value: controller.isRepetitiveEvent.value,
                  onChanged: (value) {
                    controller.isRepetitiveEvent.value = value;
                  },
                  activeColor: Colors.teal,
                )),
          ],
        ),
        Obx(() {
          if (controller.isRepetitiveEvent.value) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Text('Repetition:',
                    style:
                        TextStyle(color: isDark ? Colors.white : Colors.black)),
                SizedBox(height: 10),
                Row(
                  children: [
                    _buildRepetitionOption('Daily'),
                    SizedBox(width: 10),
                    _buildRepetitionOption('Weekly'),
                    SizedBox(width: 10),
                    _buildRepetitionOption('Monthly'),
                  ],
                ),
              ],
            );
          }
          return SizedBox.shrink();
        }),
        SizedBox(height: 20),
        Text('Tags:',
            style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _buildTag('Others', Color(0xFFD9EDF8)),
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
      ],
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

  Widget _buildRepetitionOption(String label) {
    return Obx(() => GestureDetector(
          onTap: () {
            controller.repetitiveEvent.value = label;
          },
          child: Chip(
            label: Text(
              label,
              style: TextStyle(
                  color: controller.repetitiveEvent.value == label
                      ? Colors.white
                      : Colors.black),
            ),
            backgroundColor: controller.repetitiveEvent.value == label
                ? Colors.black
                : Colors.white,
          ),
        ));
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime initialDate =
        isStartDate ? controller.startDate.value : controller.endDate.value;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != initialDate) {
      if (isStartDate) {
        controller.startDate.value = DateTime(
          picked.year,
          picked.month,
          picked.day,
          controller.startTime.value.hour,
          controller.startTime.value.minute,
        );
      } else {
        controller.endDate.value = DateTime(
          picked.year,
          picked.month,
          picked.day,
          controller.endTime.value.hour,
          controller.endTime.value.minute,
        );
      }
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    TimeOfDay initialTime =
        isStartTime ? controller.startTime.value : controller.endTime.value;
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null && picked != initialTime) {
      if (isStartTime) {
        controller.startTime.value = picked;
        controller.startDate.value = DateTime(
          controller.startDate.value.year,
          controller.startDate.value.month,
          controller.startDate.value.day,
          picked.hour,
          picked.minute,
        );
      } else {
        controller.endTime.value = picked;
        controller.endDate.value = DateTime(
          controller.endDate.value.year,
          controller.endDate.value.month,
          controller.endDate.value.day,
          picked.hour,
          picked.minute,
        );
      }
    }
  }
}
