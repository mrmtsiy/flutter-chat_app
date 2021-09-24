import 'package:chat_app/model/talk_room.dart';
import 'package:chat_app/pages/settings_profile.dart';
import 'package:chat_app/pages/talk_room.dart';
import 'package:chat_app/utils/firebase.dart';
import 'package:chat_app/utils/shared_prefs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class TopPage extends StatefulWidget {
  @override
  _TopPageState createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  List<TalkRoom>? talkUserList = [];

  Future<void> createRooms() async {
    String? myUid = SharedPrefs.getUid();
    talkUserList = await Firestore.getRooms(myUid!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('チャットアプリ'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsProfilePage(),
                  ),
                );
              },
              icon: Icon(Icons.settings))
        ],
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
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
                                width: 80,
                              ),
                              Text(intl.DateFormat('HH:mm')
                                  .format(lastMessageTime))
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
