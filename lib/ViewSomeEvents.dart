import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:timesyncr/Home.dart';
import 'package:timesyncr/ViewEvent.dart';
import 'package:timesyncr/controller/newtask_controller.dart';
import 'package:timesyncr/models/NewEvent.dart';
import 'package:timesyncr/them_controler.dart';

class ViewSomeEvents extends StatefulWidget {
  const ViewSomeEvents({Key? key}) : super(key: key);

  @override
  State<ViewSomeEvents> createState() {
    return _viewsomeevents();
  }
}

class _viewsomeevents extends State<ViewSomeEvents> {
  final NewTaskController task = Get.put(NewTaskController());
  final Random random = Random();
  final ThemeController _themeController = Get.find<ThemeController>();

  @override
  void initState() {
    super.initState();
  }

  Color getRandomColor() {
    return colors[random.nextInt(colors.length)];
  }

  void _showBottomSheet(BuildContext context, Event event, Color color) {
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
              const SizedBox(height: 16),
              // ElevatedButton(
              //   onPressed: () {
              //     task.deleteEvent(event);
              //     Navigator
              //   },
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Colors.red,
              //     minimumSize: const Size(double.infinity,
              //         50), // Full-width button with fixed height
              //   ),
              //   child: const Text(
              //     'Delete Event',
              //     style: TextStyle(color: Colors.black),
              //   ),
              // ),
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
                  backgroundColor: _themeController.isDarkTheme.value
                      ? Colors.white
                      : Colors.black,
                  minimumSize: const Size(double.infinity,
                      50), // Full-width button with fixed height
                ),
                child: Text(
                  'View Event Details',
                  style: TextStyle(
                    color: _themeController.isDarkTheme.value
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Date Events'),
        backgroundColor: _themeController.isDarkTheme.value
            ? Colors.black // Color(0xFF0D6E6E)
            : Colors.white, //Color(0xFFFF3D3D),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (task.dateevents.isEmpty) {
                  return const Center(child: Text('No events found.'));
                } else {
                  return ListView.builder(
                    itemCount: task.dateevents.length,
                    itemBuilder: (context, index) {
                      final event = task.dateevents[index];

                      Color color = Color(event.color!);
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        child: SlideAnimation(
                          child: FadeInAnimation(
                            child: GestureDetector(
                              onTap: () {
                                _showBottomSheet(context, event, color);
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      color,
                                      _themeController.isDarkTheme.value
                                          ? Colors.black
                                          : Colors.white,
                                    ],
                                  ),
                                  color: color, // Set background color
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event.title.toString().toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            _themeController.isDarkTheme.value
                                                ? Colors.white
                                                : Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            event.notes.toString(),
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: _themeController
                                                      .isDarkTheme.value
                                                  ? Colors.white70
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.calendar_today,
                                                  color: _themeController
                                                          .isDarkTheme.value
                                                      ? Colors.white70
                                                      : Colors.black,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  event.startDate.toString(),
                                                  style: TextStyle(
                                                    color: _themeController
                                                            .isDarkTheme.value
                                                        ? Colors.white70
                                                        : Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.access_time,
                                                  color: _themeController
                                                          .isDarkTheme.value
                                                      ? Colors.white70
                                                      : Colors.black,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  event.startTime.toString(),
                                                  style: TextStyle(
                                                    color: _themeController
                                                            .isDarkTheme.value
                                                        ? Colors.white70
                                                        : Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.access_time_filled,
                                                  color: _themeController
                                                          .isDarkTheme.value
                                                      ? Colors.white70
                                                      : Colors.black,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  event.endTime.toString(),
                                                  style: TextStyle(
                                                    color: _themeController
                                                            .isDarkTheme.value
                                                        ? Colors.white70
                                                        : Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}

final List<Color> colors = [
  Color(0xFFFFF3E0), // Light orange
  Color(0xFFFFFDE7), // Light yellow
  Color(0xFFE1F5FE), // Light blue
  Color(0xFFF3E5F5), // Light purple
  Color(0xFFE8F5E9), // Light green
  Color(0xFFFFEBEE), // Light red
  Color(0xFFFFF9C4), // Light amber
];
