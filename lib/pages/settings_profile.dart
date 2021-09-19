import 'package:flutter/material.dart';

class SettingsProfilePage extends StatefulWidget {
  @override
  _SettingsProfilePageState createState() => _SettingsProfilePageState();
}

class _SettingsProfilePageState extends State<SettingsProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('プロフィール画面'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(width: 120, child: Text('名前')),
                Expanded(
                  child: TextField(),
                )
              ],
            ),
            SizedBox(height: 50),
            Row(
              children: [
                Container(width: 120, child: Text('プロフィール画像')),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: Container(
                      width: 150,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {},
                        child: Text('画像を選択'),
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
