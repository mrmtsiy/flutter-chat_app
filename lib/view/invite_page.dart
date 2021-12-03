import 'package:chat_app/model/group.dart';
import 'package:chat_app/model/talk_room.dart';
import 'package:chat_app/utils/firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class InvitePage extends StatefulWidget {
  final Group? invite;
  InvitePage(this.invite);

  @override
  _InvitePageState createState() => _InvitePageState();
}

class _InvitePageState extends State<InvitePage> {
  List<TalkRoom>? talkUserList = [];

  // 選択された要素のインデックスを保管する

  Future<void> createRooms() async {
    String? myUid = FirebaseAuth.instance.currentUser!.uid;
    talkUserList = await Firestore.getRooms(myUid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('グループに招待する'),
      ),
      body: FutureBuilder(
        future: createRooms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ListView.builder(
              itemCount: talkUserList?.length,
              itemBuilder: (context, index) {
                //表示時間

                return InkWell(
                  onTap: () async {
                    Navigator.of(context).pop();
                    await Firestore.inviteGroup(
                        widget.invite!.groupName!,
                        widget.invite!.groupImage!,
                        widget.invite!.groupId!,
                        talkUserList![index].talkUser!);
                  },
                  child: Container(
                    height: 70,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(
                                talkUserList![index].talkUser!.imagePath ?? ''),
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
                                talkUserList![index].talkUser!.name ?? 'NoName',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
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
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
