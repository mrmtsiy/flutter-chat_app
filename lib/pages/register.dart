import 'package:chat_app/pages/top_page.dart';
import 'package:chat_app/utils/authentication_error.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  UserCredential? _result;
  User? _user;

  String _registerEmail = '';
  String _registerPassword = '';
  String _infoText = "";
  // ignore: non_constant_identifier_names
  bool _pswd_OK = false;

  // ignore: non_constant_identifier_names
  final auth_error = Authentication_error();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('新規登録画面'),
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
                    decoration: InputDecoration(labelText: 'example@gmail.com'),
                    controller: emailController,
                    onChanged: (text) {
                      _registerEmail = text;
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
                    decoration: InputDecoration(labelText: "(8～20文字）"),
                    obscureText: true,
                    controller: passwordController,
                    maxLength: 20, // 入力可能な文字数

                    onChanged: (text) {
                      if (text.length >= 8) {
                        _registerPassword = text;
                        _pswd_OK = true;
                      } else {
                        _pswd_OK = false;
                      }
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
                if (_pswd_OK) {
                  try {
                    _result = await _auth.createUserWithEmailAndPassword(
                      email: _registerEmail,
                      password: _registerPassword,
                    );
                    _user = _result!.user;
                    //確認のEmailを送信
                    // _user!.sendEmailVerification();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TopPage(),
                      ),
                    );
                  } catch (e) {
                    setState(() {
                      _infoText = 'ユーザーの登録に失敗しました';
                    });
                  }
                } else {
                  setState(() {
                    _infoText = 'パスワードは8文字以上です。';
                  });
                }
              },
              child: Text('新規登録'),
            ),
          ],
        ),
      ),
    );
  }
}
