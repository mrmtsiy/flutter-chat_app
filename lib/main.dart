import 'package:chat_app/view/login.dart';
import 'package:chat_app/view/route.dart';
import 'package:chat_app/utils/firebase.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // await SharedPrefs.setInstance();
  // checkAccount();
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

Future<void> checkAccount() async {
  String? uid = FirebaseAuth.instance.currentUser?.uid;
  // アカウントが生成されていなかった場合、アカウントを新規に作成する
  if (uid == '') {
    Firestore.addUser();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.blue[200],
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return RoutePage();
          } else {
            return LoginPage();
          }
        },
      ),
    );
  }
}
