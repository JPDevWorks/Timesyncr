import 'package:firebase_database/firebase_database.dart';

class DatabaseMethods {
  Future<void> addUser(String userId, Map<String, dynamic> userInfoMap) async {
    try {
      await FirebaseDatabase.instance
          .ref()
          .child("Users")
          .child(userId)
          .set(userInfoMap);
    } catch (e) {
      // Handle error
      print("Error adding user: $e");
    }
  }
}
