import 'package:chat_app/model/talk_room.dart';
import 'package:chat_app/model/user.dart';
import 'package:chat_app/utils/firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileImagePage extends StatefulWidget {
  final Users? profile;
  ProfileImagePage(this.profile);

  @override
  _ProfileImagePageState createState() => _ProfileImagePageState();
}

class _ProfileImagePageState extends State<ProfileImagePage> {
  List<TalkRoom>? talkUserList = [];

  Future<void> createRooms() async {
    String? myUid = FirebaseAuth.instance.currentUser!.uid;
    talkUserList = await Firestore.getRooms(myUid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: Center(
          child: Container(
            child: Image.network(widget.profile?.imagePath ?? ''),
          ),
        ));
  }
}
