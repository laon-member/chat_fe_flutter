import 'package:chat_app/helper/constants.dart';
import 'package:chat_app/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

  createOneChatRoom(String friendId, String chatRoomId) {
    FirebaseFirestore.instance
        .collection("users")
        .doc(Constants.myId)
        .collection("friends")
        .doc(friendId)
        .update({"hasConvRoom": true, "oneChatRoomId": chatRoomId});

    FirebaseFirestore.instance
        .collection("users")
        .doc(friendId)
        .collection("friends")
        .doc(Constants.myId)
        .set({
      "friendId": Constants.myId,
      "friendName": Constants.myName,
      "hasConvRoom": true,
      "oneChatRoomId": chatRoomId
    });
  }

  delOneChatRoom(String chatRoomId, String newFriendsId) {
    List<dynamic> inUsers;
    String friendId = "";
    FirebaseFirestore.instance.collection("ChatRoom").doc(chatRoomId).get().then((DocumentSnapshot documentSnapshot) {
      inUsers = documentSnapshot.get("users");
      inUsers.remove(Constants.myId.toString());
    });
    if(newFriendsId != inUsers.toString().replaceAll("[", "").replaceAll("]", "") && friendId != Constants.myId) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(Constants.myId)
          .collection("friends")
          .doc(friendId)
          .update({"hasConvRoom": false, "oneChatRoomId": null});
      FirebaseFirestore.instance
          .collection("users")
          .doc(friendId)
          .collection("friends")
          .doc(Constants.myId)
          .update({"hasConvRoom": false, "oneChatRoomId": null});
    }
  }

  ///사용자 초대
  addMember(String chatRoomId, String newFriendId, String friendName,
      String chatName) {
    List<dynamic> inUsers;

    ///내부에 있는 유저들의 정보를 얻어옴.
    FirebaseFirestore.instance.collection("ChatRoom").doc(chatRoomId).get().then((DocumentSnapshot documentSnapshot) {
      inUsers = documentSnapshot.get("users");
      print("된다!!: $inUsers");

      ///만약 초대하고자 하는 사람이 이미 있는 사람이라면
      if(inUsers.contains(newFriendId)) {
        print("이미 초대한 사용자는 다시 초대할 수 없어요");
      } else {
        FirebaseFirestore.instance.collection("ChatRoom").doc(chatRoomId).update({
          'users': FieldValue.arrayUnion([newFriendId])
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
    addConvMsg(fileName, "iamge", chatRoomId, Download_url: DownloadUrl);
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
