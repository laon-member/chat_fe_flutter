import 'package:chat_app/helper/constants.dart';
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
        .orderBy("friendName", descending: false)
        .snapshots();
  }

  getConversationMessages(String chatRoomId) async {
    return await Firestore.instance
        .collection("ChatRoom")
        .document(chatRoomId)
        .collection("chats")
        .orderBy("UNIXtime", descending: true)
        .snapshots();
  }

  getChatRooms(String userId) async {
    return await Firestore.instance
        .collection("ChatRoom")
        .where("users", arrayContains: userId)
        .snapshots();
  }

  ///이미 둘이 참여한 방이 있는지 여부를 확인함.
  ///TODO: 명령어가 확실치 않으니 다시 한 번 확인할 것.
  isAlreadyExistChatRooms(String userId) async {
    return await Firestore.instance
        .collection("ChatRoom")
        .where("users", arrayContains: "${userId}&&${Constants.myId}")
        .snapshots();
  }

  ///친구추가
  addFriends(String userId, friendMap) {
    Firestore.instance
        .collection("users")
        .document(Constants.myId)
        .collection("friends")
        .document(userId)
        .setData(friendMap);
  }

  ///사용자 초대
  addMember(
      String chatRoomId, String friendId, String friendName, String chatName) {
    Firestore.instance.collection("ChatRoom").document(chatRoomId).updateData({
      'users': FieldValue.arrayUnion([friendId])
    }).catchError((e) {
      print(e);
    });
    //Firestore.instance.collection("ChatRoom").document(chatRoomId).updateData({'chatName': '$chatName, $friendName'});
  }

  Future<bool> CreateChatRoom(String chatRoomId, chatRoomMap) {
    Firestore.instance
        .collection("ChatRoom")
        .document(chatRoomId)
        .setData(chatRoomMap)
        .catchError((e) {
      print(e);
    });
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
}
