import 'package:chat_app/pages/login.dart';
import 'package:chat_app/utils/authentication_error.dart';
import 'package:chat_app/utils/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Center(
                  child: Container(
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          child: Image.network(
                              'https://cdn-images-1.medium.com/max/1200/1*ilC2Aqp5sZd1wi0CopD1Hw.png'),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text('Flutter Chat',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 40,
                              shadows: [
                                Shadow(
                                  blurRadius: 1.0,
                                  color: Colors.black12,
                                  offset: Offset(5.0, 5.0),
                                ),
                                Shadow(
                                  color: Colors.black26,
                                  blurRadius: 10.0,
                                  offset: Offset(1.0, 5.0),
                                ),
                              ],
                            )),
                      ],
                    ),
                  ),
                ),
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
                            InputDecoration(labelText: 'example@gmail.com'),
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
                    Firestore.startLoading();
                    setState(() {});
                    if (_pswd_OK) {
                      try {
                        _result = await _auth.createUserWithEmailAndPassword(
                          email: _registerEmail,
                          password: _registerPassword,
                        );
                        _user = _result!.user;

                        //fireStoreに作成したユーザーを保存
                        if (_user != null) {
                          final uid = _user?.uid;
                          final userDoc = FirebaseFirestore.instance
                              .collection('user')
                              .doc(uid);
                          await userDoc.set({
                            'uid': uid,
                            'email': emailController.text,
                            'image_path':
                                'https://freesvg.org/img/abstract-user-flat-1.png'
                          });
                          await Firestore.setRoom();
                        }

                        setState(() {
                          _infoText = 'FlutterChatへようこそ';
                          final snackBar = SnackBar(
                              backgroundColor: Colors.green,
                              content: Text(_infoText));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        });
                        //確認のEmailを送信
                        // _user!.sendEmailVerification();
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => LoginPage()));
                      } catch (e) {
                        setState(() {
                          _infoText = 'ユーザーの登録に失敗しました';
                          final snackBar = SnackBar(
                              backgroundColor: Colors.red,
                              content: Text(_infoText));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        });
                      } finally {
                        Firestore.endloading();
                      }
                    } else {
                      setState(() {
                        _infoText = 'パスワードは8文字以上です。';
                        final snackBar = SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(_infoText));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      });
                    }
                  },
                  child: Text('新規登録'),
                ),
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
