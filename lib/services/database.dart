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
    Map<String, dynamic> messageMap = {
      "message":
          "ⓘ정보ⓘ\n${Constants.myName} 님이 $friendName 님을 초대했습니다.\n$friendName 님! 피자는 가져오셨겠죠?",
      "sendBy": Constants.myName,
      "UNIXtime": DateTime.now().millisecondsSinceEpoch,
      "date":
          "${DateTime.now().year.toString()}년 ${DateTime.now().month.toString()}월 ${DateTime.now().day.toString()}일",
      "time":
          "${DateTime.now().hour.toString()}:${DateTime.now().minute < 10 ? "0" + DateTime.now().minute.toString() : DateTime.now().minute.toString()}",
    };
    DatabaseMethods().addConversationMessages(chatRoomId, messageMap);
    //Firestore.instance.collection("ChatRoom").document(chatRoomId).updateData({'chatName': '$chatName, $friendName'});
  }

  ///채팅방 이름 바꾸기
  changeChatRoom(String chatRoomId, String newChatRoomName) {
    Firestore.instance
        .collection("ChatRoom")
        .document(chatRoomId)
        .updateData({'chatName': newChatRoomName}).catchError((e) {
      print(e);
    });
    Map<String, dynamic> messageMap = {
      "message":
          "ⓘ정보ⓘ\n${Constants.myName} 님이 채팅방의 이름을 다음과 같이 바꿨습니다.\n일부 버전에서는 앱을 재실행하셔야 새로운 채팅방 이름이 적용됩니다. ඞඞ\n$newChatRoomName",
      "sendBy": Constants.myName,
      "UNIXtime": DateTime.now().millisecondsSinceEpoch,
      "date":
          "${DateTime.now().year.toString()}년 ${DateTime.now().month.toString()}월 ${DateTime.now().day.toString()}일",
      "time":
          "${DateTime.now().hour.toString()}:${DateTime.now().minute < 10 ? "0" + DateTime.now().minute.toString() : DateTime.now().minute.toString()}",
    };
    DatabaseMethods().addConversationMessages(chatRoomId, messageMap);
  }

  ///채팅방 이름 바꾸기
  getOutChatRoom(String chatRoomId) {
    Firestore.instance.collection("ChatRoom").document(chatRoomId).updateData(
        {'users': FieldValue.arrayRemove([Constants.myId.toString()])});
    Map<String, dynamic> messageMap = {
      "message": "ⓘ정보ⓘ\n${Constants.myName} 님이 나갔습니다.",
      "sendBy": Constants.myName,
      "UNIXtime": DateTime.now().millisecondsSinceEpoch,
      "date":
          "${DateTime.now().year.toString()}년 ${DateTime.now().month.toString()}월 ${DateTime.now().day.toString()}일",
      "time":
          "${DateTime.now().hour.toString()}:${DateTime.now().minute < 10 ? "0" + DateTime.now().minute.toString() : DateTime.now().minute.toString()}",
    };
    DatabaseMethods().addConversationMessages(chatRoomId, messageMap);
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
