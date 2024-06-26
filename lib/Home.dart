import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timesyncr/DashBoard.dart';
import 'package:timesyncr/EventScreen.dart';
import 'package:timesyncr/Profile.dart';
import 'package:timesyncr/TimeTable.dart';
import 'package:timesyncr/controller/task_controller.dart';
import 'package:timesyncr/database/database_service.dart';
import 'package:timesyncr/models/user.dart';
import 'package:timesyncr/notificationscreen.dart';
import 'package:timesyncr/them_controler.dart';
import 'package:url_launcher/url_launcher.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _Home();
}

class _Home extends State<Homepage> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _currentPageIndex = 0;
  int count = 0;
  bool isSideMenuClosed = true;
  Userdetials? userr;
  final ThemeController themeController = Get.find();
  final TaskController _taskController = Get.put(TaskController());
  Userdetials? userProfile;

  @override
  void initState() {
    super.initState();
    _taskController.fetchtodayEvents();
    count = TaskController().dateevents.length;
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    getuser().then((_) {
      if (userr != null) {
        getUserProfile();
      }
    });
  }

  Future<void> getuser() async {
    Userdetials? latestUser = await DatabaseService.userGet();
    if (latestUser != null && latestUser.status == 'Yes') {
      print('Email User : ${latestUser.email}');
      setState(() {
        userr = latestUser;
      });
    }
  }

  Future<void> getUserProfile() async {
    if (userr == null) return;

    Userdetials? user =
        await DatabaseService.getUserDetailsByEmail(userr!.email!.toString());
    if (user != null) {
      setState(() {
        userProfile = user;
      });
    }
  }

  void _toggleDrawer() {
    if (_scaffoldKey.currentState!.isDrawerOpen) {
      _closeDrawer();
    } else {
      _animationController.forward();
      setState(() {
        isSideMenuClosed = false;
      });
      _scaffoldKey.currentState!.openDrawer();
    }
  }

  void _closeDrawer() {
    if (_scaffoldKey.currentState!.isDrawerOpen) {
      Navigator.of(context).pop();
      if (_animationController.isCompleted) {
        _animationController.reverse();
      }
      setState(() {
        isSideMenuClosed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      body: Obx(() {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: themeController.isDarkTheme.value
                  ? [Color(0xFF0D6E6E), Colors.black]
                  : [Color(0xFFFF3D3D), Colors.white],
            ),
          ),
          child: GestureDetector(
            onTap: () {
              if (_scaffoldKey.currentState!.isDrawerOpen) {
                _toggleDrawer();
              }
            },
            child: SafeArea(
              child: Obx(() {
                return AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform(
                      transform: Matrix4.identity(),
                      alignment: Alignment.centerLeft,
                      child: child,
                    );
                  },
                  child: Container(
                    color: themeController.isDarkTheme.value
                        ? Color(0xFF0D6E6E)
                        : Color(0xFFFF3D3D),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.menu,
                                      color: themeController.isDarkTheme.value
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                    onPressed: _toggleDrawer,
                                  ),
                                ],
                              ),
                              const Text(
                                'TIMESYNCR',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.notifications,
                                  color: themeController.isDarkTheme.value
                                      ? Colors.black
                                      : Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          NotificationScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(
                            child: PageView(
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentPageIndex = index;
                                });
                              },
                              children: [
                                DashBoard(
                                  count: count,
                                ),
                                TimeTable(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Obx(() {
        return _currentPageIndex == 0
            ? Container(
                margin: EdgeInsets.only(top: 20),
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventScreen(
                          startTime: DateTime.now(),
                          selectedDate: DateTime.now(),
                        ),
                      ),
                    );
                  },
                  child: Icon(Icons.add),
                  backgroundColor: themeController.isDarkTheme.value
                      ? Color(0xFF0D6E6E)
                      : Color(0xFFFF3D3D),
                ),
              )
            : SizedBox.shrink();
      }),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentPageIndex,
        onTap: (index) {
          _pageController.jumpToPage(index);
          setState(() {
            _currentPageIndex = index;
          });
        },
      ),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: Obx(() {
        return Container(
          color:
              themeController.isDarkTheme.value ? Colors.black : Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                height: 250,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: themeController.isDarkTheme.value
                        ? Color(0xFF0D6E6E)
                        : Color(0xFFFF3D3D),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(161, 158, 158, 158),
                                shape: BoxShape.circle,
                                image: userProfile?.profileImage != null
                                    ? DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                            userProfile!.profileImage!),
                                      )
                                    : null,
                              ),
                              child: Center(
                                child: userProfile?.profileImage == null
                                    ? Icon(
                                        Icons.person_rounded,
                                        color: Colors.black38,
                                        size: 25,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.white),
                            onPressed: _closeDrawer,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 300,
                        child: Text(
                          userProfile?.name ?? 'No Name found',
                          style: TextStyle(
                            color: themeController.isDarkTheme.value
                                ? Colors.black
                                : Colors.white,
                            fontSize: 20,
                          ),
                          overflow: TextOverflow.clip,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.home,
                  color: themeController.isDarkTheme.value
                      ? Colors.white
                      : Colors.black,
                ),
                title: Text('Home',
                    style: TextStyle(
                      color: themeController.isDarkTheme.value
                          ? Colors.white
                          : Colors.black,
                    )),
                onTap: () {
                  _pageController.jumpToPage(0);
                  _closeDrawer();
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.person,
                  color: themeController.isDarkTheme.value
                      ? Colors.white
                      : Colors.black,
                ),
                title: Text('Profile',
                    style: TextStyle(
                      color: themeController.isDarkTheme.value
                          ? Colors.white
                          : Colors.black,
                    )),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                          userId: userr?.email ?? 'No email found'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  themeController.isDarkTheme.value
                      ? Icons.dark_mode
                      : Icons.light_mode,
                  color: themeController.isDarkTheme.value
                      ? Colors.white
                      : Colors.black,
                ),
                title: Text(
                    themeController.isDarkTheme.value
                        ? "Dark Theme"
                        : "Light Theme",
                    style: TextStyle(
                      color: themeController.isDarkTheme.value
                          ? Colors.white
                          : Colors.black,
                    )),
                onTap: () {
                  themeController.toggleTheme();
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.help,
                  color: themeController.isDarkTheme.value
                      ? Colors.white
                      : Colors.black,
                ),
                title: Text('Terms & Conditions',
                    style: TextStyle(
                      color: themeController.isDarkTheme.value
                          ? Colors.white
                          : Colors.black,
                    )),
                onTap: () async {
                  final uri = Uri.parse(
                      'https://doc-hosting.flycricket.io/taxi-mall-privacy-policy/eac5c663-d1d2-444e-beb6-34cd08f6284c/privacy');
                  _launchInWebView(uri);
                  _closeDrawer();
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.home,
                  color: themeController.isDarkTheme.value
                      ? Colors.white
                      : Colors.black,
                ),
                title: Text('Privacy & Policy',
                    style: TextStyle(
                      color: themeController.isDarkTheme.value
                          ? Colors.white
                          : Colors.black,
                    )),
                onTap: () async {
                  final uri = Uri.parse(
                      'https://doc-hosting.flycricket.io/taxi-mall-privacy-policy/eac5c663-d1d2-444e-beb6-34cd08f6284c/privacy');
                  _launchInWebView(uri);
                  _closeDrawer();
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.logout,
                  color: themeController.isDarkTheme.value
                      ? Colors.white
                      : Colors.black,
                ),
                title: Text('Log out',
                    style: TextStyle(
                      color: themeController.isDarkTheme.value
                          ? Colors.white
                          : Colors.black,
                    )),
                onTap: () {
                  DatabaseService.deleteAllUsers();
                  FirebaseAuth.instance.signOut();
                  Get.offNamedUntil('/login', (route) => false);
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  CustomBottomNavigationBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find();
    return Obx(() {
      return Container(
        margin: const EdgeInsets.only(bottom: 15, top: 5, right: 20, left: 20),
        decoration: BoxDecoration(
          color:
              themeController.isDarkTheme.value ? Colors.white : Colors.black,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onTap,
            selectedItemColor: themeController.isDarkTheme.value
                ? Color(0xFF0D6E6E)
                : Color(0xFFFF3D3D),
            unselectedItemColor: themeController.isDarkTheme.value
                ? Color(0xFF0D6E6E)
                : Color(0xFFFF3D3D),
            backgroundColor: Colors.white,
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.dashboard,
                  color: themeController.isDarkTheme.value
                      ? Color(0xFF0D6E6E)
                      : Color(0xFFFF3D3D),
                ),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.calendar_today,
                  color: themeController.isDarkTheme.value
                      ? Color(0xFF0D6E6E)
                      : Color(0xFFFF3D3D),
                ),
                label: 'TimeTable',
              ),
            ],
          ),
        ),
      );
    });
  }
}

Future<void> _launchInWebView(Uri url) async {
  if (!await launchUrl(url, mode: LaunchMode.inAppWebView)) {
    throw Exception('Could not launch $url');
  }
}
