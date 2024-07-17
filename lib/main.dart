import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:timesyncr/Addevent.dart';
import 'package:timesyncr/database/database.dart';
import 'package:workmanager/workmanager.dart';
import 'Home.dart';
import 'Profile.dart';
import 'Settings.dart';
import 'forgotpassword.dart';
import 'loginscreen.dart';
import 'models/user.dart';
import 'Addevent.dart';
import 'service/NotificationService.dart';
import 'singupscreen.dart';
import 'splash.dart';
import 'them_controler.dart';
import 'callbackDispatcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();
  NotificationService().initializeTimeZone();
  NotificationService.initialize();
  //await DatabaseService.getdb();
  await Databasee.getdb();

  String initialRoute = await getInitialRoute();
  String email = await getIntialemail();

  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );

  DateTime now = DateTime.now();
  DateTime nextMidnight = DateTime(now.year, now.month, now.day + 1, 0, 0, 0);
  Duration initialDelay = nextMidnight.difference(now);
  print(initialDelay);

  Workmanager().registerPeriodicTask(
    "1",
    "dailyEventCheck",
    frequency: Duration(hours: 24),
    initialDelay: initialDelay,
    constraints: Constraints(
      networkType: NetworkType.not_required,
      requiresBatteryNotLow: false,
      requiresCharging: false,
      requiresDeviceIdle: false,
      requiresStorageNotLow: false,
    ),
  );

  runApp(MyApp(initialRoute: initialRoute, email: email));
}

Future<String> getInitialRoute() async {
  Userdetials? latestUser = await Databasee.userGet();
  if (latestUser != null && latestUser.status == 'Yes') {
    print('Email User : ${latestUser.email}');
    return '/home';
  } else {
    return '/';
  }
}

Future<String> getIntialemail() async {
  Userdetials? latestUser = await Databasee.userGet();
  if (latestUser != null && latestUser.status == 'Yes') {
    print('Email User : ${latestUser.email}');
    return '${latestUser.email}';
  } else {
    return 'Null';
  }
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  final String email;
  final ThemeController themeController = Get.put(ThemeController());

  MyApp({Key? key, required this.initialRoute, required this.email})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'timesyncr',
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: themeController.isDarkTheme.value
            ? ThemeMode.dark
            : ThemeMode.light,
        initialRoute: initialRoute,
        getPages: [
          GetPage(name: '/', page: () => Splash()),
          GetPage(name: '/home', page: () => Homepage()),
          GetPage(name: '/settings', page: () => Settings()),
          GetPage(name: '/login', page: () => LoginScreen()),
          GetPage(name: '/signup', page: () => SignUpScreen()),
          GetPage(name: '/forgot', page: () => ForgetPasswordScreen()),
          GetPage(name: '/newEvent', page: () => NewEventScreen()),
          GetPage(name: '/profile', page: () => ProfileScreen(userId: email)),
        ],
      );
    });
  }
}
