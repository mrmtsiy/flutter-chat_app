import 'dart:io';

import 'package:chat_app/utils/firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class GroupCreatePage extends StatefulWidget {
  @override
  _GroupCreatePageState createState() => _GroupCreatePageState();
}

class _GroupCreatePageState extends State<GroupCreatePage> {
  bool isLoading = false;
  TextEditingController controller = TextEditingController();
  File? image;
  ImagePicker picker = ImagePicker();
  String? imagePath;
  String _infoText = '';

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
    return Scaffold(
      appBar: AppBar(
        title: Text('グループの作成'),
      ),
      body: Stack(
        children: [
          Center(
            child: Container(
              child: Column(
                children: [
                  SizedBox(height: 100),
                  Stack(
                    children: [
                      image == null
                          ? Container(
                              width: 200,
                              height: 200,
                              child: CircleAvatar(
                                backgroundColor: Colors.grey[200],
                              ),
                            )
                          : Container(
                              width: 200,
                              height: 200,
                              child: CircleAvatar(
                                  backgroundImage: NetworkImage(imagePath!)),
                            ),
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: FloatingActionButton(
                          heroTag: "グループ画像の設定",
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.photo,
                            size: 30,
                            color: Colors.black,
                          ),
                          onPressed: () async {
                            Firestore.startLoading();
                            setState(() {});
                            try {
                              await getImageFromGallery();
                            } catch (e) {} finally {
                              Firestore.endloading();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 80),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: TextField(
                              controller: controller,
                              maxLines: 1,
                              decoration: InputDecoration(
                                hintText: 'グループ名を記入してください',
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(width: 0.0),
                                  borderRadius: BorderRadius.all(
                                      const Radius.circular(0)),
                                ),
                              ),
                            ),
                          ),
                        ),
                        FloatingActionButton(
                          heroTag: "グループの作成",
                          backgroundColor: Colors.white,
                          onPressed: () async {
                            if (controller.text.isNotEmpty) {
                              await Firestore.createGroup(
                                  controller.text,
                                  imagePath ??
                                      'https://www.silhouette-illust.com/wp-content/uploads/2016/10/13707-300x300.jpg');
                              Navigator.pop(context);
                              _infoText = 'グループを作成しました';
                              setState(() {});
                              final snackBar = SnackBar(
                                  backgroundColor: Colors.green,
                                  content: Text(_infoText));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            } else {
                              _infoText = 'グループ名を決めてください';
                              setState(() {});
                              final snackBar = SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text(_infoText));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            }
                          },
                          child: Icon(
                            Icons.add,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(),
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
