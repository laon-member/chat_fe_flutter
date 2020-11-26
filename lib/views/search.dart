import 'package:chat_app/helper/constants.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
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
            itemCount: searchResultSnapshot.docs.length,
            itemBuilder: (context, index) {
              return SearchTile(
                searchResultSnapshot.docs[index].data()["name"],
                searchResultSnapshot.docs[index].data()["email"],
                searchResultSnapshot.docs[index].data()["userId"],
              );
            })
        : Container();
  }

  addFriend({String userName, String userId, bool hasConvRoom, String oneChatRoomId}) {
    Map<String, dynamic> friendMap = {"friendId": userId, "friendName": userName, "hasConvRoom": hasConvRoom, "oneChatRoomId": null};
    databaseMethods.addFriends(userId, friendMap, hasConvRoom, oneChatRoomId);
  }

  Widget SearchTile(String userName, String userEmail, String userId) {
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
              userId != Constants.myId ? addFriend(userName: userName, userId: userId, hasConvRoom: false) : null;
            },
            child: Container(
              decoration: BoxDecoration(
                  color: userId == Constants.myId ? Colors.black54 : Colors.blue, borderRadius: BorderRadius.circular(30)),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Icon(
                userId == Constants.myId ? Icons.person_add_disabled_outlined : Icons.person_add_outlined,
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
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchTextEditingController,
                            keyboardType: TextInputType.name,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                                hintText: "사용자 이름 검색",
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
                                CupertinoIcons.search,
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
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: searchList(),
                  )
                ],
              ),
            ),
    );
  }
}
