import 'package:flutter/material.dart';

class SendImageDisplay extends StatefulWidget {
  final String? image;
  SendImageDisplay(this.image);

  @override
  _SendImageDisplayState createState() => _SendImageDisplayState();
}

class _SendImageDisplayState extends State<SendImageDisplay> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: Center(
          child: Container(
            child: Image.network(widget.image ?? ''),
          ),
        ));
  }
}
