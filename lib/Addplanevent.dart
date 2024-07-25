import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timesyncr/Addevent.dart';
import 'package:timesyncr/controller/newtask_controller.dart';
import 'package:timesyncr/models/NewEvent.dart';
import 'package:timesyncr/them_controler.dart';

class AddPlanEventScreen extends StatefulWidget {
  final Event parentEvent;
  final String fun;
  AddPlanEventScreen({required this.parentEvent, required this.fun});

  @override
  _AddPlanEventScreenState createState() => _AddPlanEventScreenState();
}

class _AddPlanEventScreenState extends State<AddPlanEventScreen> {
  final NewTaskController taskController = Get.find<NewTaskController>();
  final NewEventController controller = Get.put(NewEventController());
  late Event parentevent;
  late Event futureEvent;

  @override
  void initState() {
    super.initState();
    parentevent = widget.parentEvent;
    futureEvent = widget.parentEvent;
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

  Future<void> _addPlanEvent(BuildContext context, Event event) async {
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
      );
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

    DateTime eventStartDateTime = DateFormat('dd-MM-yyyy hh:mm a')
        .parse('${event.startDate} ${event.startTime}');
    DateTime eventEndDateTime = DateFormat('dd-MM-yyyy hh:mm a')
        .parse('${event.endDate} ${event.endTime}');

    // Ensure endDateTime is after startDateTime
    if (endDateTime.isBefore(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('End time must be after start time.'),
        ),
      );
      return;
    }

    if (!parentevent.isAllDayEvent) {
      // Ensure startDateTime and endDateTime are before the main event times
      if (startDateTime.isAfter(eventStartDateTime) ||
          endDateTime.isAfter(eventStartDateTime)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Plan event times must be before the main event times.'),
          ),
        );
        return;
      }
    }

    int numberOfDays = endDateTime.difference(startDateTime).inDays;

    futureEvent = Event(
      title: futureEvent.title,
      location: futureEvent.location,
      notes: futureEvent.notes,
      startDate: DateFormat('dd-MM-yyyy').format(startDateTime),
      startTime: DateFormat('hh:mm a').format(startDateTime),
      endDate: DateFormat('dd-MM-yyyy').format(endDateTime),
      endTime: DateFormat('hh:mm a').format(endDateTime),
      planevent: "Yes",
      uniquestr: futureEvent.uniquestr,
      id: null,
      isAllDayEvent: controller.isAllDayEvent.value,
      repetitiveEvent: controller.repetitiveEvent.value,
      selectedTag: controller.selectedTag.value,
      color: getTagColor(controller.selectedTag.value).value,
      isCompleted: 0,
      numberOfDays: numberOfDays,
    );

    if (widget.fun == "add") {
      await taskController.addEvent(parentevent);
      await taskController.addEvent(futureEvent);
    } else {
      await taskController.updateEvent(parentevent);
      await taskController.addEvent(futureEvent);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Events added successfully.'),
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
            Navigator.pushNamed(context, '/home');
          },
        ),
        title: Text(
          'Prep Event',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        backgroundColor: isDark ? Color(0xFF121212) : Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUneditableField('Title', futureEvent.title, isDark),
              SizedBox(height: 10),
              _buildUneditableField(
                  'Location or meeting URL', futureEvent.location, isDark),
              SizedBox(height: 20),
              _buildEditableFields(isDark),
              SizedBox(height: 20),
              _buildUneditableField('Notes', futureEvent.notes, isDark),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _addPlanEvent(context, futureEvent);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.white : Colors.black,
                      disabledBackgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    child: Center(
                      child: Text('Add Prep Event',
                          style: TextStyle(
                              fontSize: 18,
                              color: isDark ? Colors.black : Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
        Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('All-Day-Repeat',
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black)),
                  Obx(() => Switch(
                        value: controller.isAllDayEvent.value,
                        onChanged: (value) {
                          controller.isAllDayEvent.value = value;
                          if (!value) {
                            controller.repetitiveEvent.value = 'None';
                          }
                        },
                        activeColor: Colors.teal,
                      )),
                ],
              ),
              if (controller.isAllDayEvent.value)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                                    color:
                                        isDark ? Colors.white : Colors.black),
                              ),
                              child: Text(
                                DateFormat('MMM dd')
                                    .format(controller.startDate.value),
                                style: TextStyle(
                                    color:
                                        isDark ? Colors.white : Colors.black),
                              ),
                            ),
                          ),
                        ),
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
                                    color:
                                        isDark ? Colors.white : Colors.black),
                              ),
                              child: Text(
                                DateFormat('MMM dd')
                                    .format(controller.endDate.value),
                                style: TextStyle(
                                    color:
                                        isDark ? Colors.white : Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              else
                Column(
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
                                fillColor: isDark
                                    ? Color(0xFF1C1C1C)
                                    : Colors.grey[200],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                suffixIcon: Icon(Icons.arrow_drop_down,
                                    color:
                                        isDark ? Colors.white : Colors.black),
                              ),
                              child: Text(
                                DateFormat('MMM dd')
                                    .format(controller.startDate.value),
                                style: TextStyle(
                                    color:
                                        isDark ? Colors.white : Colors.black),
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
                                    color:
                                        isDark ? Colors.white : Colors.black),
                              ),
                              child: Text(
                                controller.startTime.value.format(context),
                                style: TextStyle(
                                    color:
                                        isDark ? Colors.white : Colors.black),
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
                                fillColor: isDark
                                    ? Color(0xFF1C1C1C)
                                    : Colors.grey[200],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                suffixIcon: Icon(Icons.arrow_drop_down,
                                    color:
                                        isDark ? Colors.white : Colors.black),
                              ),
                              child: Text(
                                DateFormat('MMM dd')
                                    .format(controller.endDate.value),
                                style: TextStyle(
                                    color:
                                        isDark ? Colors.white : Colors.black),
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
                                    color:
                                        isDark ? Colors.white : Colors.black),
                              ),
                              child: Text(
                                controller.endTime.value.format(context),
                                style: TextStyle(
                                    color:
                                        isDark ? Colors.white : Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              SizedBox(height: 20),
              if (!controller.isAllDayEvent.value)
                Row(
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
                ),
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
                  style:
                      TextStyle(color: isDark ? Colors.white : Colors.black)),
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
        }),
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
