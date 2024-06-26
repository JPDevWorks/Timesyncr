import 'package:flutter/widgets.dart';

class Screen1 extends StatelessWidget {
  const Screen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 50,
          ),
          child: Center(
            child: Image.asset('assets/cal1.avif'),
          ),
        ),
        const SizedBox(
          height: 0, // Increase space between the image and text
        ),
        const SizedBox(
          height: 0,
        ),
        Container(
          child: const Text(
            'timesyncr is a Calendar Scheduler App which makes it easy to schedule your plans.',
            textAlign:
                TextAlign.center, // Center the text for better aesthetics
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
        ),
      ],
    );
  }
}
