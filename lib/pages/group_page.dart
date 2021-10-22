import 'package:chat_app/model/group.dart';
import 'package:chat_app/model/member.dart';
import 'package:chat_app/pages/group_create_page.dart';
import 'package:chat_app/utils/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart' as intl;

class GroupPage extends StatefulWidget {
  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  List<Group>? groupList = [];
  List<Member>? memberList = [];

  Future<void> getGroup() async {
    String? myUid = FirebaseAuth.instance.currentUser!.uid;
    groupList = await Firestore.getGroup(myUid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('グループ'),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.search))],
        leading: IconButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => GroupCreatePage()));
          },
          icon: Icon(Icons.add),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: Firestore.groupSnapshot(),
          builder: (context, snapshot) {
            return FutureBuilder(
              future: getGroup(),
              builder: (context, snapshot) {
                groupList?.sort((a, b) => b.lastMessageTime!
                    .toDate()
                    .compareTo(a.lastMessageTime!.toDate()));
                if (snapshot.connectionState == ConnectionState.done) {
                  return ListView.builder(
                    itemCount: groupList?.length,
                    itemBuilder: (context, index) {
                      String? myUid = FirebaseAuth.instance.currentUser!.uid;
                      Group _group = groupList![index];
                      DateTime lastMessageTime =
                          groupList![index].lastMessageTime!.toDate();
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

                      if (groupList![index].member!.contains(myUid)) {
                        return InkWell(
                          onTap: () {
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) =>
                            //             TalkRoomPage(groupList?[index])));
                          },
                          child: Slidable(
                            actionPane: SlidableDrawerActionPane(),
                            actionExtentRatio: 0.25,
                            secondaryActions: [
                              IconSlideAction(
                                caption: '招待する',
                                color: Colors.green,
                                icon: Icons.add,
                                onTap: () async {},
                              ),
                              IconSlideAction(
                                caption: '退会する',
                                color: Colors.red,
                                icon: Icons.remove,
                                onTap: () async {
                                  showDialog(
                                    context: context,
                                    builder: (childContext) {
                                      return SimpleDialog(
                                        backgroundColor: Colors.white,
                                        title: Text("グループを退会してもよろしいでしょうか？"),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20))),
                                        children: <Widget>[
                                          SimpleDialogOption(
                                            onPressed: () async {
                                              Navigator.pop(childContext);
                                              try {
                                                final myUid = FirebaseAuth
                                                    .instance.currentUser?.uid;
                                                await Firestore.leaveGroup(
                                                    groupList![index].groupId!,
                                                    myUid!);
                                              } catch (e) {
                                                e.toString();
                                              }

                                              setState(() {});
                                            },
                                            child: Text('グループを退会する'),
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
                              ),
                            ],
                            child: Container(
                              height: 70,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12.0),
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(groupList![
                                                  index]
                                              .groupImage ??
                                          'https://upload.wikimedia.org/wikipedia/commons/thumb/7/75/Netflix_icon.svg/2048px-Netflix_icon.svg.png'),
                                      radius: 30,
                                      backgroundColor: Colors.white,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 200,
                                        child: Text(
                                          groupList![index].groupName ??
                                              'NoName',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Text(
                                        'メンバー ${_group.member?.length}人',
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
                                      groupList![index].lastMessage != ''
                                          ? fromAtNow(lastMessageTime)
                                          : '',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      } else {
                        return SizedBox.shrink();
                      }
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
