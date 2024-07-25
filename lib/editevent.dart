import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timesyncr/Addevent.dart';
import 'package:timesyncr/Addplanevent.dart';
import 'package:timesyncr/Home.dart';
import 'package:timesyncr/models/NewEvent.dart';
import 'package:timesyncr/controller/newtask_controller.dart';
import 'package:timesyncr/them_controler.dart';

class EditEventScreen extends StatefulWidget {
  final Event event;
  EditEventScreen({required this.event});

  @override
  _EditEventScreenState createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final NewTaskController taskController = Get.find<NewTaskController>();
  final NewEventController controller = Get.put(NewEventController());
  final ThemeController themeController = Get.put(ThemeController());
  final TextEditingController titleController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  String plan = "";
  String uniquestr = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      titleController.text = widget.event.title;
      locationController.text = widget.event.location;
      notesController.text = widget.event.notes;
      plan = widget.event.planevent.toString();
      uniquestr = widget.event.uniquestr.toString();
      controller.isAllDayEvent.value = widget.event.isAllDayEvent;
      controller.isRepetitiveEvent.value =
          widget.event.repetitiveEvent != 'None';
      controller.repetitiveEvent.value = widget.event.repetitiveEvent;
      controller.selectedTag.value = widget.event.selectedTag;
      controller.setInitialValues(
        DateFormat('dd-MM-yyyy').parse(widget.event.startDate),
        TimeOfDay(
          hour: int.parse(DateFormat('HH')
              .format(DateFormat('hh:mm a').parse(widget.event.startTime))),
          minute: int.parse(DateFormat('mm')
              .format(DateFormat('hh:mm a').parse(widget.event.startTime))),
        ),
      );
      controller.endDate.value =
          DateFormat('dd-MM-yyyy').parse(widget.event.endDate);
      controller.endTime.value = TimeOfDay(
        hour: int.parse(DateFormat('HH')
            .format(DateFormat('hh:mm a').parse(widget.event.endTime))),
        minute: int.parse(DateFormat('mm')
            .format(DateFormat('hh:mm a').parse(widget.event.endTime))),
      );
    });
  }

  Future<void> _updateEvent(BuildContext context) async {
    if (titleController.text.isEmpty ||
        locationController.text.isEmpty ||
        notesController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all the fields'),
        ),
      );
      return;
    }

    DateTime startDateTime;
    DateTime endDateTime;

    if (controller.isAllDayEvent.value) {
      startDateTime = DateTime(
        controller.startDate.value.year,
        controller.startDate.value.month,
        controller.startDate.value.day,
        0,
        0,
      );
      endDateTime = DateTime(
        controller.endDate.value.year,
        controller.endDate.value.month,
        controller.endDate.value.day,
        23,
        59,
      ).add(Duration(days: 1));
    } else {
      startDateTime = DateTime(
        controller.startDate.value.year,
        controller.startDate.value.month,
        controller.startDate.value.day,
        controller.startTime.value.hour,
        controller.startTime.value.minute,
      );
      endDateTime = DateTime(
        controller.endDate.value.year,
        controller.endDate.value.month,
        controller.endDate.value.day,
        controller.endTime.value.hour,
        controller.endTime.value.minute,
      );
    }

    DateTime now = DateTime.now();

    int numberOfDays = endDateTime.difference(startDateTime).inDays;

    if (controller.isAllDayEvent.value ||
        (startDateTime.isAfter(now) && endDateTime.isAfter(startDateTime))) {
      Event updatedEvent = Event(
        title: titleController.text,
        location: locationController.text,
        startDate: DateFormat('dd-MM-yyyy').format(startDateTime),
        startTime: DateFormat('hh:mm a').format(startDateTime),
        endDate: DateFormat('dd-MM-yyyy').format(endDateTime),
        endTime: DateFormat('hh:mm a').format(endDateTime),
        isAllDayEvent: controller.isAllDayEvent.value,
        repetitiveEvent: controller.repetitiveEvent.value,
        selectedTag: controller.selectedTag.value,
        notes: notesController.text,
        color: getTagColor(controller.selectedTag.value).value,
        planevent: plan,
        isCompleted: 0,
        numberOfDays: numberOfDays,
        uniquestr: uniquestr,
      );

      _showPrepEventDialog(context, updatedEvent);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Start and end times must be in the future.'),
        ),
      );
    }
  }

  void _showPrepEventDialog(BuildContext context, Event updatedEvent) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isDark = themeController.isDarkTheme.value;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          backgroundColor: isDark ? Color(0xFF1C1C1C) : Colors.white,
          title: Text(
            'Create Prep Event',
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          content: Text(
            'Would you like to create a Prep Event?',
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'No',
                style: TextStyle(color: isDark ? Colors.teal : Colors.teal),
              ),
              onPressed: () async {
                int val = await taskController.updateEvent(updatedEvent);
                if (val > 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Event updated successfully.'),
                    ),
                  );
                  Navigator.pushReplacementNamed(context, '/home');
                }
              },
            ),
            TextButton(
              child: Text(
                'Yes',
                style: TextStyle(color: isDark ? Colors.teal : Colors.teal),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddPlanEventScreen(
                      parentEvent: updatedEvent,
                      fun: "edit",
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Color getTagColor(String tag) {
    switch (tag) {
      case 'Others':
        return Color(0xFFDEDAF4);
      case 'FITNESS':
        return Color(0xFFFFADAD);
      case 'ME TIME':
        return Color(0xFFFFD6A5);
      case 'FAMILY':
        return Color(0xFFD9EDF8);
      case 'FRIENDS':
        return Color(0xFFFFDffb6);
      case 'WORK':
        return Color(0xFFFFADAD);
      case 'HEALTH':
        return Color(0xFFFFD6A5);
      case 'TRAVEL':
        return Color(0xFFDEDAF4);
      case 'HOBBY':
        return Color(0xFFFFDffb6);
      default:
        return Colors.grey;
    }
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
            'Edit event',
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          backgroundColor: isDark ? Color(0xFF121212) : Colors.white,
          elevation: 0,
        ),
        body: Container(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: 'Title',
                      hintStyle:
                          TextStyle(color: isDark ? Colors.grey : Colors.black),
                      filled: true,
                      fillColor: isDark ? Color(0xFF1C1C1C) : Colors.grey[300],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style:
                        TextStyle(color: isDark ? Colors.white : Colors.black),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: locationController,
                    decoration: InputDecoration(
                      hintText: 'Location or meeting URL',
                      hintStyle:
                          TextStyle(color: isDark ? Colors.grey : Colors.black),
                      filled: true,
                      fillColor: isDark ? Color(0xFF1C1C1C) : Colors.grey[300],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style:
                        TextStyle(color: isDark ? Colors.white : Colors.black),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('All day event',
                          style: TextStyle(
                              color: isDark ? Colors.white : Colors.black)),
                      Obx(() => Switch(
                            value: controller.isAllDayEvent.value,
                            onChanged: (value) {
                              controller.isAllDayEvent.value = value;
                              if (!value) {
                                controller.repetitiveEvent.value = 'None';
                                controller.selectedDays.value = 1;
                              }
                            },
                            activeColor: Colors.teal,
                          )),
                    ],
                  ),
                  Obx(() {
                    if (controller.isAllDayEvent.value) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Text('Start Date:',
                                  style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black)),
                              SizedBox(width: 150),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _selectDate(context, true),
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 5),
                                      filled: true,
                                      fillColor: isDark
                                          ? Color(0xFF1C1C1C)
                                          : Colors.grey[200],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none,
                                      ),
                                      suffixIcon: Icon(Icons.arrow_drop_down,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                    child: Text(
                                      DateFormat('MMM dd')
                                          .format(controller.startDate.value),
                                      style: TextStyle(
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black),
                                    ),
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
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black)),
                              SizedBox(
                                width: 160,
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _selectDate(context, false),
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 5),
                                      filled: true,
                                      fillColor: isDark
                                          ? Color(0xFF1C1C1C)
                                          : Colors.grey[200],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none,
                                      ),
                                      suffixIcon: Icon(Icons.arrow_drop_down,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                    child: Text(
                                      DateFormat('MMM dd')
                                          .format(controller.endDate.value),
                                      style: TextStyle(
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      );
                    }
                    return SizedBox.shrink();
                  }),
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
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black)),
                              SizedBox(width: 80),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _selectDate(context, true),
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 5),
                                      filled: true,
                                      fillColor: isDark
                                          ? Color(0xFF1C1C1C)
                                          : Colors.grey[200],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none,
                                      ),
                                      suffixIcon: Icon(Icons.arrow_drop_down,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                    child: Text(
                                      DateFormat('MMM dd')
                                          .format(controller.startDate.value),
                                      style: TextStyle(
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black),
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
                                      fillColor: isDark
                                          ? Color(0xFF1C1C1C)
                                          : Colors.grey[200],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none,
                                      ),
                                      suffixIcon: Icon(Icons.arrow_drop_down,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                    child: Text(
                                      controller.startTime.value
                                          .format(context),
                                      style: TextStyle(
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black),
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
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black)),
                              SizedBox(width: 90),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _selectDate(context, false),
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 5),
                                      filled: true,
                                      fillColor: isDark
                                          ? Color(0xFF1C1C1C)
                                          : Colors.grey[200],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none,
                                      ),
                                      suffixIcon: Icon(Icons.arrow_drop_down,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                    child: Text(
                                      DateFormat('MMM dd')
                                          .format(controller.endDate.value),
                                      style: TextStyle(
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black),
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
                                      fillColor: isDark
                                          ? Color(0xFF1C1C1C)
                                          : Colors.grey[200],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none,
                                      ),
                                      suffixIcon: Icon(Icons.arrow_drop_down,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                    child: Text(
                                      controller.endTime.value.format(context),
                                      style: TextStyle(
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black),
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
                  Obx(() {
                    if (!controller.isAllDayEvent.value) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Repetitive event',
                              style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black)),
                          Obx(() => Switch(
                                value: controller.isRepetitiveEvent.value,
                                onChanged: (value) {
                                  controller.isRepetitiveEvent.value = value;
                                },
                                activeColor: Colors.teal,
                              )),
                        ],
                      );
                    }
                    return SizedBox.shrink();
                  }),
                  Obx(() {
                    if (controller.isRepetitiveEvent.value &&
                        !controller.isAllDayEvent.value) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          Text('Repetition:',
                              style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black)),
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
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black)),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildTag('Others', Color(0xFFDEDAF4)),
                      _buildTag('FITNESS', Color(0xFFFFADAD)),
                      _buildTag('ME TIME', Color(0xFFFFD6A5)),
                      _buildTag('FAMILY', Color(0xFFD9EDF8)),
                      _buildTag('FRIENDS', Color(0xFFFFDffb6)),
                      _buildTag('WORK', Color(0xFFFFADAD)),
                      _buildTag('HEALTH', Color(0xFFFFD6A5)),
                      _buildTag('TRAVEL', Color(0xFFDEDAF4)),
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
                    style:
                        TextStyle(color: isDark ? Colors.black : Colors.black),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => _updateEvent(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? Colors.white : Colors.black,
                          shadowColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                        ),
                        child: Text('Update Event',
                            style: TextStyle(
                              fontSize: 18,
                              color: isDark ? Color(0xFF1C1C1C) : Colors.white,
                            )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
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
        );
      } else {
        controller.endDate.value = DateTime(
          picked.year,
          picked.month,
          picked.day,
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
