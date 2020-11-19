import 'dart:math';

import 'package:chat_app/helper/authenticate.dart';
import 'package:chat_app/helper/constants.dart';
import 'package:chat_app/helper/helperfunctions.dart';
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/chat_rooms_screen.dart';
import 'package:chat_app/views/conversation_screen.dart';
import 'package:chat_app/views/search.dart';
import 'package:chat_app/views/signin.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:flutter/material.dart';

class FriendsScreen extends StatefulWidget {
  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  AuthService authMethods = new AuthService();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  Stream friends;

  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  Widget friendsList() {
    return StreamBuilder(
      stream: friends,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return FriendsTile(
                      snapshot.data.docs[index].data()['friendName']
                          .toString(),
                      snapshot.data.docs[index].data()['friendId']);
                })
            : Container();
      },
    );
  }

  getUserFriends() async {
    Constants.myName = await HelperFunctions.getUserNameSharedPreference();
    Constants.myId = await HelperFunctions.getUserIdSharedPreference();
    DatabaseMethods().getFriends(Constants.myId).then((value) {
      setState(() {
        friends = value;
        print("다음과 같은 데이터를 얻음: + ${value.toString()}\n이름: ${Constants.myName}");
      });
    });
  }

  @override
  void initState() {
    getUserFriends();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${Constants.myName.toString()}의 친구 목록",
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app_rounded),
            tooltip: "로그아웃",
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  // return object of type Dialog
                  return AlertDialog(
                    title: new Text("로그아웃"),
                    content: new Text("로그아웃 하시겠어요?\n로그아웃 이후 재로그인이 필요합니다."),
                    actions: <Widget>[
                      new FlatButton(
                        child: new Text("취소"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      new FlatButton(
                        child: new Text("여기를 길게 눌러 로그아웃"),
                        onPressed:() {},
                        onLongPress: () {Navigator.pop(context);
                        authService.signOut();
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) => Authenticate()));
                        },
                      )
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.search_rounded),
            tooltip: "검색",
            padding: EdgeInsets.symmetric(horizontal: 20),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Search()));
            },
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: ThemeData.dark().primaryColorDark,
          borderRadius: BorderRadius.circular(15),
        ),
        child: friendsList(),
      ),
      resizeToAvoidBottomPadding: false,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.chat_rounded),
        tooltip: '채팅 목록',
        onPressed: () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => ChatRoom()));
        },
      ),
    );
  }

  /// 채팅방을 만들며 대화를 시작합니다. 그러나 본인에게는 메시지를 전송할 수 없습니다.
  createChatroomAndStartConversation({String userId, String userName}) {
    if (userId != Constants.myId) {
        print("${databaseMethods.isAlreadyExistChatRooms(userId)}");
        String chatRoomId = getRandomString(20);
        List<String> users = [userId, Constants.myId.toString()];
        Map<String, dynamic> chatRoomMap = {
          "users": users,
          "chatroomId": chatRoomId,
          "chatName": "${Constants.myName}, $userName"
        };
        ChatMethods().createChatRoom(chatRoomId, chatRoomMap);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ConversationScreen(userName, chatRoomId)));
    } else {
      print("본인은 본인에게 메시지를 전송할 수 없어요.");
    }
  }
}

class FriendsTile extends StatelessWidget {
  final String friendName;
  final String friendId;

  FriendsTile(this.friendName, this.friendId);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Colors.blue, borderRadius: BorderRadius.circular(40)),
            child: Text(
              "${friendName.substring(0, 1).toUpperCase()}",
              style: mediumTextStyle(),
            ),
          ),
          SizedBox(
            width: 8,
          ),
          Container(
            child: Text(
              friendName,
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.add_comment_rounded), color: Colors.white, tooltip: "채팅방 만들기",
            onPressed: () {
              _FriendsScreenState().createChatroomAndStartConversation(
                  userId: friendId, userName: friendName);
            },
          )
        ],
      ),
    );
  }
}
