import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  static final FirebaseAuth auth = FirebaseAuth.instance;

  static Future<void> getCurrentUser() async {
    auth.currentUser;
  }
}
