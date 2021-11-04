import 'package:chat_app/model/talk_room.dart';
import 'package:chat_app/pages/current_user_profile_page.dart';
import 'package:chat_app/pages/profile_image_page.dart';
import 'package:chat_app/pages/talk_room.dart';
import 'package:chat_app/utils/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TopPage extends StatefulWidget {
  @override
  _TopPageState createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  List<TalkRoom>? talkUserList = [];

  Future<void> createRooms() async {
    String? myUid = FirebaseAuth.instance.currentUser!.uid;
    talkUserList = await Firestore.getRooms(myUid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ユーザーリスト'),
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
          stream: Firestore.roomSnapshot(),
          builder: (context, snapshot) {
            return FutureBuilder(
              future: createRooms(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return ListView.builder(
                    itemCount: talkUserList?.length,
                    itemBuilder: (context, index) {
                      //表示時間

                      return InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        IconButton(
                                            color: Colors.red,
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            icon: Icon(Icons.cancel)),
                                      ],
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ProfileImagePage(
                                                      talkUserList![index]
                                                          .talkUser),
                                              fullscreenDialog: true),
                                        );
                                      },
                                      child: CircleAvatar(
                                        radius: 80,
                                        backgroundImage: NetworkImage(
                                          talkUserList![index]
                                                  .talkUser!
                                                  .imagePath ??
                                              'https://freesvg.org/img/abstract-user-flat-1.png',
                                        ),
                                        backgroundColor: Colors.white,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 50,
                                    ),
                                    Text(
                                      talkUserList![index].talkUser!.name ??
                                          'NoName',
                                      style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    Center(
                                      child: Container(
                                        width: 300,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              spreadRadius: 1.0,
                                              blurRadius: 10.0,
                                              offset: Offset(10, 10),
                                            ),
                                          ],
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.of(context)
                                                .pushReplacement(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            TalkRoomPage(
                                                                talkUserList![
                                                                    index])));
                                          },
                                          child: Card(
                                            color: Colors.white,
                                            child: Center(
                                              child: Text('トークする'),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10.0),
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
                                                .imagePath ??
                                            ''),
                                    radius: 30,
                                    backgroundColor: Colors.white,
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 200,
                                      child: Text(
                                        talkUserList![index].talkUser!.name ??
                                            'NoName',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 60,
                                ),
                              ],
                            ),
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
