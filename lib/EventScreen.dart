import 'dart:ffi';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:timesyncr/Home.dart';
import 'package:timesyncr/controller/task_controller.dart';

import 'package:timesyncr/input.dart'; // Ensure this package contains the Myinputfield widget
import 'package:intl/intl.dart'; // Importing the intl package for date formatting
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timesyncr/models/Event.dart';
import 'package:timesyncr/planevent.dart';
import 'package:timesyncr/them_controler.dart';

class EventScreen extends StatefulWidget {
  DateTime selectedDate;
  DateTime startTime;
  DateTime? endTime;
  int? remaind;

  EventScreen({
    super.key,
    required this.startTime,
    required this.selectedDate,
    this.endTime,
    this.remaind,
  });

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  int rem = 0;
  DateTime end = DateTime.now();
  List<int> remaindList = [0, 5, 10, 15, 30, 60];
  String repeat = "None";
  List<String> repeatList = ["None", "Daily", "Weekly", "Monthly"];
  String category = "Others";
  List<String> categorylist = ["Others", "School", "Collage"];
  final TaskController taskController = Get.put(TaskController());
  final _formKey = GlobalKey<FormState>();
  final _eventNameController = TextEditingController();
  final _eventDescriptionController = TextEditingController();
  final _emailController = TextEditingController();
  var _categoryController = TextEditingController();
  var _startDateController = TextEditingController();
  var _endDateController = TextEditingController();
  var _startTimeController = TextEditingController();
  var _endTimeController = TextEditingController();
  var _reminderController = TextEditingController();
  var _repeatController = TextEditingController();
  final ThemeController _themeController = Get.find<ThemeController>();

  Color? _selectedColor;

