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


  ///사용자가 초대되어있는 대화방 모두 불러오기
  getChatRooms(String userId) async {
    return await FirebaseFirestore.instance
        .collection("ChatRoom")
        .where("users", arrayContains: userId)
        .snapshots();
  }

  ///이미 둘이 참여한 방이 있는지 여부를 확인함.
  ///TODO: 명령어가 확실치 않으니 다시 한 번 확인할 것.
  isAlreadyExistChatRooms(String friendId) async {
    return await FirebaseFirestore.instance
        .collection("ChatRoom")
        .where("users", arrayContains: [friendId, Constants.myId])
        .snapshots();
  }

  ///친구추가
  addFriends(String userId, friendMap, bool hasConvRoom, String oneChatRoomId) {
    FirebaseFirestore.instance
        .collection("users")
        .doc(Constants.myId)
        .collection("friends")
        .doc(userId)
        .set(friendMap);
  }

}
