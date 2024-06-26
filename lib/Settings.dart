import 'package:flutter/material.dart';
import 'package:timesyncr/Home.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        leading: Container(), // This removes the default back button
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Homepage()),
              ); // This closes the current page and returns to the previous page
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () {
              // Handle profile tap
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.video_library),
            title: Text('Watch Tutorial'),
            onTap: () {
              // Handle watch tutorial tap
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.upgrade),
            title: Text('Upgrade'),
            onTap: () {
              // Handle upgrade tap
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.contact_mail),
            title: Text('Contact Us'),
            onTap: () {
              // Handle contact us tap
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              // Handle logout tap
            },
          ),
        ],
      ),
    );
  }
}
