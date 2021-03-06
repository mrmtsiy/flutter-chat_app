import 'package:chat_app/view/group_page.dart';
import 'package:chat_app/view/talk_list_page.dart';
import 'package:chat_app/view/top_page.dart';

import 'package:flutter/material.dart';

class RoutePage extends StatefulWidget {
  @override
  _RoutePageState createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  @override
  // ignore: override_on_non_overriding_member
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  Future<void> currentPage(int index) async {
    _currentIndex = index;
    setState(() {});
  }

  static final List<Widget> _pageList = <Widget>[
    TopPage(),
    TalkListPage(),
    GroupPage(),
  ];

  Widget build(BuildContext context) {
    return Scaffold(
      body: _pageList[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue[100],
        // 選択中のアイコンを更新する。
        currentIndex: _currentIndex,

        onTap: (index) {
          // indexで今タップしたアイコンの番号にアクセス
          currentPage(index);
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Talk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Group',
          ),
        ],
      ),
    );
  }
}
