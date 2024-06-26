import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timesyncr/them_controler.dart';

class NotificationScreen extends StatelessWidget {
  final ThemeController _themeController = Get.find<ThemeController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: _themeController.isDarkTheme.value
            ? Color(0xFF0D6E6E)
            : Color(0xFFFF3D3D),
      ),
      body: Center(
        child: Text(
          'No notifications available.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
