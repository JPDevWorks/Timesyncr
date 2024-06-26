import 'package:flutter/material.dart';
import 'package:timesyncr/loginscreen.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({Key? key}) : super(key: key);

  @override
  _OnBoardingState createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  final PageController _pageController = PageController();
  int _activePage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'color': '#ffe24e',
      'title': 'timesyncr',
      'image': 'assets/2.png',
      'description':
          'timesyncr is an event reminder app designed to help you manage both child and parent events effortlessly.',
      'buttonText': 'Skip Now',
      'buttonColor': '#ffda44'
    },
    {
      'color': '#a3e4f1',
      'title': 'timesyncr',
      'image': 'assets/3.png',
      'description':
          'Never miss an event again with timesyncr. Keep track of all your important dates and stay organized.',
      'buttonText': 'Skip Now',
      'buttonColor': '#a3e4f1'
    },
    {
      'color': '#31b77a',
      'title': 'timesyncr',
      'image': 'assets/7.png',
      'description':
          'Get started with timesyncr today and experience the ease of managing your events. Create an account now!',
      'buttonText': 'Get Started',
      'buttonColor': '#31b77a'
    },
  ];

  void _onPageChanged(int index) {
    setState(() {
      _activePage = index;
    });
  }

  void onNextPage() {
    if (_activePage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.linear,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  List<Widget> _buildIndicator() {
    return List<Widget>.generate(_pages.length, (int index) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 4,
        width: _activePage == index ? 20 : 12,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: _activePage == index ? Colors.black : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(4),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (BuildContext context, int index) {
              return IntroWidget(
                color: _pages[index]['color'],
                title: _pages[index]['title'],
                description: _pages[index]['description'],
                image: _pages[index]['image'],
                buttonText: _pages[index]['buttonText'],
                buttonColor: _pages[index]['buttonColor'],
                onTab: onNextPage,
              );
            },
          ),
          Positioned(
            bottom: 360,
            left: 0,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}

class IntroWidget extends StatelessWidget {
  final String color;
  final String title;
  final String description;
  final String image;
  final String buttonText;
  final String buttonColor;
  final VoidCallback onTab;

  const IntroWidget({
    required this.color,
    required this.title,
    required this.description,
    required this.image,
    required this.buttonText,
    required this.buttonColor,
    required this.onTab,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(int.parse(color.substring(1, 7), radix: 16) + 0xFF000000),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: TopCurveClipper(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.6,
                color: Colors.white,
                child: Image.asset(image, fit: BoxFit.cover),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.60,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                ElevatedButton(
                  onPressed: onTab,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(
        size.width / 4, size.height * 0.85, size.width / 2, size.height * 0.9);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * .95, size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
