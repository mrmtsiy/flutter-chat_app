import 'package:chat_app/model/group.dart';
import 'package:chat_app/utils/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

//招待されているグループのページ
class InvitedPage extends StatefulWidget {
  @override
  _InvitedPageState createState() => _InvitedPageState();
}

class _InvitedPageState extends State<InvitedPage> {
  List<Group>? invitedList = [];

  // 選択された要素のインデックスを保管する

  Future<void> getInvitation() async {
    String? myUid = FirebaseAuth.instance.currentUser!.uid;
    invitedList = await Firestore.getInvitation(myUid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('招待されているグループ'),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: Firestore.invitedsnapshot(),
          builder: (context, snapshot) {
            return FutureBuilder(
              future: getInvitation(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return ListView.builder(
                    itemCount: invitedList?.length,
                    itemBuilder: (context, index) {
                      //表示時間

                      return Container(
                        height: 70,
                        child: Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12.0),
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(invitedList?[
                                            index]
                                        .groupImage ??
                                    'https://www.silhouette-illust.com/wp-content/uploads/2016/10/13707-300x300.jpg'),
                                radius: 30,
                                backgroundColor: Colors.white,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 170,
                                  child: Text(
                                    invitedList?[index].groupName ?? 'NoName',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: () async {
                                Navigator.of(context).pop();
                                try {
                                  String? myUid =
                                      FirebaseAuth.instance.currentUser?.uid;
                                  await Firestore.joinGroup(
                                      invitedList![index].groupId!, myUid!);
                                } catch (e) {
                                  print(e.toString());
                                }
                              },
                              child: Container(
                                width: 70,
                                height: 70,
                                child: Center(child: Text('参加する')),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                width: 70,
                                height: 70,
                                child: Center(child: Text('拒否する')),
                              ),
                            )
                          ],
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
