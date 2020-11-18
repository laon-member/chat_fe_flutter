import 'package:chat_app/helper/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

///대화방에서 사용되는 메서드들 입니다.
///
/// format 에 관련된 정보
/// info: 정보, text: 단문 텍스트, file: 파일, image: 이미지파일
class ChatMethods {
  ///대화창에서 대화 내용 불러오기
  getConversationMessages(String chatRoomId) async {
    return await FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy("UNIXtime", descending: true)
        .snapshots();
  }

  ///대화방에서 사용자를 초대합니다.
  addMember(String chatRoomId, String friendId, String friendName, String chatName) {
    FirebaseFirestore.instance.collection("ChatRoom").doc(chatRoomId).update({
      'users': FieldValue.arrayUnion([friendId])
    }).catchError((e) {
      print(e);
    });
    addInfo(chatRoomId,
        "ⓘ정보ⓘ\n${Constants.myName} 님이 $friendName 님을 초대했습니다.\n$friendName 님! 피자는 가져오셨겠죠?");
  }

  ///채팅방 이름 바꾸기
  changeChatRoom(String chatRoomId, String newChatRoomName) {
    FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomId)
        .update({'chatName': newChatRoomName}).catchError((e) {
      print(e);
    });
    addInfo(chatRoomId, "${Constants.myName}님이 다음과 같은 새로운 채팅방 이름을 지어줬어요!\n$newChatRoomName\n\n일부 버전은 채팅방 재진입 후 적용됩니다.");
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
    addInfo(chatRoomId, "지금부터 대화 시작!");
  }

  ///채팅방 나감
  getOutChatRoom(String chatRoomId) {
    FirebaseFirestore.instance.collection("ChatRoom").doc(chatRoomId).update({
      'users': FieldValue.arrayRemove([Constants.myId.toString()])
    });
    addInfo(chatRoomId, "${Constants.myName}님이 나갔습니다.");
  }

  addInfo(String chatRoomId, String infoText) {
    addConvMsg(infoText, "info", chatRoomId);
  }

  addText(String chatRoomId, String chatText) {
    addConvMsg(chatText, "text", chatRoomId);
  }

  addFile(String chatRoomId, String fileName, String DownloadUrl) {
    addConvMsg(fileName, "file", chatRoomId, Download_url: DownloadUrl);
  }

  addImage(String chatRoomId, String fileName, String DownloadUrl) {
    addConvMsg(fileName, "iamge", chatRoomId, Download_url: DownloadUrl);
  }

  @Deprecated("`addConvMsg()` 사용을 권장합니다.")
  addConversationMessages(String message, String format, String chatRoomId) =>
      addConvMsg(message, format, chatRoomId);

  ///채팅방에서 대화를 만듭니다.
  addConvMsg(String message, String format, String chatRoomId,
      {String Download_url}) {
    Map<String, dynamic> messageMap = {
      "message": message,
      "format": format,
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
