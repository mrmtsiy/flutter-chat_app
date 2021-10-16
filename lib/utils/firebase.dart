import 'package:chat_app/model/message.dart';
import 'package:chat_app/model/talk_room.dart';
import 'package:chat_app/model/user.dart';
import 'package:chat_app/utils/shared_prefs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Firestore {
  static bool isLoading = false;

  static Future<void> startLoading() async {
    isLoading = true;
  }

  static Future<void> endloading() async {
    isLoading = false;
  }

  static FirebaseFirestore _firestoreInstance = FirebaseFirestore.instance;
  static final userRef = _firestoreInstance.collection('user');
  static final roomRef = _firestoreInstance.collection('room');
  // static final roomSnapshot = roomRef.snapshots();

  static Future<void> addUser() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser!;
      // final newDoc = await userRef.add({
      //   'name': 'NoName',
      //   'image_path':
      //       'https://images-fe.ssl-images-amazon.com/images/I/41vCDELt1xL.jpg',
      //   'uid': myUid,
      // });
      print('アカウント作成完了');

      //作成したユーザーを端末に保存する
      await SharedPrefs.setUid(currentUser.uid);

      List<String>? userIds = await getUsers();
      userIds?.forEach((user) async {
        // newDocは作成した自身のアカウント
        if (user != currentUser.uid) {
          await roomRef.add({
            'joined_user_ids': [user, currentUser.uid],
            'updated_time': Timestamp.now()
          });
        }
      });
      print('ルーム作成が完了しました');
    } catch (e) {
      print('失敗しました');
    }
  }

  static Future<void> setRoom() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    List<String>? userIds = await getUsers();
    userIds?.forEach((user) async {
      if (user != currentUser?.uid) {
        await roomRef.add({
          'joined_user_ids': [user, currentUser?.uid],
          'updated_time': Timestamp.now()
        });
      }
    });
  }

  static Future<List<String>?> getUsers() async {
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

  static Future<Users?> getProfile(String uid) async {
    final profile = await userRef.doc(uid).get();
    Users myProfile = Users(
      name: profile.data()?['name'],
      imagePath: profile.data()?['image_path'],
      uid: uid,
    );
    return myProfile;
  }

  static Future<void> updateProfile(Users newProfile) async {
    String? myUid = FirebaseAuth.instance.currentUser?.uid;
    await userRef.doc(myUid).update({
      'name': newProfile.name,
      'image_path': newProfile.imagePath,
    });
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
        Users? yourProfile = await getProfile(yourUid!);
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
      String? myUid = FirebaseAuth.instance.currentUser?.uid;
      if (doc.data()['sender_id'] == myUid) {
        isMe = true;
      } else {
        isMe = false;
      }
      Message message = Message(
        message: doc.data()['message'],
        image: doc.data()['image'],
        isMe: isMe,
        sendTime: doc.data()['send_time'],
        messageId: doc.id,
      );
      messageList.add(message);
    });
    messageList.sort((a, b) => b.sendTime!.compareTo(a.sendTime!));
    return messageList;
  }

  static Future<void> sendMessage(String roomId, String message) async {
    final messageRef = roomRef.doc(roomId).collection('message');
    final id = messageRef.doc().id;
    String? myUid = FirebaseAuth.instance.currentUser?.uid;
    await messageRef.doc(id).set({
      'message': message,
      'sender_id': myUid,
      'send_time': Timestamp.now(),
      'messageId': id,
    });

    roomRef.doc(roomId).update({
      'last_message': message,
      'updated_time': Timestamp.now(),
    });
  }

  static Future<void> sendImage(String roomId, String image) async {
    final messageRef = roomRef.doc(roomId).collection('message');
    final id = messageRef.doc().id;
    String? myUid = FirebaseAuth.instance.currentUser?.uid;
    await messageRef.doc(id).set({
      'image': image,
      'sender_id': myUid,
      'send_time': Timestamp.now(),
      'messageId': id,
    });

    roomRef.doc(roomId).update({
      'last_message': '画像を送信しました',
      'updated_time': Timestamp.now(),
    });
  }

  static Future<void> deleteMessage(String roomId, String messageId) async {
    print(messageId);
    await roomRef.doc(roomId).collection('message').doc(messageId).delete();

    roomRef.doc(roomId).update({
      'last_message': '投稿を削除しました',
      'updated_time': Timestamp.now(),
    });
  }

  static Stream<QuerySnapshot>? messageSnapshot(String roomId) {
    return roomRef.doc(roomId).collection('message').snapshots();
  }

  static Stream<QuerySnapshot>? roomSnapshot() {
    return roomRef.snapshots();
  }
}

class Auth {
  static String? email;
  static String? name;
  static String? profileImage;

  static final FirebaseAuth auth = FirebaseAuth.instance;

  static Future<void> logOut() async {
    await FirebaseAuth.instance.signOut();
  }

  static Future<void> fetchUser(String uid) async {
    final user = auth.currentUser;
    await Future.delayed(
      Duration(seconds: 1),
    );

    email = user?.email;
    String? uid = user?.uid;
    final snapshot =
        await FirebaseFirestore.instance.collection('user').doc(uid).get();
    final data = snapshot.data();
    name = data?['name'];
    profileImage = data?['image_path'];
  }
}
