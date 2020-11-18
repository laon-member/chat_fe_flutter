import 'package:chat_app/helper/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {

  ///새로운 사용자 파이어베이스에 저장
  uploadUserInfo(String userId, userMap) {
    FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .set(userMap)
        .catchError((e) {
      print("에러!: ${e.toString()}");
    });
  }

  ///사용자의 이름으로 검색
  getUserByUsername(String username) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("name", isGreaterThanOrEqualTo: username)
        .get();
  }

  ///사용자의 이메일로 검색
  getUserByEmail(String userEmail) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: userEmail)
        .get();
  }

  ///사용자의 친구 목록을 얻어옴.
  getFriends(String userId) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("friends")
        .orderBy("friendName", descending: false)
        .snapshots();
  }

  ///대화창에서 대화 내용 불러오기
  getConversationMessages(String chatRoomId) async {
    return await FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy("UNIXtime", descending: true)
        .snapshots();
  }

  ///사용자가 초대되어있는 대화방 모두 불러오기
  getChatRooms(String userId) async {
    return await FirebaseFirestore.instance
        .collection("ChatRoom")
        .where("users", arrayContains: userId)
        .snapshots();
  }

  ///이미 둘이 참여한 방이 있는지 여부를 확인함.
  ///TODO: 명령어가 확실치 않으니 다시 한 번 확인할 것.
  isAlreadyExistChatRooms(String userId) async {
    return await FirebaseFirestore.instance
        .collection("ChatRoom")
        .where("users", arrayContains: "$userId&&${Constants.myId}")
        .snapshots();
  }

  ///친구추가
  addFriends(String userId, friendMap) {
    FirebaseFirestore.instance
        .collection("users")
        .doc(Constants.myId)
        .collection("friends")
        .doc(userId)
        .set(friendMap);
  }

  ///사용자 초대
  addMember(
      String chatRoomId, String friendId, String friendName, String chatName) {
    FirebaseFirestore.instance.collection("ChatRoom").doc(chatRoomId).update({
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
    //FirebaseFirestore.instance.collection("ChatRoom").doc(chatRoomId).update({'chatName': '$chatName, $friendName'});
  }

  ///채팅방 이름 바꾸기
  changeChatRoom(String chatRoomId, String newChatRoomName) {
    FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomId)
        .update({'chatName': newChatRoomName}).catchError((e) {
      print(e);
    });
    Map<String, dynamic> messageMap = {
      "message":
          "ⓘ정보ⓘ\n${Constants.myName} 님이 채팅방의 이름을 다음과 같이 바꿨습니다.\n$newChatRoomName\n\n구 버전에서는 앱을 재실행하셔야 새로운 채팅방 이름이 적용됩니다. ඞඞ",
      "sendBy": Constants.myName,
      "UNIXtime": DateTime.now().millisecondsSinceEpoch,
      "date":
          "${DateTime.now().year.toString()}년 ${DateTime.now().month.toString()}월 ${DateTime.now().day.toString()}일",
      "time":
          "${DateTime.now().hour.toString()}:${DateTime.now().minute < 10 ? "0" + DateTime.now().minute.toString() : DateTime.now().minute.toString()}",
    };
    DatabaseMethods().addConversationMessages(chatRoomId, messageMap);
  }

  ///채팅방 나감
  getOutChatRoom(String chatRoomId) {
    FirebaseFirestore.instance.collection("ChatRoom").doc(chatRoomId).update(
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

  ///채팅방 만들기
  Future<bool> CreateChatRoom(String chatRoomId, chatRoomMap) {
    FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomId)
        .set(chatRoomMap)
        .catchError((e) {
      print(e);
    });
  }

  ///채팅방에서 텍스트형식의 대화를 만듭니다.
  ///일일이 Map 값을 입력해야해 불편함이 예상되어 다른 것으로의 사용을 강력히 권장합니다.
  @Deprecated("대화 관련된 메서드는 ChatMethods대화 내용 추가는 addText(), 파일 추가는 addFile(), 새로운 정보 추가는 addInfo()를 사용하세요.")
  addConversationMessages(String chatRoomId, messageMap) {
    FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomId)
        .collection("chats")
        .add(messageMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  addChat(String chatRoomId, String chatText) {

  }

  addConversationMessagesAsFile(String chatRoomId, String fileName){
    Map<String, dynamic> messageMap = {
      "message": fileName,
      "format": "file",
      "sendBy": Constants.myName,
      "UNIXtime": DateTime.now().millisecondsSinceEpoch,
      "date":
      "${DateTime.now().year.toString()}년 ${DateTime.now().month.toString()}월 ${DateTime.now().day.toString()}일",
      "time":
      "${DateTime.now().hour.toString()}:${DateTime.now().minute < 10 ? "0" + DateTime.now().minute.toString() : DateTime.now().minute.toString()}",
    };
    DatabaseMethods().addConversationMessages(chatRoomId, messageMap);
  }

  void uploadFile() {}

}
