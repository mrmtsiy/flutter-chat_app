import 'package:chat_app/model/user.dart';
import 'package:chat_app/pages/settings_profile.dart';
import 'package:chat_app/pages/talk_room.dart';
import 'package:flutter/material.dart';

class TopPage extends StatefulWidget {
  @override
  _TopPageState createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  List<User> userList = [
    User(
      name: 'ルフィ',
      uid: 'abc',
      imagePath:
          'https://yt3.ggpht.com/ytc/AKedOLRBntMXxB8M_HgM3uxtQ9256MlF8y4cX-OvfzjUng=s900-c-k-c0x00ffffff-no-rj',
      lastMessage: '海賊王に俺はなる',
    ),
    User(
      name: 'サンジ',
      uid: 'def',
      imagePath:
          'https://stickershop.line-scdn.net/stickershop/v1/product/15056934/LINEStorePC/main.png;compress=true',
      lastMessage: 'レディーには手は出さん',
    ),
    User(
      name: 'ゾロ',
      uid: 'ghi',
      imagePath: 'https://pbs.twimg.com/media/EJDt6a9UEAAyFnr.jpg',
      lastMessage: '背中の傷は剣士の恥だ',
    )
  ];
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
        body: ListView.builder(
            itemCount: userList.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TalkRoom(userList[index].name!,
                              userList[index].imagePath!)));
                },
                child: Container(
                  height: 70,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: CircleAvatar(
                          backgroundImage:
                              NetworkImage(userList[index].imagePath!),
                          radius: 30,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            userList[index].name!,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            userList[index].lastMessage!,
                            style: TextStyle(color: Colors.grey),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              );
            }));
  }
}
