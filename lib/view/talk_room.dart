import 'dart:io';

import 'package:chat_app/model/message.dart';
import 'package:chat_app/model/talk_room.dart';
import 'package:chat_app/view/send_image_display.dart';
import 'package:chat_app/utils/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' as intl;

class TalkRoomPage extends StatefulWidget {
  final TalkRoom? room;
  TalkRoomPage(this.room);

  @override
  _TalkRoomPageState createState() => _TalkRoomPageState();
}

class _TalkRoomPageState extends State<TalkRoomPage> {
  bool isLoading = false;
  List<Message>? messageList = [];
  TextEditingController controller = TextEditingController();
  bool confirmImage = true;

  File? image;
  ImagePicker picker = ImagePicker();
  String? imagePath;

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
        .ref('${image?.path}.${FirebaseAuth.instance.currentUser?.uid}');
    final storedImage = await ref.putFile(image!);
    imagePath = await loadImage(storedImage);
    return imagePath;
  }

  Future<String?> loadImage(TaskSnapshot storedImage) async {
    String downloadUrl = await storedImage.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> getMessages() async {
    messageList = await Firestore.getMessages(widget.room!.roomId!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        title: Text(widget.room!.talkUser!.name ?? 'Noname'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 70.0),
            child: StreamBuilder<QuerySnapshot>(
                stream: Firestore.messageSnapshot(widget.room!.roomId!),
                builder: (context, snapshot) {
                  return FutureBuilder(
                      future: getMessages(),
                      builder: (context, snapshot) {
                        return ListView.builder(
                            reverse: true,
                            physics: RangeMaintainingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: messageList!.length,
                            itemBuilder: (context, index) {
                              Message _message = messageList![index];
                              DateTime sendTime = _message.sendTime!.toDate();
                              return Padding(
                                padding: EdgeInsets.only(
                                    top: 20.0,
                                    right: 10,
                                    left: 10,
                                    bottom: index == 0 ? 10 : 0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  textDirection: _message.isMe!
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
                                  children: [
                                    _message.isMe!
                                        ? SizedBox()
                                        : Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  widget.room!.talkUser!
                                                      .imagePath!),
                                              radius: 20,
                                              backgroundColor: Colors.white,
                                            ),
                                          ),
                                    // 投稿を長押しした時にアラートを出す
                                    GestureDetector(
                                      onLongPress: () {
                                        showDialog(
                                          context: context,
                                          builder: (childContext) {
                                            return SimpleDialog(
                                              backgroundColor: Colors.white,
                                              title: Text("投稿を削除しますか？"),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(20))),
                                              children: <Widget>[
                                                SimpleDialogOption(
                                                  onPressed: () async {
                                                    Navigator.pop(childContext);
                                                    try {
                                                      await Firestore
                                                          .deleteMessage(
                                                              widget.room!
                                                                  .roomId!,
                                                              messageList![
                                                                      index]
                                                                  .messageId!);
                                                    } catch (e) {
                                                      e.toString();
                                                    }

                                                    setState(() {});
                                                  },
                                                  child: Text('削除'),
                                                ),
                                                SimpleDialogOption(
                                                  onPressed: () {
                                                    Navigator.pop(childContext);
                                                  },
                                                  child: Text('キャンセル'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: Container(
                                        constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.6),
                                        padding: _message.image == null
                                            ? EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 6)
                                            : null,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: _message.isMe!
                                              ? Colors.green[200]
                                              : Colors.white,
                                        ),
                                        child: _message.message != null
                                            ? Text(_message.message!)
                                            : InkWell(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            SendImageDisplay(
                                                                _message.image),
                                                        fullscreenDialog: true),
                                                  );
                                                },
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                  child: Image.network(
                                                    _message.image!,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, right: 8.0),
                                      child: Text(
                                        intl.DateFormat('HH:mm')
                                            .format(sendTime),
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            });
                      });
                }),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 70,
              color: Colors.white,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: IconButton(
                        onPressed: () async {
                          Firestore.startLoading();
                          setState(() {});
                          try {
                            await getImageFromGallery();
                            await Firestore.sendImage(
                                widget.room!.roomId!, imagePath!);
                          } catch (e) {} finally {
                            Firestore.endloading();
                            setState(() {});
                          }
                        },
                        icon: Icon(Icons.photo_outlined),
                        color: Colors.black),
                  ),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10.0, bottom: 8.0, top: 8.0),
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(border: OutlineInputBorder()),
                    ),
                  )),
                  IconButton(
                    onPressed: () async {
                      print('送信');
                      if (controller.text.isNotEmpty) {
                        final String? myUid =
                            FirebaseAuth.instance.currentUser!.uid;
                        await Firestore.sendMessage(
                            widget.room!.roomId!, controller.text);
                        Firestore.getProfile(myUid!);
                        controller.clear();
                      }
                    },
                    icon: Icon(Icons.send),
                    color: Colors.black,
                  )
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
