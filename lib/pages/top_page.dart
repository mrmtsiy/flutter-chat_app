import 'package:chat_app/model/talk_room.dart';
import 'package:chat_app/pages/current_user_profile_page.dart';
import 'package:chat_app/pages/login.dart';
import 'package:chat_app/pages/register.dart';
import 'package:chat_app/pages/talk_room.dart';
import 'package:chat_app/utils/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class TopPage extends StatefulWidget {
  @override
  _TopPageState createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  List<TalkRoom>? talkUserList = [];
  final List<Widget> pageList = <Widget>[
    TopPage(),
    LoginPage(),
    RegisterPage(),
  ];

  Future<void> createRooms() async {
    String? myUid = FirebaseAuth.instance.currentUser!.uid;
    talkUserList = await Firestore.getRooms(myUid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('トークリスト'),
        actions: [
          IconButton(
              onPressed: () {
                // if (FirebaseAuth.instance.currentUser != null) {
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => SettingsProfilePage(),
                //     ),
                //   );
                //   print('ログインしている');
                // } else {
                //   print('ログインしていない');
                // }
              },
              icon: Icon(Icons.settings))
        ],
        leading: IconButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CurrentUserProfilePage()));
          },
          icon: Icon(Icons.person),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: Firestore.roomSnapshot,
          builder: (context, snapshot) {
            return FutureBuilder(
              future: createRooms(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return ListView.builder(
                    itemCount: talkUserList!.length,
                    itemBuilder: (context, index) {
                      DateTime lastMessageTime =
                          talkUserList![index].lastMessageTime!.toDate();
                      //表示時間
                      String fromAtNow(DateTime date) {
                        final Duration difference =
                            DateTime.now().difference(date);
                        final int sec = difference.inSeconds;

                        if (sec >= 60 * 60 * 24 * 2) {
                          return intl.DateFormat('MM/dd')
                              .format(lastMessageTime);
                        } else if (sec >= 60 * 60 * 24) {
                          return '昨日';
                        } else if (sec >= 60 * 60) {
                          return '${difference.inHours.toString()}時間前';
                        } else if (sec >= 60) {
                          return '${difference.inMinutes.toString()}分前';
                        } else {
                          return '$sec秒前';
                        }
                      }

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      TalkRoomPage(talkUserList![index])));
                        },
                        child: Container(
                          height: 70,
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0),
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      talkUserList![index]
                                          .talkUser!
                                          .imagePath!),
                                  radius: 30,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 200,
                                    child: Text(
                                      talkUserList![index].talkUser!.name!,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Text(
                                    talkUserList![index].lastMessage!,
                                    style: TextStyle(color: Colors.grey),
                                  )
                                ],
                              ),
                              SizedBox(
                                width: 60,
                              ),
                              Container(
                                  width: 60,
                                  alignment: Alignment.center,
                                  child: Text(
                                    fromAtNow(lastMessageTime),
                                    style: TextStyle(color: Colors.grey),
                                  ))
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            );
          }),
    );
  }
}
