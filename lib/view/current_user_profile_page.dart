import 'dart:io';

import 'package:chat_app/view/login.dart';
import 'package:chat_app/view/settings_profile.dart';
import 'package:chat_app/utils/firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CurrentUserProfilePage extends StatefulWidget {
  @override
  _CurrentUserProfilePageState createState() => _CurrentUserProfilePageState();
}

class _CurrentUserProfilePageState extends State<CurrentUserProfilePage> {
  File? image;
  ImagePicker picker = ImagePicker();
  String? imagePath;
  TextEditingController controller = TextEditingController();
  User? currentUser;

  Future<void> getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      image = File(pickedFile.path);
      uploadImage();
      setState(() {});
    }
  }

  Future<String?> uploadImage() async {
    final ref = FirebaseStorage.instance.ref('test_pic.png');
    final storedImage = await ref.putFile(image!);
    imagePath = await loadImage(storedImage);
    return imagePath;
  }

  Future<String?> loadImage(TaskSnapshot storedImage) async {
    String downloadUrl = await storedImage.ref.getDownloadURL();
    return downloadUrl;
  }

  @override
  Widget build(BuildContext context) {
    String? myUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('プロフィール画面'),
        actions: [
          IconButton(
            onPressed: () async {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Center(child: Text('ログアウトしますか？')),
                    actions: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Row(
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('キャンセル'),
                              ),
                              SizedBox(
                                width: 30,
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  await Auth.logOut();
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginPage()),
                                    (Route<dynamic> route) => false,
                                  );
                                },
                                child: Text('ログアウト'),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  );
                },
              );
            },
            icon: Icon(Icons.logout),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder(
            future: Auth.fetchUser(myUid!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              return Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: 50,
                    ),
                    Auth.profileImage == null
                        ? Container(
                            width: 200,
                            height: 200,
                            color: Colors.grey,
                          )
                        : Container(
                            width: 200,
                            height: 200,
                            child: Image.network(
                              Auth.profileImage ?? '',
                              fit: BoxFit.cover,
                              errorBuilder: (c, o, s) {
                                return const Icon(
                                  Icons.error,
                                  color: Colors.red,
                                );
                              },
                            ),
                          ),
                    SizedBox(
                      height: 50,
                    ),
                    Container(
                      child: Text(
                        Auth.name ?? 'ユーザー名が設定されていません',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: () async {
                        await Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => SettingsProfilePage(
                                Auth.name, Auth.profileImage)));
                        await Auth.fetchUser(myUid);
                        setState(() {});
                      },
                      child: Text('編集する'),
                    )
                  ],
                ),
              );
            }),
      ),
    );
  }
}
