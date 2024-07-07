import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timesyncr/service/NotificationService.dart';
import 'package:timesyncr/them_controler.dart';

class PendingNotificationsPage extends StatefulWidget {
  @override
  _PendingNotificationsPageState createState() =>
      _PendingNotificationsPageState();
}

class _PendingNotificationsPageState extends State<PendingNotificationsPage> {
  final ThemeController themeController = Get.put(ThemeController());
  List<Map<String, String>> notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchPendingNotifications();
  }

  Future<void> _fetchPendingNotifications() async {
    var details = await NotificationService.getPendingNotificationDetails();
    setState(() {
      notifications = details;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = themeController.isDarkTheme.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pending Notifications',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        backgroundColor: isDark ? Color(0xFF121212) : Colors.white,
        elevation: 0,
      ),
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: notifications.isEmpty
            ? Center(
                child: Text(
                  'No pending notifications',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
              )
            : ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  return _buildNotificationCard(notifications[index], isDark);
                },
              ),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, String> notification, bool isDark) {
    return Card(
      color: isDark ? Color(0xFF1C1C1C) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification ID: ${notification['id']}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Title: ${notification['title']}',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white30 : Colors.black38,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Body: ${notification['body']}',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white30 : Colors.black38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
