import 'package:cloud_firestore/cloud_firestore.dart';

class Firestore {
  static FirebaseFirestore _firestoreInstance = FirebaseFirestore.instance;
  static final userRef = _firestoreInstance.collection('user');
  static final roomRef = _firestoreInstance.collection('room');

  static Future<void> addUser() async {
    try {
      final newDoc = await userRef.add({
        'name': 'NoName',
        'image_path':
            'https://images-fe.ssl-images-amazon.com/images/I/41vCDELt1xL.jpg',
      });
      print('アカウント作成完了');

      List<String>? userIds = await getUser();
      userIds!.forEach((user) async {
        // newDocは作成した自身のアカウント
        if (user != newDoc.id) {
          await roomRef.add({
            'joined_user_ids': [user, newDoc.id],
            'updated_time': Timestamp.now()
          });
        }
      });
      print('ルーム作成が完了しました');
    } catch (e) {
      print('失敗しました');
    }
  }

  static Future<List<String>?> getUser() async {
    try {
      final snapshot = await userRef.get();
      List<String> userIds = [];
      snapshot.docs.forEach((user) {
        userIds.add(user.id);
        print('ドキュメントID: ${user.id} --- 名前: ${user.data()['name']}');
      });
      return userIds;
    } catch (e) {
      print('取得失敗');
      return null;
    }
  }
}
