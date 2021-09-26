import 'dart:io';

import 'package:chat_app/model/user.dart';
import 'package:chat_app/utils/firebase.dart';
import 'package:chat_app/utils/auth.dart';
import 'package:chat_app/utils/shared_prefs.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SettingsProfilePage extends StatefulWidget {
  @override
  _SettingsProfilePageState createState() => _SettingsProfilePageState();
}

class _SettingsProfilePageState extends State<SettingsProfilePage> {
  File? image;
  ImagePicker picker = ImagePicker();
  String? imagePath;
  TextEditingController controller = TextEditingController();
  User? currentuser;

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
    String? myUid = SharedPrefs.getUid();

    return Scaffold(
      appBar: AppBar(
        title: Text('プロフィール画面'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder(
            future: Firestore.getProfile(myUid!),
            builder: (context, snapshot) {
              return Column(
                children: [
                  SizedBox(
                    height: 50,
                  ),
                  image == null
                      ? Container(
                          width: 200,
                          height: 200,
                          color: Colors.grey,
                        )
                      : Container(
                          width: 200,
                          height: 200,
                          child: Image.file(
                            image!,
                            fit: BoxFit.cover,
                          ),
                        ),
                  SizedBox(
                    height: 50,
                  ),
                  Row(
                    children: [
                      Container(
                          width: 120,
                          child: Text(
                            '名前',
                            textAlign: TextAlign.center,
                          )),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(hintText: 'currentUser'),
                          controller: controller,
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 50),
                  Row(
                    children: [
                      Container(width: 120, child: Text('プロフィール画像')),
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          child: Container(
                            width: 150,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () {
                                getImageFromGallery();
                              },
                              child: Text('画像を選択'),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      User newProfile = User(
                        name: controller.text,
                        imagePath: imagePath,
                      );
                      try {
                        await Firestore.updateProfile(newProfile);
                        Navigator.of(context).pop();
                        _showDialog(context, 'プロフィールを更新しました');
                      } catch (e) {
                        _showDialog(context, e.toString());
                      }
                    },
                    child: Text('保存する'),
                  )
                ],
              );
            }),
      ),
    );
  }
}

Future _showDialog(
  BuildContext context,
  String title,
) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          )
        ],
      );
    },
  );
}
