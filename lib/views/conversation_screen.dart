import 'package:chat_app/helper/constants.dart';
import 'package:chat_app/services/database.dart';
import 'package:flutter/material.dart';

///conversation : 대화
///상대방과 대화할 수 있는 스크린 입니다.
///일반 사용자들은 이 스크린을 흔히 "대화방" 혹은 "톡방"으로 부릅니다.
class ConversationScreen extends StatefulWidget {
  final String chatRoomId;

  ConversationScreen(this.chatRoomId);

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController messageController = new TextEditingController();
  ScrollController _scrollController = new ScrollController();

  Stream chatMessageStream;

  // ignore: non_constant_identifier_names
  Widget ChatMessageList() {
    return StreamBuilder(
      stream: chatMessageStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
            reverse: true,
            controller: _scrollController,
            shrinkWrap: true,
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) {
              return MessageTile(
                  snapshot.data.documents[index].data["message"],
                  snapshot.data.documents[index].data["sendBy"] ==
                      Constants.myName,
                  snapshot.data.documents[index].data["time"]);
            })
            : Container();
      },
    );
  }

  sendMessage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> messageMap = {
        "message": messageController.text,
        "sendBy": Constants.myName,
        "UNIXtime": DateTime
            .now()
            .millisecondsSinceEpoch,
        "date": "${DateTime
            .now()
            .year
            .toString()}년 ${DateTime
            .now()
            .month
            .toString()}월 ${DateTime
            .now()
            .day
            .toString()}일",
        "time": "${DateTime
            .now()
            .hour
            .toString()}:${DateTime
            .now()
            .minute
            .toString()}",
      };
      DatabaseMethods().addConversationMessages(widget.chatRoomId, messageMap);
      _scrollController.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  @override
  void initState() {
    databaseMethods.getConversationMessages(widget.chatRoomId).then((value) {
      setState(() {
        chatMessageStream = value;
      });
    });
    super.initState();
  }

  //ScrollController _scrollController = new ScrollController();

  @override
  Widget build(BuildContext context) {
    _scrollController.animateTo(
      0.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.chatRoomId
              .replaceAll("_", "")
              .replaceAll(Constants.myName, ""))),
      body: Container(
        child: Stack(
          children: [
            ChatMessageList(),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Color(0x99FFFFFF),
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                          controller: messageController,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              hintText: "보낼 메시지 입력..",
                              hintStyle: TextStyle(color: Colors.white54),
                              border: InputBorder.none),
                        )),
                    GestureDetector(
                      onTap: () {
                        sendMessage();
                      },
                      child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          padding: EdgeInsets.all(10),
                          child: Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 30,
                          )),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  final bool isSendByMe;
  final String time;

  MessageTile(this.message, this.isSendByMe, this.time);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 8,
          bottom: 8,
          left: isSendByMe ? 0 : 24,
          right: isSendByMe ? 24 : 0),
      alignment: isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isSendByMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Container(
            margin:
            isSendByMe ? EdgeInsets.only(left: 30) : EdgeInsets.only(right: 30),
            padding: EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
            decoration: BoxDecoration(
                borderRadius: isSendByMe
                    ? BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(23),
                    bottomLeft: Radius.circular(23))
                    : BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(23),
                    bottomRight: Radius.circular(23)),
                gradient: LinearGradient(
                  colors: isSendByMe
                      ? [const Color(0xff007EF4), const Color(0xff2A75BC)]
                      : [const Color(0x1AFFFFFF), const Color(0x1AFFFFFF)],
                )),
            child: Text(message,
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'OverpassRegular',
                    fontWeight: FontWeight.w300)),
          ),
          Container(
            margin:
            isSendByMe ? EdgeInsets.only(left: 30) : EdgeInsets.only(right: 30),
            child: Text(time,
                textAlign: isSendByMe ? TextAlign.right : TextAlign.left,
                style: TextStyle (color: Colors.white30)),
          )
        ],
      ),
    );
  }
}
