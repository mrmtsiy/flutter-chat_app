import 'package:chat_app/pages/register.dart';
import 'package:chat_app/pages/route.dart';
import 'package:chat_app/utils/authentication_error.dart';
import 'package:chat_app/utils/firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  UserCredential? _result;
  User? user;

  String? loginEmail = '';
  String? loginPassword = '';
  String _infoText = '';
  //エラーメッセージを日本語化
  final authError = Authentication_error();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ログインページ'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                ),
                Row(
                  children: [
                    Container(
                        width: 100,
                        child: Text(
                          'メールアドレス',
                          textAlign: TextAlign.center,
                        )),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: TextField(
                        decoration:
                            InputDecoration(hintText: 'example@gmail.com'),
                        controller: emailController,
                        onChanged: (text) {
                          loginEmail = text;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 50),
                Row(
                  children: [
                    Container(
                        width: 100,
                        child: Text(
                          'パスワード',
                          textAlign: TextAlign.center,
                        )),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(hintText: 'password'),
                        obscureText: true,
                        maxLength: 20, // 入力可能な文字数
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        controller: passwordController,
                        onChanged: (text) {
                          loginPassword = text;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 50,
                ),
                ElevatedButton(
                  onPressed: () async {
                    Firestore.startLoading();
                    setState(() {});
                    try {
                      _result = await _auth.signInWithEmailAndPassword(
                        email: loginEmail!,
                        password: loginPassword!,
                      );
                      user = _result!.user;

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RoutePage()),
                      );
                      _infoText = 'FlutterChatへようこそ';
                      final snackBar = SnackBar(
                          backgroundColor: Colors.green,
                          content: Text(_infoText));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    } catch (e) {
                      setState(() {
                        _infoText = 'ログインに失敗しました';
                        final snackBar = SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(_infoText));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      });
                    } finally {
                      Firestore.endloading();
                    }
                  },
                  child: Text('ログイン'),
                ),
                SizedBox(
                  height: 10,
                ),
                TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterPage()));
                    },
                    child: Text('新規登録がお済みでない方はこちらから'))
              ],
            ),
          ),
          if (Firestore.isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
        ],
      ),
    );
  }
}
