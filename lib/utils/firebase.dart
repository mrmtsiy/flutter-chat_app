import 'package:chat_app/model/group.dart';
import 'package:chat_app/model/member.dart';
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
  static final groupRef = _firestoreInstance.collection('group');
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

  static Future<void> sendGroupMessage(String groupId, String message) async {
    final messageRef = groupRef.doc(groupId).collection('message');
    final id = messageRef.doc().id;
    String? myUid = FirebaseAuth.instance.currentUser?.uid;
    await messageRef.doc(id).set({
      'message': message,
      'sender_id': myUid,
      'send_time': Timestamp.now(),
      'messageId': id,
    });

    groupRef.doc(groupId).update({
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

  static Future<void> sendGroupImage(String groupId, String image) async {
    final messageRef = groupRef.doc(groupId).collection('message');
    final id = messageRef.doc().id;
    String? myUid = FirebaseAuth.instance.currentUser?.uid;
    await messageRef.doc(id).set({
      'image': image,
      'sender_id': myUid,
      'send_time': Timestamp.now(),
      'messageId': id,
    });

    groupRef.doc(groupId).update({
      'last_message': '画像を送信しました',
      'updated_time': Timestamp.now(),
    });
  }

  static Future<void> deleteMessage(String roomId, String messageId) async {
    await roomRef.doc(roomId).collection('message').doc(messageId).delete();

    roomRef.doc(roomId).update({
      'last_message': '投稿を削除しました',
      'updated_time': Timestamp.now(),
    });
  }

  static Future<void> deleteGroupMessage(
      String groupId, String messageId) async {
    await groupRef.doc(groupId).collection('message').doc(messageId).delete();

    groupRef.doc(groupId).update({
      'last_message': '投稿を削除しました',
      'updated_time': Timestamp.now(),
    });
  }

  static Future<void> createGroup(String groupName, String groupImage) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    Auth.fetchUser(currentUser!.uid);

    final id = groupRef.doc().id;
    if (groupName.isEmpty) {
      throw 'グループ名を決めてください';
    } else {
      await groupRef.doc(id).set({
        'groupName': groupName,
        'joined_user_id': [currentUser.uid],
        'updated_time': Timestamp.now(),
        'groupId': id,
        'groupImage': groupImage,
      });
    }

    groupRef.doc(id).collection('member').doc(currentUser.uid).set({
      // 'groupId': id,
      //   'userName': doc.data()['userName'],
      //   'userImage': doc.data()['userImage'],
    });
  }

  static Future<List<Group>?> getGroup(String myUid) async {
    final snapshot = await groupRef.get();
    List<Group>? groupList = [];
    await Future.forEach(snapshot.docs, (dynamic doc) async {
      if (doc.data()['joined_user_id'].contains(myUid)) {
        Group group = Group(
          groupId: doc.data()['groupId'],
          groupName: doc.data()['groupName'],
          member: doc.data()['joined_user_id'],
          lastMessage: doc.data()['last_message'],
          lastMessageTime: doc.data()['updated_time'],
          groupImage: doc.data()['groupImage'],
        );

        groupList.add(group);
      }
    });
    return groupList;
  }

  static Future<List<Users>?> getGroupMember(String groupId) async {
    final snapshot = await userRef.get();
    List<Users>? memberList = [];
    await Future.forEach(snapshot.docs, (dynamic doc) async {
      Users member = Users(
        name: doc.data()['name'],
        imagePath: doc.data()['image_path'],
        uid: doc.data()['uid'],
      );
      memberList.add(member);
    });
    return memberList;
  }

  static Future<List<Message>?> getGroupMessages(String groupId) async {
    final messageRef = groupRef.doc(groupId).collection('message');
    List<Message>? messageList = [];
    final snapshot = await messageRef.get();
    await Future.forEach(snapshot.docs, (dynamic doc) {
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

//グループに参加する
  static Future<List<Group>?> joinGroup(String groupId, String myUid) async {
    final _name = userRef.doc(myUid).get().then((user) => user.data()!['name']);
    final _image =
        userRef.doc(myUid).get().then((user) => user.data()!['image_path']);
    userRef.doc(myUid).get().then((user) => user.data()!['name']);

    await groupRef.doc(groupId).update({
      'joined_user_id': FieldValue.arrayUnion([myUid])
    });
    groupRef.doc(groupId).update({
      'last_message': '参加しました',
      'updated_time': Timestamp.now(),
    });

    // groupRef.doc(groupId).collection('member').doc(myUid).set({
    //   'groupId': groupId,
    //   'userName': _name,
    //   'userImage': _image,
    // });

    //参加したら招待を表示しなくするため
    await userRef.doc(myUid).collection('invitation').doc(groupId).delete();
  }

//グループを抜ける
  static Future<List<Group>?> leaveGroup(String groupId, String myUid) async {
    groupRef.doc(groupId).update({
      'joined_user_id': FieldValue.arrayRemove([myUid])
    });
  }

//招待されているグループを取得する
  static Future<List<Group>?> getInvitation(String myUid) async {
    final snapshot = await userRef.doc(myUid).collection('invitation').get();
    List<Group>? invitedList = [];
    await Future.forEach(snapshot.docs, (dynamic doc) {
      Group invite = Group(
        groupName: doc.data()['groupName'] ?? '',
        groupImage: doc.data()['groupImage'] ?? '',
        groupId: doc.data()['groupId'],
      );
      invitedList.add(invite);
    });
    return invitedList;
  }

//グループに招待する
  static Future<void> inviteGroup(String groupName, String groupImage,
      String groupId, Users invitedUser) async {
    final inviteRef = userRef.doc(invitedUser.uid).collection('invitation');
    await inviteRef.doc(groupId).set({
      'groupImage': groupImage,
      'groupName': groupName,
      'groupId': groupId,
      'isInvited': true,
    });

    groupRef.doc(groupId).update({
      'last_message': '${invitedUser.name}を招待しました',
      'updated_time': Timestamp.now(),
    });
  }

  static Stream<QuerySnapshot>? messageSnapshot(String roomId) {
    return roomRef.doc(roomId).collection('message').snapshots();
  }

  static Stream<QuerySnapshot>? roomSnapshot() {
    return roomRef.snapshots();
  }

  static Stream<QuerySnapshot>? groupSnapshot() {
    return groupRef.snapshots();
  }

  static Stream<QuerySnapshot>? groupMessageSnapshot(String groupId) {
    return groupRef.doc(groupId).collection('message').snapshots();
  }

  static Stream<QuerySnapshot>? invitedsnapshot() {
    String? myUid = FirebaseAuth.instance.currentUser?.uid;
    return userRef.doc(myUid).collection('invitation').snapshots();
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
