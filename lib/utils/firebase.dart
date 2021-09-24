import 'package:chat_app/model/message.dart';
import 'package:chat_app/model/talk_room.dart';
import 'package:chat_app/model/user.dart';
import 'package:chat_app/utils/shared_prefs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Firestore {
  static FirebaseFirestore _firestoreInstance = FirebaseFirestore.instance;
  static final userRef = _firestoreInstance.collection('user');
  static final roomRef = _firestoreInstance.collection('room');
  static final roomSnapshot = roomRef.snapshots();

  static Future<void> addUser() async {
    try {
      final newDoc = await userRef.add({
        'name': 'NoName',
        'image_path':
            'https://images-fe.ssl-images-amazon.com/images/I/41vCDELt1xL.jpg',
      });
      print('アカウント作成完了');

      //作成したユーザーを端末に保存する
      await SharedPrefs.setUid(newDoc.id);

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

  static Future<User?> getProfile(String uid) async {
    final profile = await userRef.doc(uid).get();
    User myProfile = User(
      name: profile.data()!['name'],
      imagePath: profile.data()!['image_path'],
      uid: uid,
    );
    return myProfile;
  }

  static Future<List<TalkRoom>?> getRooms(String myUid) async {
    final snapshot = await roomRef.get();
    List<TalkRoom>? roomList = [];
    await Future.forEach(snapshot.docs, (dynamic doc) async {
      if (doc.data()['joined_user_ids'].contains(myUid)) {
        String? yourUid;
        doc.data()['joined_user_ids'].forEach((id) {
          if (id != myUid) {
            yourUid = id;
            return;
          }
        });
        User? yourProfile = await getProfile(yourUid!);
        TalkRoom room = TalkRoom(
            roomId: doc.id,
            talkUser: yourProfile,
            lastMessage: doc.data()['last_message'] ?? '',
            lastMessageTime: doc.data()['updated_time']);
        roomList.add(room);
      }
    });

    return roomList;
  }

  static Future<List<Message>?> getMessages(String roomId) async {
    final messageRef = roomRef.doc(roomId).collection('message');
    List<Message>? messageList = [];
    final snapshot = await messageRef.get();
    Future.forEach(snapshot.docs, (dynamic doc) {
      bool isMe;
      String? myUid = SharedPrefs.getUid();
      if (doc.data()['sender_id'] == myUid) {
        isMe = true;
      } else {
        isMe = false;
      }
      Message message = Message(
        message: doc.data()['message'],
        isMe: isMe,
        sendTime: doc.data()['send_time'],
      );
      messageList.add(message);
    });
    messageList.sort((a, b) => b.sendTime!.compareTo(a.sendTime!));
    return messageList;
  }

  static Future<void> sendMessage(String roomId, String message) async {
    final messageRef = roomRef.doc(roomId).collection('message');
    String? myUid = SharedPrefs.getUid();
    await messageRef.add({
      'message': message,
      'send_id': myUid,
      'send_time': Timestamp.now(),
    });

    roomRef.doc(roomId).update({
      'last_message': message,
      'updated_time': Timestamp.now(),
    });
  }

  static Stream<QuerySnapshot>? messageSnapshot(String roomId) {
    return roomRef.doc(roomId).collection('message').snapshots();
  }
}
