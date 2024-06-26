import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timesyncr/controller/task_controller.dart';
import 'package:timesyncr/Home.dart';
import 'package:timesyncr/them_controler.dart';
import 'package:timesyncr/models/Event.dart';

class PlanEventScreen extends StatefulWidget {
  final String category;
  final String eventName;
  final String eventDescription;
  final String repeat;
  final int reminderBefore;
  final Color color;

  PlanEventScreen({
    required this.category,
    required this.eventName,
    required this.eventDescription,
    required this.repeat,
    required this.reminderBefore,
    required this.color,
  });

  @override
  _PlanEventScreenState createState() => _PlanEventScreenState();
}

class _PlanEventScreenState extends State<PlanEventScreen> {
  DateTime? _endDate;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  TimeOfDay? _endTime;
  int? _selectedReminder;
  String? _selectedRepeat;
  final TaskController taskController = Get.put(TaskController());
  final ThemeController _themeController = Get.find<ThemeController>();

  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd-MM-yyyy').format(now);
    String formattedTime = DateFormat('jm').format(now);

    _endDate = DateFormat('dd-MM-yyyy').parse(formattedDate);
    _selectedDate = DateFormat('dd-MM-yyyy').parse(formattedDate);
    _selectedTime =
        TimeOfDay.fromDateTime(DateFormat.jm().parse(formattedTime));
    _endTime = TimeOfDay.fromDateTime(DateFormat.jm().parse(formattedTime));
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = _themeController.isDarkTheme.value;

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Plan Event'),
        backgroundColor: isDarkTheme ? Color(0xFF0D6E6E) : Color(0xFFFF3D3D),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateCard('Start Date:', _selectedDate, (pickedDate) {
                setState(() {
                  _selectedDate = pickedDate;
                });
              }, isDarkTheme),
              SizedBox(height: 20),
              _buildDateCard('End Date:', _endDate, (pickedDate) {
                setState(() {
                  _endDate = pickedDate;
                });
              }, isDarkTheme),
              SizedBox(height: 20),
              _buildTimeCard('Start Time:', _selectedTime, (pickedTime) {
                setState(() {
                  _selectedTime = pickedTime;
                });
              }, isDarkTheme),
              SizedBox(height: 20),
              _buildTimeCard('End Time:', _endTime, (pickedTime) {
                setState(() {
                  _endTime = pickedTime;
                });
              }, isDarkTheme),
              SizedBox(height: 20),
              _buildDropdownCard(
                'Repeat:',
                _selectedRepeat,
                ['None', 'Daily', 'Weekly', 'Monthly'],
                (newValue) {
                  setState(() {
                    _selectedRepeat = newValue!;
                  });
                },
                isDarkTheme,
              ),
              SizedBox(height: 20),
              _buildDropdownCard(
                'Reminder Before:',
                _selectedReminder,
                [0, 1, 5, 10, 15, 30, 60],
                (newValue) {
                  setState(() {
                    _selectedReminder = newValue!;
                  });
                },
                isDarkTheme,
                isInt: true,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                      'Add Plan Event', context, isDarkTheme, _validate),
                  _buildActionButton('Skip', context, isDarkTheme, () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Homepage()),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateCard(String title, DateTime? date,
      Function(DateTime) onDateChanged, bool isDarkTheme) {
    return Container(
      width: double.infinity,
      child: Card(
        elevation: 4,
        color: isDarkTheme ? Colors.grey[800] : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  color: isDarkTheme ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: isDarkTheme ? Colors.white : Colors.black,
                  ),
                  SizedBox(width: 10),
                  Text(
                    date != null
                        ? DateFormat('dd-MM-yyyy').format(date)
                        : 'Select Date',
                    style: TextStyle(
                        color: isDarkTheme ? Colors.white : Colors.black),
                  ),
                ],
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: date ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null && pickedDate != date) {
                    onDateChanged(pickedDate);
                  }
                },
                child: Text('Change Date'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeCard(String title, TimeOfDay? time,
      Function(TimeOfDay) onTimeChanged, bool isDarkTheme) {
    return Container(
      width: double.infinity,
      child: Card(
        elevation: 4,
        color: isDarkTheme ? Colors.grey[800] : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  color: isDarkTheme ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: isDarkTheme ? Colors.white : Colors.black,
                  ),
                  SizedBox(width: 10),
                  Text(
                    time != null ? time.format(context) : 'Select Time',
                    style: TextStyle(
                        color: isDarkTheme ? Colors.white : Colors.black),
                  ),
                ],
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: time ?? TimeOfDay.now(),
                  );
                  if (pickedTime != null && pickedTime != time) {
                    onTimeChanged(pickedTime);
                  }
                },
                child: Text('Change Time'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownCard<T>(String title, T? currentValue, List<T> values,
      ValueChanged<T?> onChanged, bool isDarkTheme,
      {bool isInt = false}) {
    return Container(
      width: double.infinity,
      child: Card(
        elevation: 4,
        color: isDarkTheme ? Colors.grey[800] : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  color: isDarkTheme ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: 10),
              DropdownButton<T>(
                value: currentValue,
                onChanged: onChanged,
                dropdownColor: isDarkTheme ? Colors.grey[800] : Colors.white,
                style:
                    TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
                items: values.map<DropdownMenuItem<T>>((T value) {
                  return DropdownMenuItem<T>(
                    value: value,
                    child: Text(
                      isInt ? '$value min prior' : value.toString(),
                      style: TextStyle(
                          color: isDarkTheme ? Colors.white : Colors.black),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, BuildContext context, bool isDarkTheme,
      VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isDarkTheme ? Color(0xFF0D6E6E) : Color(0xFFFF3D3D),
        foregroundColor: Colors.white,
        minimumSize: Size(150, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20,
        ),
      ),
    );
  }

  void _validate() {
    if (_selectedDate != null &&
        _endDate != null &&
        _selectedTime != null &&
        _endTime != null) {
      _addTaskToDb();
      Navigator.of(context).pop();
    } else {
      Get.snackbar(
        "Required",
        "All Fields are Required!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        icon: Icon(Icons.warning_amber_rounded),
        colorText: Colors.red,
      );
    }
  }

  void _addTaskToDb() async {
    int value = await taskController.addEvent(
      Event(
        eventName: widget.eventName,
        eventDescription: widget.eventDescription,
        startDate: DateFormat('dd-MM-yyyy').format(_selectedDate!),
        endDate: DateFormat('dd-MM-yyyy').format(_endDate!),
        startTime: _selectedTime?.format(context) ?? '',
        endTime: _endTime?.format(context) ?? '',
        category: widget.category.toString(),
        repeat: _selectedRepeat ?? 'None',
        inviteGmails: 'null',
        planevent: 'Yes',
        reminderBefore: _selectedReminder ?? 0,
        isCompleted: 0,
        color: widget.color.value,
      ),
    );
    print('Event Name: ${widget.eventName}');
    print('Event Description: ${widget.eventDescription}');
    print('Start Date: ${_selectedDate?.toString() ?? ''}');
    print('End Date: ${_endDate?.toString() ?? ''}');
    print('Start Time: ${_selectedTime?.format(context) ?? ''}');
    print('End Time: ${_endTime?.format(context) ?? ''}');
    print('Repeat: ${_selectedRepeat ?? 'None'}');
    print('Reminder Before: ${_selectedReminder ?? 0}');
    print('Child event added with ID: $value');
  }
}
