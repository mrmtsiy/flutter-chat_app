import 'package:chat_app/model/user.dart';

class TalkRoom {
  String? roomId;
  User? talkUser;
  String? lastMessage;

  TalkRoom({this.roomId, this.talkUser, this.lastMessage});
}
