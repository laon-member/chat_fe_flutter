import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  ///사용자의 이름으로 검색할 때 구현됩니다.
  ///사용자 이름(username)을 String 값으로 받아와 구현해 줍니다.
  ///만약 "kroon"을 검색하면 "kroon"과 일치하거나 그런 이름을 가진 계정들이 검색됩니다.
  getUserByUsername(String username) async {
    return await Firestore.instance
        .collection("users")
        .where("name", isGreaterThanOrEqualTo: username)
        .getDocuments();
  }

  getUserByEmail(String userEmail) async {
    return await Firestore.instance
        .collection("users")
        .where("email", isEqualTo: userEmail)
        .getDocuments();
  }

  uploadUserInfo(String userId, userMap) {
    Firestore.instance
        .collection("users")
        .document(userId)
        .setData(userMap)
        .catchError((e) {
      print("에러!: ${e.toString()}");
    });
  }

  ///친구 목록을 얻어옵니다.
  getFriends(String userId) async {
    return await Firestore.instance
        .collection("users")
        .document(userId)
        .collection("friends")
        .orderBy("name", descending: false)
        .snapshots();
  }

  addFriends(String userId, friendMap) {
    Firestore.instance
        .collection("users")
        .document(userId)
        .collection("friends")
        .add(friendMap);
  }

  Future<bool> CreateChatRoom(String charRoomId, chatRoomMap) {
    Firestore.instance
        .collection("ChatRoom")
        .document(charRoomId)
        .setData(chatRoomMap)
        .catchError((e) {
      print(e);
    });
  }

  getConversationMessages(String chatRoomId) async {
    return await Firestore.instance
        .collection("ChatRoom")
        .document(chatRoomId)
        .collection("chats")
        .orderBy("UNIXtime", descending: true)
        .snapshots();
  }

  addConversationMessages(String chatRoomId, messageMap) {
    Firestore.instance
        .collection("ChatRoom")
        .document(chatRoomId)
        .collection("chats")
        .add(messageMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  getChatRooms(String userId) async {
    return await Firestore.instance
        .collection("ChatRoom")
        .where("users", arrayContains: userId)
        .snapshots();
  }
}
