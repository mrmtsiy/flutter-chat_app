import 'dart:io';

import 'package:chat_app/model/user.dart';
import 'package:chat_app/utils/firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SettingsProfilePage extends StatefulWidget {
  SettingsProfilePage(this.name, this.profileImage) {
    controller.text = name ?? '';
  }
  final TextEditingController controller = TextEditingController();
  final String? name;
  final String? profileImage;

  @override
  _SettingsProfilePageState createState() => _SettingsProfilePageState();
}

class _SettingsProfilePageState extends State<SettingsProfilePage> {
  File? image;
  ImagePicker picker = ImagePicker();
  String? imagePath;

  User? currentUser;
  String infoText = '';

  Future<void> getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      image = File(pickedFile.path);
      await uploadImage();
      setState(() {});
    }
  }

  Future<String?> uploadImage() async {
    final ref = FirebaseStorage.instance
        .ref('${FirebaseAuth.instance.currentUser?.uid}.png');
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
        title: Text('プロフィール編集画面'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: FutureBuilder(
                future: Auth.fetchUser(myUid!),
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
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                              ),
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
                              decoration: InputDecoration(
                                  hintText: Auth.name ?? 'ユーザー名が登録されていません'),
                              controller: widget.controller,
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
                                  onPressed: () async {
                                    Firestore.startLoading();
                                    setState(() {});
                                    try {
                                      await getImageFromGallery();
                                    } catch (e) {} finally {
                                      Firestore.endloading();
                                    }
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
                          Users newProfile = Users(
                            name: widget.controller.text,
                            imagePath: imagePath ?? widget.profileImage,
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
