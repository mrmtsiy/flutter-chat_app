import 'package:chat_app/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  String? groupImage;
  String? groupName;
  List? member;
  String? groupId;
  List<Users>? talkUser;
  String? lastMessage;
  Timestamp? lastMessageTime;

  Group(
      {this.member,
      this.groupImage,
      this.groupName,
      this.groupId,
      this.talkUser,
      this.lastMessage,
      this.lastMessageTime});
}
