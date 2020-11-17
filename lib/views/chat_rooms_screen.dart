import 'package:chat_app/helper/authenticate.dart';
import 'package:chat_app/helper/constants.dart';
import 'package:chat_app/helper/helperfunctions.dart';
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/conversation_screen.dart';
import 'package:chat_app/views/friends_screen.dart';
import 'package:chat_app/views/search.dart';
import 'package:chat_app/views/signin.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:flutter/material.dart';

class ChatRoom extends StatefulWidget {

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  AuthService authMethods = new AuthService();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  Stream chatRooms;

  Widget chatRoomsList() {
    return StreamBuilder(
      stream: chatRooms,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.documents.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return ChatRoomsTile(
                      snapshot.data.documents[index].data['chatName'],
                      snapshot.data.documents[index].data['chatroomId']);
                })
            : Container();
      },
    );
  }

  getUserInfogetChats() async {
    Constants.myName = await HelperFunctions.getUserNameSharedPreference();
    Constants.myId = await HelperFunctions.getUserIdSharedPreference();
    DatabaseMethods().getChatRooms(Constants.myId).then((value) {
      setState(() {
        chatRooms = value;
        print("다음과 같은 데이터를 얻음: + ${value.toString()}\n이름: ${Constants.myName}");
      });
    });
  }

  @override
  void initState() {
    getUserInfogetChats();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${Constants.myName.toString()}의 채팅 목록",
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
                        // ignore: unnecessary_statements
                        onPressed:(){null;},
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
        child: chatRoomsList(),
      ),
      resizeToAvoidBottomPadding: false,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.person_outline_rounded),
        tooltip: '친구',
        onPressed: () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => FriendsScreen()));
        },
      ),
    );
  }
}

class ChatRoomsTile extends StatelessWidget {
  final String chatName;
  final String chatRoomId;

  ChatRoomsTile(this.chatName, this.chatRoomId);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ConversationScreen(this.chatName, this.chatRoomId)));
      },
      child: Container(
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
                "${chatName.substring(0, 1).toUpperCase()}",
                style: mediumTextStyle(),
              ),
            ),
            SizedBox(
              width: 8,
            ),
            Container(
              child: Text(
                chatName,
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
