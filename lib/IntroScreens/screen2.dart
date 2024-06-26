import 'package:flutter/widgets.dart';

class Screen2 extends StatelessWidget {
  const Screen2({super.key});

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
            child: Image.asset('assets/cal2.avif'),
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
            'In timesyncr you can schedule your plans more Easily.',
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
