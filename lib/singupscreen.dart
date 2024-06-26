import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timesyncr/Home.dart'; // Import the homepage
import 'package:timesyncr/Formheader.dart';
import 'package:timesyncr/database/database_service.dart';
import 'package:timesyncr/models/user.dart';
import 'package:firebase_database/firebase_database.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
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
                  heightBetween: 35,
                  title: 'Sign Up',
                  subTitle: 'Create a new account',
                  imageHeight: 0.12,
                ),
                SignUpFormWidget(),
                SignUpFooterWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SignUpFormWidget extends StatefulWidget {
  const SignUpFormWidget({Key? key}) : super(key: key);

  @override
  _SignUpFormWidgetState createState() => _SignUpFormWidgetState();
}

class _SignUpFormWidgetState extends State<SignUpFormWidget> {
  String email = "";
  String password = "";
  String name = "";
  String phone = "";
  String countryCode = "+91";
  bool _obscureText = true;

  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController namecontroller = TextEditingController();
  TextEditingController phonecontroller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  registration() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      User? firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        String userId = firebaseUser.uid; // Retrieve the UID

        Userdetials user = Userdetials(
            name: namecontroller.text,
            email: emailcontroller.text,
            phonenumber: '$countryCode${phonecontroller.text}',
            password: passwordcontroller.text,
            status: "Yes",
            profileImage: "Null");
        if (await DatabaseService.userAdd(user)) {
          print("User added");
        }

        // Store user data in Firestore using the UID
        Map<String, dynamic> userInfoMap = {
          "email": user.email,
          "name": user.name,
          "phonenumber": user.phonenumber,
          "password": user.password,
          "status": user.status,
          "profileImage": user.profileImage,
        };
        DatabaseReference userRef =
            FirebaseDatabase.instance.ref().child('Users').child(userId);
        await userRef.set({
          "email": user.email,
          "name": user.name,
          "phonenumber": user.phonenumber,
          "password": user.password,
          "status": user.status,
          "profileImage": user.profileImage
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "Registered Successfully",
            style: TextStyle(fontSize: 20.0),
          ),
        ));

        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      String message = "";
      if (e.code == 'weak-password') {
        message = "Password provided is too weak.";
      } else if (e.code == 'email-already-in-use') {
        message = "Account already exists.";
      } else {
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

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please Enter Email';
    }
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please Enter phone number';
    }
    final phoneRegExp = RegExp(r'^\+?[0-9]{10,15}$');
    if (!phoneRegExp.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
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
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please Enter Name';
                }
                return null;
              },
              controller: namecontroller,
              decoration: const InputDecoration(
                label: Text('Full Name'),
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              validator: validateEmail,
              controller: emailcontroller,
              decoration: const InputDecoration(
                label: Text('Email'),
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 20.0),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: countryCode,
                    onChanged: (String? newValue) {
                      setState(() {
                        countryCode = newValue!;
                      });
                    },
                    items: <String>['+1', '+44', '+91', '+61', '+81']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: '',
                      prefixIcon: Icon(Icons.flag),
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  flex: 5,
                  child: TextFormField(
                    validator: validatePhone,
                    controller: phonecontroller,
                    decoration: const InputDecoration(
                      label: Text('Phone No'),
                      prefixIcon: Icon(Icons.numbers),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please Enter Password';
                }
                return null;
              },
              controller: passwordcontroller,
              obscureText: _obscureText,
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      email = emailcontroller.text;
                      name = namecontroller.text;
                      password = passwordcontroller.text;
                      phone = phonecontroller.text;
                    });

                    registration();
                  }
                },
                child: const Text('SIGN UP'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SignUpFooterWidget extends StatelessWidget {
  const SignUpFooterWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("OR"),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // Implement the sign-in with Google logic here
            },
            icon: const Image(
              image: AssetImage(
                  'assets/google.png'), // Update with the actual image path
              width: 20.0,
            ),
            label: const Text('SIGN IN WITH GOOGLE'),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/login');
          },
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Already have an account? ',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const TextSpan(text: 'LOGIN')
              ],
            ),
          ),
        )
      ],
    );
  }
}
