import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:timesyncr/get_started_screen.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      backgroundColor: Colors.black,
      splash: Center(
        child: Image.asset(
          "assets/timesyncr_512px_white.png",
          width: 300,
        ),
      ),
      nextScreen: GetStartedScreen(),
      splashIconSize: 900,
    );
  }
}
