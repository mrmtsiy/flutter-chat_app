import 'package:chat_app/pages/top_page.dart';
import 'package:chat_app/utils/firebase.dart';
import 'package:chat_app/utils/shared_prefs.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SharedPrefs.setInstance();
  checkAccount();
  runApp(MyApp());
}

Future<void> checkAccount() async {
  String? uid = SharedPrefs.getUid();
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
        primarySwatch: Colors.blue,
      ),
      home: TopPage(),
    );
  }
}
