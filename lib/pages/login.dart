import 'package:chat_app/pages/register.dart';
import 'package:chat_app/pages/top_page.dart';
import 'package:chat_app/utils/authentication_error.dart';
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
  User? _user;

  String? _login_email = '';
  String? _login_password = '';
  String _infoText = '';
  //エラーメッセージを日本語化
  final auth_error = Authentication_error();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ログインページ'),
      ),
      body: Padding(
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
                    decoration: InputDecoration(hintText: 'example@gmail.com'),
                    controller: emailController,
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
                      _login_password = text;
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
                try {
                  _result = await _auth.signInWithEmailAndPassword(
                    email: _login_email!,
                    password: _login_password!,
                  );
                  _user = _result!.user;

                  if (_user!.emailVerified) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TopPage()),
                    );
                  }
                } catch (e) {
                  setState(() {
                    _infoText = 'ログインに失敗しました';
                  });
                }
              },
              child: Text('ログイン'),
            ),
            SizedBox(
              height: 10,
            ),
            TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => RegisterPage()));
                },
                child: Text('新規登録がお済みでない方はこちらから'))
          ],
        ),
      ),
    );
  }
}
