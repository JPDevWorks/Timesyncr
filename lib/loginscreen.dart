import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timesyncr/Home.dart'; // Import the homepage
import 'package:timesyncr/FormHeader.dart';
import 'package:timesyncr/database/database_service.dart';
import 'package:timesyncr/models/user.dart';
import 'package:timesyncr/service/auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: const Column(
              children: [
                FormHeaderWidget(
                  image: 'assets/timesyncr_512px.png',
                  heightBetween: 50,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  title: 'Sign In',
                  subTitle: 'Welcome back, you\'ve been missed!',
                  imageHeight: 0.12,
                ),
                LoginFormWidget(),
                LoginFooterWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoginFormWidget extends StatefulWidget {
  const LoginFormWidget({Key? key}) : super(key: key);

  @override
  _LoginFormWidgetState createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  String email = "";
  String password = "";
  bool _obscureText = true;

  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  userlogin() async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      Userdetials user = Userdetials(
        name: emailcontroller.text,
        email: emailcontroller.text,
        profileImage: "Null",
        phonenumber: "Null",
        password: passwordcontroller.text,
        status: "Yes",
      );
      if (await DatabaseService.userAdd(user)) {
        print("added User");
      }
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String message = "";
      if (e.code == 'user-not-found') {
        message = "User not found for that email.";
      } else if (e.code == "invalid-credential") {
        print(e.code);
        message = "Wrong Email or password provided by user.";
      } else {
        print(e.code);
        message = "An error occurred. Please try again.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text(
            message,
            style: TextStyle(fontSize: 18.0),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: emailcontroller,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please Enter Email';
                }
                return null;
              },
              decoration: const InputDecoration(
                label: Text('Email'),
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              controller: passwordcontroller,
              obscureText: _obscureText,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please Enter Password';
                }
                return null;
              },
              decoration: InputDecoration(
                label: const Text('Password'),
                prefixIcon: const Icon(Icons.fingerprint),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/forgot');
                },
                child: const Text('Recovery Password'),
              ),
            ),
            const SizedBox(height: 20.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      email = emailcontroller.text;
                      password = passwordcontroller.text;
                    });
                    userlogin();
                  }
                },
                child: const Text('SIGN IN'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class LoginFooterWidget extends StatelessWidget {
  const LoginFooterWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("OR"),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              AuthMethods().signInWithGoogle(context);
            },
            icon: const Image(
              image: AssetImage(
                  'assets/google.png'), // Update with the actual image path
              width: 20.0,
            ),
            label: const Text('SIGN IN WITH GOOGLE'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              AuthMethods().signInWithApple(context);
            },
            icon: const Icon(
              Icons.apple,
              size: 20.0,
            ),
            label: const Text('SIGN IN WITH APPLE'),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/signup');
          },
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Don\'t have an account? ',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const TextSpan(text: 'SIGN UP')
              ],
            ),
          ),
        )
      ],
    );
  }
}
