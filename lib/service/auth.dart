import 'package:timesyncr/Home.dart';
import 'package:timesyncr/database/database_service.dart';
import 'package:timesyncr/models/user.dart';
import 'package:timesyncr/service/databasemethods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<User?> getCurrentUser() async {
    return auth.currentUser;
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );

      UserCredential result = await auth.signInWithCredential(credential);
      User? userDetails = result.user;

      if (userDetails != null) {
        Map<String, dynamic> userInfoMap = {
          "name": userDetails.displayName,
          "email": userDetails.email,
          "profileImage": "Null",
          "phonenumber": "Null",
          "password": "Null",
          "status": "Yes",
        };

        Userdetials userdata = Userdetials.fromJson(userInfoMap);

        await DatabaseService.userAdd(userdata);

        await DatabaseMethods()
            .addUser(userDetails.uid, userInfoMap)
            .then((value) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Homepage()));
        });
      }
    }
  }

  Future<void> signInWithApple(BuildContext context) async {
    final AuthorizationCredentialAppleID appleIdCredential =
        await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName
      ],
    );

    final OAuthProvider oAuthProvider = OAuthProvider("apple.com");
    final AuthCredential credential = oAuthProvider.credential(
      idToken: appleIdCredential.identityToken,
      accessToken: appleIdCredential.authorizationCode,
    );

    UserCredential result = await auth.signInWithCredential(credential);
    User? userDetails = result.user;

    if (userDetails != null) {
      String? fullName =
          "${appleIdCredential.givenName} ${appleIdCredential.familyName}"
              .trim();
      if (fullName.isEmpty) fullName = userDetails.displayName ?? "Null";

      Map<String, dynamic> userInfoMap = {
        "name": fullName,
        "email": userDetails.email ?? "Null",
        "profileImage": "Null",
        "phonenumber": "Null",
        "password": "Null",
        "status": "Yes",
      };

      Userdetials userdata = Userdetials.fromJson(userInfoMap);

      await DatabaseService.userAdd(userdata);

      await DatabaseMethods()
          .addUser(userDetails.uid, userInfoMap)
          .then((value) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Homepage()));
      });
    }
  }
}
