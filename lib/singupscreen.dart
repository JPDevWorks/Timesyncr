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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/login_lc.png',
                  fit: BoxFit.fill, height: 130, width: 220),
              SizedBox(height: 30),
              Text(
                '',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black54,
                ),
              ),
              SignUpFormWidget(),
              SignUpFooterWidget(),
            ],
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
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextFormField(
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter your name'
                    : null,
                controller: nameController,
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person_outline),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  hintText: 'Full Name',
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextFormField(
                validator: validateEmail,
                controller: emailController,
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email_outlined),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  hintText: 'Email',
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
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
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.phone),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        hintText: 'Phone No',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextFormField(
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a password'
                    : null,
                controller: passwordController,
                obscureText: _obscureText,
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
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
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  hintText: 'Password',
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: registerUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // Change button color to black
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'SIGN UP',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
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
                        color: Colors.green, fontWeight: FontWeight.bold))
              ],
            ),
          ),
        )
      ],
    );
  }
}
