import 'package:chat_app/model/message.dart';
import 'package:chat_app/model/talk_room.dart';
import 'package:chat_app/utils/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  Future<void> getMessages() async {
    messageList = await Firestore.getMessages(widget.room!.roomId!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        title: Text(widget.room!.talkUser!.name!),
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
                                    top: 10.0,
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
                                            ),
                                          ),
                                    Container(
                                        constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.6),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: _message.isMe!
                                              ? Colors.green[200]
                                              : Colors.white,
                                        ),
                                        child: Text(_message.message!)),
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
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(
                        left: 20.0, bottom: 8.0, top: 8.0),
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
                      icon: Icon(Icons.send))
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
            )
        ],
      ),
    );
  }
}
