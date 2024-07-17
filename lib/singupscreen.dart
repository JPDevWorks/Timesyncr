import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timesyncr/Home.dart'; // Import the homepage
import 'package:timesyncr/Formheader.dart';
import 'package:timesyncr/database/database.dart';
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
            child: Column(
              children: const [
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
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  String countryCode = "+91";
  bool _obscureText = true;
  final _formKey = GlobalKey<FormState>();

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) {
      return; // If validation fails, exit the function.
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const Dialog(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Registering... Please wait"),
            ],
          ),
        ),
      ),
    );

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      final user = Userdetials(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phonenumber: '$countryCode${phoneController.text.trim()}',
        password: passwordController.text.trim(),
        status: "Yes",
        profileImage: "Null",
      );
      // Assuming 'Databasee.userAdd' and 'FirebaseDatabase' integration is correct
      if (await Databasee.userAdd(user)) {
        DatabaseReference userRef = FirebaseDatabase.instance
            .ref()
            .child('Users')
            .child(userCredential.user!.uid);
        await userRef.set(user.toJson());
        Navigator.pop(context); // Close the loading dialog
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      String errorMessage =
          'An unexpected error occurred. Please try again later.';
      if (e.code.contains('weak-password')) {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code.contains('email-already-in-use')) {
        errorMessage =
            'The email address is already in use by another account.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
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
              validator: (value) => value == null || value.isEmpty
                  ? 'Please enter your name'
                  : null,
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              validator: validateEmail,
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Row(
              children: [
                CountryCodePicker(
                  onChanged: (country) {
                    setState(() {
                      countryCode = country.dialCode!;
                    });
                  },
                  initialSelection: 'US',
                  favorite: const ['+91', 'IN'],
                  showCountryOnly: false,
                  showOnlyCountryWhenClosed: false,
                  alignLeft: false,
                  showDropDownButton: true,
                  padding: EdgeInsets.zero,
                ),
                Expanded(
                  child: TextFormField(
                    validator: validatePhone,
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone No',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              validator: (value) => value == null || value.isEmpty
                  ? 'Please enter a password'
                  : null,
              controller: passwordController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.fingerprint),
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: registerUser,
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
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/login');
          },
          child: Text.rich(
            TextSpan(
              text: 'Already have an account? ',
              style: Theme.of(context).textTheme.bodyLarge,
              children: const [
                TextSpan(
                    text: 'Login',
                    style: TextStyle(
                        color: Colors.deepPurple, fontWeight: FontWeight.bold))
              ],
            ),
          ),
        )
      ],
    );
  }
}
