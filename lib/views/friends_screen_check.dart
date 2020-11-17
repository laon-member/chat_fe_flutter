import 'package:chat_app/helper/constants.dart';
import 'package:chat_app/helper/helperfunctions.dart';
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/search.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:flutter/material.dart';

class FriendsCheckScreen extends StatefulWidget {
  final String roomId;
  final String chatName;

  FriendsCheckScreen(this.roomId, this.chatName);

  @override
  _FriendsCheckScreenState createState() => _FriendsCheckScreenState();
}

class _FriendsCheckScreenState extends State<FriendsCheckScreen> {
  AuthService authMethods = new AuthService();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  Stream friends;

  Widget friendsList() {
    return StreamBuilder(
      stream: friends,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.documents.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return FriendsPlusTile(
                      snapshot.data.documents[index].data['friendName']
                          .toString(),
                      snapshot.data.documents[index].data['friendId'],
                      widget.roomId.toString(),
                    widget.chatName.toString()
                  );
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
        print("!!채팅방 아이디: ${widget.roomId.toString()}");
      });
    });
  }

  @override
  void initState() {
    this.getUserFriends();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.chatName}(으)로 다른 사용자 초대",
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.check_rounded),
            tooltip: "확인",
            onPressed: () {
              Navigator.pop(context);
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
        child: this.friendsList(),
      ),
      resizeToAvoidBottomPadding: false,
    );
  }
}

class FriendsPlusTile extends StatelessWidget {
  final String friendName;
  final String friendId;
  final String roomId;
  final String chatName;

  FriendsPlusTile(this.friendName, this.friendId, this.roomId, this.chatName);

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
          GestureDetector(
            onTap: () {
              DatabaseMethods().addMember(roomId, friendId, friendName, chatName);
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(30)),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Icon(
                Icons.person_add_rounded,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
