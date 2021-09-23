import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String? message;
  bool? isMe;
  Timestamp? sendTime;

  Message({this.message, this.isMe, this.sendTime});
}
