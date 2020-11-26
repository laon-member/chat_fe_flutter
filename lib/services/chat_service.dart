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

  Future <String> getRoomName(String chatRoomId) async {
    return await FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
          return documentSnapshot.get("chatName").toString();
    });
  }

  ///채팅방 이름 바꾸기
  changeRoomName(String chatRoomId, String newChatRoomName) {
    FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomId)
        .update({'chatName': newChatRoomName}).catchError((e) {
      print(e);
    });
    addInfo(chatRoomId,
        "${Constants.myName} 님이 새 채팅방 이름을\n$newChatRoomName (으)로 바꿨습니다.");
    addInfo(chatRoomId, "ⓘ구 버전은 채팅방을 재진입해야 적용됩니다.");
  }

  ///채팅방 만들기
  createChatRoom(String chatRoomId, chatRoomMap) {
    FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomId)
        .set(chatRoomMap)
        .catchError((e) {
      print(e);
    });
    addInfo(chatRoomId, "채팅방이 열렸습니다!");
  }

  ///1:1 채팅방 양산 방지를 위한 부분
  Future<String> isAlreadyExistChatRoom(String friendsId) async {
    List<dynamic> inUsers;
    List<String> alreadyInUsers = [Constants.myId, friendsId];
    alreadyInUsers.sort((a, b) => a.compareTo(b));
    print(alreadyInUsers);
    return await FirebaseFirestore.instance
        .collection("ChatRoom")
        .where("users", arrayContainsAny: alreadyInUsers)
        .get()
        .then((snapshot) {
      QuerySnapshot querySnapshot = snapshot;
      int i = 0;
      for (i = 0; i + 1 < querySnapshot.size; i++) {
        print(i);
        if (querySnapshot.docs[i]
                .data()["isOneVone"]
                .toString()
                .trim()
                .replaceAll("[", "")
                .replaceAll("]", "") ==
            "true") {
          inUsers = querySnapshot.docs[i].data()["users"];
          if (alreadyInUsers.toString() == inUsers.toString()) {
            print(
                "이미 있는 채팅방 입니다!!\n채팅방 아이디!!: ${querySnapshot.docs[i].data()["chatroomId"]}");
            return querySnapshot.docs[i].data()["chatroomId"];
          }
        } else {
          print("이 사용자와 대화를 나눈 전적이 없음.");
        }
      }
      print("for문 끝. 잡힌 채팅방이 하나도 없음!!");
    }).catchError((e) {});
  }

  ///사용자 초대
  addMember(String chatRoomId, String newFriendId, String friendName,
      String chatName, bool isOneVone) {
    List<dynamic> inUsers;
    FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      inUsers = documentSnapshot.get("users");
      inUsers.remove(Constants.myId.toString());
    });
    if (isOneVone == null) {
      isOneVone = true;
    }

    ///내부에 있는 유저들의 정보를 얻어옴.
    FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      inUsers = documentSnapshot.get("users");
      print("된다!!: $inUsers");

      ///만약 초대하고자 하는 사람이 이미 있는 사람이라면
      if (inUsers.contains(newFriendId)) {
        print("이미 초대한 사용자는 다시 초대할 수 없어요");
      } else {
        FirebaseFirestore.instance
            .collection("ChatRoom")
            .doc(chatRoomId)
            .update({
          'users': FieldValue.arrayUnion([newFriendId]),
          'isOneVone': false
        }).catchError((e) {
          print(e);
        });
        addInfo(chatRoomId,
            "${Constants.myName} 님이 $friendName 님을 초대했습니다.\n$friendName 님! 피자는 가져오셨겠죠?");
      }
    });
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
    addConvMsg(fileName, "image", chatRoomId, Download_url: DownloadUrl);
  }

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
