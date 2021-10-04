import 'package:chat_app/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TalkRoom {
  String? roomId;
  Users? talkUser;
  String? lastMessage;
  Timestamp? lastMessageTime;

  TalkRoom(
      {this.roomId, this.talkUser, this.lastMessage, this.lastMessageTime});
}
