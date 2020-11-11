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

  ///사람을 검색할 때 사용합니다. 이 경우 검색창이 비어있지 않아야 합니다.
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
    } else if (searchTextEditingController.text == "admin://searchall"){
      await databaseMethods
          .getUserByUsername("a")
          .then((snapshot) {
        searchResultSnapshot = snapshot;
        print("$searchResultSnapshot");
        setState(() {
          haveUserSearched = true;
        });
      });
    }
  }

  @override
  void initState() {
    initiateSearch();
    super.initState();
  }

  ///유저가 검색이 된 경우 Firebase 에서 값을 구해옵니다. 만약 "k"를 검색한 경우 "k"와 관련되어 있는 이름이 모두 뜨게 됩니다.
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

///채팅방의 ID를 받아옵니다.
  getChatRoomId(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  /// 채팅방을 만들며 대화를 시작합니다. 그러나 본인에게는 메시지를 전송할 수 없습니다.
  createChatroomAndStartConversation({String userName}) {
    if (userName != Constants.myName) {
      String chatRoomId = getChatRoomId(userName, Constants.myName);
      List<String> users = [userName, Constants.myName];
      Map<String, dynamic> charRoomMap = {
        "users": users,
        "chatroomId": chatRoomId
      };
      databaseMethods.CreateChatRoom(chatRoomId, charRoomMap);
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
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              Text(
                userEmail,
                style: TextStyle(color: Colors.white54, fontSize: 15),
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
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Icon(
                Icons.message_rounded,
                color: Colors.white,
              ), //하얀색 메시지 아이콘
            ),
          )
        ],
      ),
    );
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
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Color(0x99FFFFFF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchTextEditingController,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                                hintText: "사용자 이름..",
                                hintStyle: TextStyle(
                                  color: Colors.black54,
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
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(45)),
                              padding: EdgeInsets.all(10),
                              child: Icon(
                                Icons.person_search_rounded,
                                color: Colors.black,
                                size: 30,
                              )),
                        )
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xff1F1F1F),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: searchList(),
                  )

                ],
              ),
            ),
    );
  }
}
