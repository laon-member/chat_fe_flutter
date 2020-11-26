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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  AuthService authMethods = new AuthService();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  Stream chatRooms;
  String version;

  Widget chatRoomsList() {
    return StreamBuilder(
      stream: chatRooms,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return ChatRoomsTile(
                      snapshot.data.docs[index].data()['chatName'],
                      snapshot.data.docs[index].data()['chatroomId']);
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

    FirebaseFirestore.instance
        .collection("notifyUpdate")
        .doc("lastVersion")
        .get()
        .then((value) {
      DocumentSnapshot documentSnapshot = value;
      version = documentSnapshot.data()["lastVersion"];
    });

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
        actions: [],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: ThemeData.dark().primaryColorDark,
          borderRadius: BorderRadius.circular(15),
        ),
        child: chatRoomsList(),
      ),
      resizeToAvoidBottomPadding: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        child: Icon(CupertinoIcons.search),
        tooltip: "검색",
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Search()));
        },
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 5.0,
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  tooltip: '친구 목록',
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  icon: Icon(CupertinoIcons.person_2),
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FriendsScreen()));
                  },
                ),
              ],
            ),
            //로그아웃
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  icon: Icon(CupertinoIcons.escape),
                  tooltip: "로그아웃",
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        // return object of type Dialog
                        return AlertDialog(
                          title: new Text("로그아웃"),
                          content:
                              new Text("로그아웃 하시겠어요?\n로그아웃 이후 재로그인이 필요합니다."),
                          actions: <Widget>[
                            new FlatButton(
                              child: new Text("취소"),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            new FlatButton(
                              child: new Text("여기를 길게 눌러 로그아웃"),
                              onPressed: () {},
                              onLongPress: () {
                                Navigator.pop(context);
                                authService.signOut();
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Authenticate()));
                              },
                            )
                          ],
                        );
                      },
                    );
                  },
                ),

                //버전 비교
                IconButton(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  icon: Icon(CupertinoIcons.info_circle),
                  tooltip: "앱 정보 및 업데이트 확인",
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        // return object of type Dialog
                        return AlertDialog(
                          title: new Text("애플리케이션 정보"),
                          content: new Text(
                              "현재 버전: ${Constants.appVersion}\n새로운 버전: ${version != null ? version : null}"),
                          actions: <Widget>[
                            new FlatButton(
                              child: new Text("확인"),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
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
                builder: (context) => ConversationScreen(this.chatRoomId)));
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
