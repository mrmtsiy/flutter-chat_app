import 'package:chat_app/utils/firebase.dart';
import 'package:flutter/material.dart';

class GroupCreatePage extends StatefulWidget {
  @override
  _GroupCreatePageState createState() => _GroupCreatePageState();
}

class _GroupCreatePageState extends State<GroupCreatePage> {
  TextEditingController controller = TextEditingController();
  String _infoText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('グループの作成'),
      ),
      body: Center(
        child: Container(
          child: Column(
            children: [
              SizedBox(height: 100),
              Stack(
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[200],
                    ),
                  ),
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: FloatingActionButton(
                      heroTag: "グループ画像の設定",
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.photo,
                        size: 30,
                        color: Colors.black,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              SizedBox(height: 80),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: TextField(
                          controller: controller,
                          maxLines: 1,
                          decoration: InputDecoration(
                            hintText: 'グループ名を記入してください',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(width: 0.0),
                              borderRadius:
                                  BorderRadius.all(const Radius.circular(0)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    FloatingActionButton(
                        heroTag: "グループの作成",
                        backgroundColor: Colors.white,
                        onPressed: () async {
                          if (controller.text.isNotEmpty) {
                            await Firestore.createGroup(controller.text);
                            Navigator.pop(context);
                            _infoText = 'グループを作成しました';
                            setState(() {});
                            final snackBar = SnackBar(
                                backgroundColor: Colors.green,
                                content: Text(_infoText));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          } else {
                            _infoText = 'グループ名を決めてください';
                            setState(() {});
                            final snackBar = SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(_infoText));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                        },
                        child: Icon(
                          Icons.add,
                          color: Colors.black,
                        ))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
