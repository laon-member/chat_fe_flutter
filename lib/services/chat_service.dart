import 'package:chat_app/helper/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

///대화방에서 사용되는 데이터베이스 관련 메서드들 입니다.
///
/// type 에 관련된 정보
/// info: 정보, text: 단문 텍스트, file: 파일, image: 이미지파일
class ChatMethods {

  ///대화창에서 대화 내용 불러옵니다.
  getConvMsg(String chatRoomId) async {
    return await FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy("UNIXtime", descending: true)
        .snapshots();
  }

  ///채팅방 이름 바꾸기
  changeRoomName(String chatRoomId, String newChatRoomName) {
    FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomId)
        .update({'chatName': newChatRoomName}).catchError((e) {
      print(e);
    });
    addInfo(chatRoomId, "${Constants.myName} 님이 새 채팅방 이름을\n$newChatRoomName (으)로 바꿨습니다.");
    addInfo(chatRoomId, "ⓘ구 버전은 채팅방을 재진입해야 적용됩니다.");
  }

  ///채팅방 만들기
  Future<bool> createChatRoom(String chatRoomId, chatRoomMap) {
    FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomId)
        .set(chatRoomMap)
        .catchError((e) {
      print(e);
    });
    addInfo(chatRoomId, "채팅방이 열렸습니다!");
  }

  ///사용자 초대
  addMember(String chatRoomId, String friendId, String friendName, String chatName) {
    FirebaseFirestore.instance.collection("ChatRoom").doc(chatRoomId).update({
      'users': FieldValue.arrayUnion([friendId])
    }).catchError((e) {
      print(e);
    });
    addInfo(chatRoomId, "${Constants.myName} 님이 $friendName 님을 초대했습니다.\n$friendName 님! 피자는 가져오셨겠죠?");
  }

  ///사용자 나감
  getOutChatRoom(String chatRoomId) {
    FirebaseFirestore.instance.collection("ChatRoom").doc(chatRoomId).update({
      'users': FieldValue.arrayRemove([Constants.myId.toString()])
    });
    addInfo(chatRoomId, "${Constants.myName}님이 나갔습니다.");
  }

  ///새롭게 변경된 정보 알림
  addInfo(String chatRoomId, String infoText) {
    addConvMsg(infoText, "info", chatRoomId);
  }

  ///텍스트 형식으로 된 쳇
  addText(String chatRoomId, String chatText) {
    addConvMsg(chatText, "text", chatRoomId);
  }

  ///파일 형식으로 된 쳇
  addFile(String chatRoomId, String fileName, String DownloadUrl) {
    addConvMsg(fileName, "file", chatRoomId, Download_url: DownloadUrl);
  }

  ///이미지 보냄
  addImage(String chatRoomId, String fileName, String DownloadUrl) {
    addConvMsg(fileName, "iamge", chatRoomId, Download_url: DownloadUrl);
  }

  @Deprecated("`addConvMsg()`를 사용하셔야 합니다! 반드시!!")
  addConversationMessages(String message, String type, String chatRoomId) =>
      addConvMsg(message, type, chatRoomId);

  ///채팅방에서 대화를 만듭니다.
  addConvMsg(String message, String type, String chatRoomId,
      {String Download_url}) {
    Map<String, dynamic> messageMap = {
      "message": message,
      "type": type,
      "Download_url": Download_url,
      "sendBy": Constants.myName,
      "UNIXtime": DateTime.now().millisecondsSinceEpoch,
      "date":
          "${DateTime.now().year.toString()}년 ${DateTime.now().month.toString()}월 ${DateTime.now().day.toString()}일",
      "time":
          "${DateTime.now().hour.toString()}:${DateTime.now().minute < 10 ? "0" + DateTime.now().minute.toString() : DateTime.now().minute.toString()}",
    };
    FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomId)
        .collection("chats")
        .add(messageMap)
        .catchError((e) {
      print(e.toString());
    });
  }
}
