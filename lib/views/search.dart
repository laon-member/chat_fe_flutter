import 'package:chat_app/helper/authenticate.dart';
import 'package:chat_app/helper/constants.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/conversation_screen.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

String myName;

class _SearchState extends State<Search> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController searchTextEditingController =
      new TextEditingController();
  QuerySnapshot searchResultSnapshot;

  bool isLoading = false;
  bool haveUserSearched = false;

  initiateSearch() async {
    if (searchTextEditingController.text.isNotEmpty) {
      await databaseMethods
        .getUserByUsername(searchTextEditingController.text)
        .then((snapshot) {
      searchResultSnapshot = snapshot;
      print("$searchResultSnapshot");
      setState(() {
        haveUserSearched = true;
      });
    });

    }
  }

  Widget searchList() {
    return haveUserSearched
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchResultSnapshot.documents.length,
            itemBuilder: (context, index) {
              return SearchTile(
                searchResultSnapshot.documents[index].data["name"],
                searchResultSnapshot.documents[index].data["email"],
              );
            })
        : Container();
  }

  /// 채팅방 반들기, 메시지 등을 다른 사용자에게 보냄.
  createChatroomAndStartConversation({String userName}) {
    if (userName != Constants.myName) {
      String chatRoomId = getChatRoomId(userName, Constants.myName);
      List<String> users = [userName, Constants.myName];
      Map<String, dynamic> charRoomMap = {
        "users": users,
        "chatroomId": chatRoomId
      };
      databaseMethods.createChatRoom(chatRoomId, charRoomMap);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ConversationScreen(chatRoomId)));
    } else {
      print("본인은 본인에게 메시지를 전송할 수 없어요.");
    }
  }

  Widget SearchTile(String userName, String userEmail) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: simpleTextStyle(),
              ),
              Text(
                userEmail,
                style: simpleTextStyle(),
              )
            ],
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
              createChatroomAndStartConversation(userName: userName);
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(30)),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Icon(
                Icons.message,
                color: Colors.white,
              ), //하얀색 메시지 아이콘
            ),
          )
        ],
      ),
    );
  }

  getChatRoomId(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  @override
  void initState() {
    initiateSearch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Container(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    color: Color(0x54FFFFFF),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchTextEditingController,
                            style: simpleTextStyle(),
                            decoration: InputDecoration(
                                hintText: "사용자 이름..",
                                hintStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                border: InputBorder.none),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            initiateSearch();
                          },
                          child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(40)),
                              padding: EdgeInsets.all(12),
                              child: Icon(
                                Icons.search,
                                color: Colors.white,
                                size: 20,
                              )),
                        )
                      ],
                    ),
                  ),
                  searchList()
                ],
              ),
            ),
    );
  }
}
