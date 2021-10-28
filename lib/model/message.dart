import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String? message;
  String? image;
  bool? isMe;
  Timestamp? sendTime;
  String? messageId;
  String? senderId;

  Message(
      {this.message,
      this.isMe,
      this.sendTime,
      this.image,
      this.messageId,
      this.senderId});
}