  @override
  void initState() {
    super.initState();

    _reminderController.text = rem.toString();
    _repeatController.text = repeat;
    _startDateController.text =
        DateFormat('dd-MM-yyyy').format(widget.selectedDate);
    _endDateController.text = DateFormat('dd-MM-yyyy').format(end);
    _startTimeController.text =
        DateFormat('hh:mm a').format(widget.startTime).toString();
    _endTimeController.text =
        DateFormat('hh:mm a').format(widget.startTime).toString();
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _eventDescriptionController.dispose();
    _emailController.dispose();
    _categoryController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _reminderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = MediaQuery.of(context).platformBrightness == Brightness.dark
        ? 'DarkTheme'
        : 'LightTheme';
    final isDarkTheme = _themeController.isDarkTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Event'),
        backgroundColor:
            isDarkTheme.value ? Color(0xFF0D6E6E) : Color(0xFFFF3D3D),
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Myinputfield(
                titlee: "Event",
                hint: "Enter name of Event",
                controller: _eventNameController,
              ),
              Myinputfield(
                titlee: "Description",
                hint: "Event Description.",
                controller: _eventDescriptionController,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: Myinputfield(
                      titlee: "Start Date",
                      hint:
                          DateFormat('dd-MM-yyyy').format(widget.selectedDate),
                      controller: _startDateController,
                      widget: IconButton(
                        onPressed: () {
                          _getDateFromUser(isend: false);
                        },
                        icon: Icon(
                          Icons.calendar_month_outlined,
                          color: isDarkTheme.value
                              ? Color(0xFF0D6E6E)
                              : Color(0xFFFF3D3D),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: Myinputfield(
                      titlee: "End Date",
                      hint: DateFormat('dd-MM-yyyy').format(end),
                      controller: _endDateController,
                      widget: IconButton(
                        onPressed: () {
                          _getDateFromUser(isend: true);
                        },
                        icon: Icon(
                          Icons.calendar_month_outlined,
                          color: isDarkTheme.value
                              ? Color(0xFF0D6E6E)
                              : Color(0xFFFF3D3D),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: Myinputfield(
                      titlee: "Start Time",
                      hint: DateFormat('hh:mm a').format(widget.startTime),
                      controller: _startTimeController,
                      widget: IconButton(
                        onPressed: () {
                          _getTimeFromUser(isStartTime: true);
                        },
                        icon: Icon(
                          Icons.access_time_rounded,
                          color: isDarkTheme.value
                              ? Color(0xFF0D6E6E)
                              : Color(0xFFFF3D3D),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: Myinputfield(
                      titlee: "End Time",
                      hint: DateFormat('hh:mm a').format(widget.startTime),
                      controller: _endTimeController,
                      widget: IconButton(
                        onPressed: () {
                          _getEndTimeFromUser(isEndTime: true);
                        },
                        icon: Icon(
                          Icons.access_time_rounded,
                          color: isDarkTheme.value
                              ? Color(0xFF0D6E6E)
                              : Color(0xFFFF3D3D),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Myinputfield(
              //   titlee: "Category",
              //   hint: "$category",
              //   widget: DropdownButton(
              //     icon: Icon(
              //       Icons.arrow_drop_down,
              //       color: isDarkTheme.value ? Colors.white : Colors.black,
              //     ),
              //     iconSize: 32,
              //     elevation: 4,
              //     style: GoogleFonts.lato(
              //       fontSize: 16,
              //       fontWeight: FontWeight.w600,
              //       color: isDarkTheme.value ? Colors.white : Colors.black,
              //     ),
              //     underline: Container(
              //       height: 0,
              //     ),
              //     items: categorylist
              //         .map<DropdownMenuItem<String>>((String? value) {
              //       return DropdownMenuItem<String>(
              //         value: value, // Added value property
              //         child: Text(
              //           value!,
              //           style: TextStyle(
              //             color:
              //                 isDarkTheme.value ? Colors.white : Colors.black,
              //           ),
              //         ),
              //       );
              //     }).toList(),
              //     onChanged: (String? newValue) {
              //       setState(() {
              //         category = newValue!;
              //       });
              //     },
              //   ),
              // ),
              Myinputfield(
                titlee: "Category",
                hint: "[School,Collage,Home,Market...]",
                controller: _categoryController,
              ),
              Myinputfield(
                titlee: "Reminder",
                hint: "$rem min prior",
                widget: DropdownButton(
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: isDarkTheme.value ? Colors.white : Colors.black,
                  ),
                  iconSize: 32,
                  elevation: 4,
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkTheme.value ? Colors.white : Colors.black,
                  ),
                  underline: Container(
                    height: 0,
                  ),
                  items: remaindList.map<DropdownMenuItem<String>>((int value) {
                    return DropdownMenuItem<String>(
                      value: value.toString(), // Added value property
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      rem = int.parse(newValue!);
                    });
                  },
                ),
              ),
              Myinputfield(
                titlee: "Repeat",
                hint: "$repeat",
                widget: DropdownButton(
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: isDarkTheme.value ? Colors.white : Colors.black,
                  ),
                  iconSize: 32,
                  elevation: 4,
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  underline: Container(
                    height: 0,
                  ),
                  items:
                      repeatList.map<DropdownMenuItem<String>>((String? value) {
                    return DropdownMenuItem<String>(
                      value: value, // Added value property
                      child: Text(
                        value!,
                        style: TextStyle(
                          color:
                              isDarkTheme.value ? Colors.white : Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      repeat = newValue!;
                    });
                  },
                ),
              ),
              Myinputfield(
                titlee: "Invite Email",
                hint: "Enter Email",
                controller: _emailController,
              ),
              SizedBox(height: 20),
              // Color selection buttons
              Wrap(
                spacing: 5,
                children: _buildColorSelectionButtons(),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _showConfirmationDialog(),
                    child: Container(
                      width: 170,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: isDarkTheme.value
                            ? Color(0xFF0D6E6E)
                            : Color(0xFFFF3D3D),
                      ),
                      child: Center(
                        child: Text(
                          "Add Prep",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  GestureDetector(
                    onTap: _validate,
                    child: Container(
                      width: 150,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: isDarkTheme.value
                            ? Color(0xFF0D6E6E)
                            : Color(0xFFFF3D3D),
                      ),
                      child: Center(
                        child: Text(
                          "Add Event",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildColorSelectionButtons() {
    // Define your list of colors here
    List<Color> predefinedColors = [
      Colors.red,
      Colors.black,
      Colors.lightBlue,
      const Color.fromARGB(255, 7, 81, 141),
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.yellow,
    ];

    return predefinedColors.map((color) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _selectedColor = color;
          });
        },
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color:
                  _selectedColor == color ? Colors.black : Colors.transparent,
              width: 4,
            ),
          ),
        ),
      );
    }).toList();
  }

  _validate() async {
    DateTime parsedStartDate =
        DateFormat('hh:mm a').parse(_startTimeController.text);
    TimeOfDay? taken = TimeOfDay.fromDateTime(parsedStartDate);

    TimeOfDay now = TimeOfDay.now();

    if (_eventNameController.text.isNotEmpty &&
        _eventDescriptionController.text.isNotEmpty &&
        _emailController.text.isNotEmpty) {
      if (_isBefore(taken, now)) {
        print("yes");
        int value = await _addTaskToDb();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Homepage()),
        );
      } else {
        print(taken);
        print(now);
        print("Event time must be After current time.");
        Get.snackbar(
          "Invalid Time",
          "Event time must be before current time.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          icon: Icon(Icons.warning_amber_rounded),
          colorText: Colors.red,
        );
      }
    } else if (_eventNameController.text.isEmpty ||
        _eventDescriptionController.text.isEmpty ||
        _emailController.text.isEmpty) {
      print("No");
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

  bool _isBefore(TimeOfDay time1, TimeOfDay time2) {
    print(time1);
    print(time2);
    return time1.hour > time2.hour ||
        (time1.hour == time2.hour && time1.minute > time2.minute);
  }

  Future<int> _addTaskToDb() async {
    final String eventName = _eventNameController.text;
    final String eventDescription = _eventDescriptionController.text;
    final String startDate = _startDateController.text;
    final String endDate = _endDateController.text;
    final String startTime = _startTimeController.text;

    final String endTime = _endTimeController.text;
    final String category =
        this.category; // Assuming `this.category` is defined elsewhere
    final String repeat =
        this.repeat; // Assuming `this.repeat` is defined elsewhere
    final String inviteGmails = _emailController.text;
    final int reminderBefore =
        this.rem; // Assuming `this.rem` is defined elsewhere
    final int isCompleted = 0;
    final Color color = _selectedColor!;

    // Printing each field for verification
    print("Event Name: $eventName");
    print("Event Description: $eventDescription");
    print("Start Date: $startDate");
    print("Start Date: $endDate");
    print("Start Time: $startTime");
    print("End Time: $endTime");
    print("Category: $category");
    print("Repeat: $repeat");
    print("Invite Gmails: $inviteGmails");
    print("Reminder Before: $reminderBefore");
    print("Is Completed: $isCompleted");
    print("Color :${color.value}");

    int value = await taskController.addEvent(
      Event(
        eventName: eventName,
        eventDescription: eventDescription,
        startDate: startDate,
        endDate: endDate,
        startTime: startTime,
        endTime: endTime,
        category: category,
        repeat: repeat,
        planevent: 'No',
        inviteGmails: inviteGmails,
        reminderBefore: reminderBefore,
        isCompleted: isCompleted,
        color: _selectedColor!.value,
      ),
    );

    return value;
  }

  void _showConfirmationDialog() {
    final String eventName = _eventNameController.text;
    final String eventDescription = _eventDescriptionController.text;
    final String category = this.category;
    final String inviteGmails = _emailController.text;

    if (_selectedColor == null) {
      Get.snackbar(
        "Required",
        "Please select Color also!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        icon: Icon(Icons.warning_amber_rounded),
        colorText: Colors.red,
      );
    } else {
      if (eventName.isNotEmpty &&
          eventDescription.isNotEmpty &&
          category.isNotEmpty &&
          inviteGmails.isNotEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              title: Row(
                children: [
                  Icon(Icons.event, color: Colors.blue),
                  SizedBox(width: 10),
                  Text("Add Prep"),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Do you want to add Prep to this event?",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "This will create a new Prep event linked to the Main event. You can always Edit the details later.",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                    textStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("No"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlanEventScreen(
                          eventName: _eventNameController.text,
                          eventDescription: _eventDescriptionController.text,
                          category: category,
                          repeat: this.repeat,
                          reminderBefore: this.rem,
                          color: _selectedColor!,
                        ),
                      ),
                    );
                  },
                  child: Text("Yes"),
                ),
              ],
            );
          },
        );
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
  }

  void _getDateFromUser({required bool isend}) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );
    if (isend == true) {
      if (pickedDate != null) {
        setState(() {
          end = pickedDate;
          _endDateController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
        });
      }
    } else {
      if (pickedDate != null) {
        setState(() {
          widget.selectedDate = pickedDate;
          _startDateController.text =
              DateFormat('dd-MM-yyyy').format(pickedDate);
        });
      }
    }
  }

  void _getTimeFromUser({required bool isStartTime}) async {
    TimeOfDay? pickedTime = await showTimePicker(
      initialEntryMode: TimePickerEntryMode.dial,
      context: context,
      initialTime: TimeOfDay.fromDateTime(widget.startTime),
    );

    if (pickedTime != null) {
      final now = DateTime.now();
      final pickedDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      final pickedDateTimeadd = DateTime(
        now.year,
        now.month,
        now.day,
        pickedTime.hour,
        pickedTime.minute + 5,
      );
      if (pickedDateTime.isAfter(now)) {
        setState(() {
          if (isStartTime) {
            widget.endTime = pickedDateTime;
            _endTimeController.text =
                DateFormat('hh:mm a').format(pickedDateTimeadd);
            _startTimeController.text =
                DateFormat('hh:mm a').format(pickedDateTime);
          } else {
            // Update end time logic if required
          }
        });
      } else {
        Get.snackbar(
          "Required",
          "Time must be in Future",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          icon: Icon(Icons.warning_amber_rounded),
          colorText: Colors.red,
        );
      }
    }
  }

  void _getEndTimeFromUser({required bool isEndTime}) async {
    TimeOfDay? pickedTime = await showTimePicker(
      initialEntryMode: TimePickerEntryMode.dial,
      context: context,
      initialTime: TimeOfDay.fromDateTime(widget.startTime),
    );

    if (pickedTime != null) {
      final now = DateTime.now();
      final pickedDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      setState(() {
        if (isEndTime) {
          widget.endTime = pickedDateTime;
          _endTimeController.text =
              DateFormat('hh:mm a').format(pickedDateTime);
        } else {
          // Update end time logic if required
        }
      });
    }
  }
}
