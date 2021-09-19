import 'package:chat_app/model/message.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class TalkRoom extends StatefulWidget {
  final String name;
  final String imagePath;
  TalkRoom(this.name, this.imagePath);

  @override
  _TalkRoomState createState() => _TalkRoomState();
}

class _TalkRoomState extends State<TalkRoom> {
  List<Message> messageList = [
    Message(
      message: 'あいうえお',
      isMe: true,
      sendTime: DateTime(2020, 1, 1, 10, 20),
    ),
    Message(
      message: 'かきくけこ',
      isMe: false,
      sendTime: DateTime(2020, 1, 1, 11, 15),
    ),
    Message(
      message:
          'さしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそ',
      isMe: false,
      sendTime: DateTime(2020, 1, 1, 11, 15),
    ),
    Message(
      message:
          'さしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそ',
      isMe: false,
      sendTime: DateTime(2020, 1, 1, 11, 15),
    ),
    Message(
      message:
          'さしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそさしすせそ',
      isMe: false,
      sendTime: DateTime(2020, 1, 1, 11, 15),
    )
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 70.0),
              child: ListView.builder(
                  physics: RangeMaintainingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: messageList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                          top: 10.0,
                          right: 10,
                          left: 10,
                          bottom: index == 0 ? 10 : 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        textDirection: messageList[index].isMe!
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        children: [
                          messageList[index].isMe!
                              ? SizedBox()
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(widget.imagePath),
                                    radius: 20,
                                  ),
                                ),
                          Container(
                              constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.6),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: messageList[index].isMe!
                                    ? Colors.green[200]
                                    : Colors.white,
                              ),
                              child: Text(messageList[index].message!)),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Text(
                              intl.DateFormat('HH:mm')
                                  .format(messageList[index].sendTime!),
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 70,
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: InputDecoration(border: OutlineInputBorder()),
                    ),
                  )),
                  IconButton(
                      onPressed: () {
                        print('送信');
                      },
                      icon: Icon(Icons.send))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
