import 'package:audioplayers/audioplayers.dart';
import 'package:chat_app/helper/constants.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:chat_app/services/storage_methods.dart';
import 'package:chat_app/views/friends_screen_check.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:firebase_image/firebase_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///conversation : 대화(nown)
///상대방과 대화할 수 있는 스크린 입니다.
///일반 사용자들은 이 스크린을 흔히 "대화방" 혹은 "톡방"으로 부릅니다.
class ConversationScreen extends StatefulWidget {
  final String chatRoomId;

  ConversationScreen(this.chatRoomId);

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  TextEditingController messageController = new TextEditingController();
  ScrollController _scrollController = new ScrollController();

  Stream chatMessageStream;

  TextEditingController chatNameTextEditingController =
      new TextEditingController();

  AudioPlayer audioPlayer = AudioPlayer(mode: PlayerMode.LOW_LATENCY);

  String chatRoomName;

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
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return MessageTile(
                      snapshot.data.docs[index].data()["message"],
                      snapshot.data.docs[index].data()["sendBy"] ==
                          Constants.myName,
                      snapshot.data.docs[index].data()["time"],
                      snapshot.data.docs[index].data()["sendBy"],
                      snapshot.data.docs[index].data()["type"],
                      snapshot.data.docs[index].data()['Download_url'],
                      widget.chatRoomId);
                })
            : Container(
                decoration: BoxDecoration(
                color: Color(0x99FFFFFF),
                borderRadius: BorderRadius.circular(15),
              ));
      },
    );
  }

  sendMessage() {
    ChatMethods().addText(
        widget.chatRoomId, messageController.text.trimLeft().trimRight());
    _scrollController.animateTo(
      0.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 500),
    );
    messageController.clear();
  }

  @override
  void initState() {
    ChatMethods().getConvMsg(widget.chatRoomId).then((value) {
      setState(() {
        chatMessageStream = value;
      });
    });
    ChatMethods().getRoomName(widget.chatRoomId).then((value) {
      setState(() {
        chatRoomName = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _scrollController.animateTo(
      0.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
    return Scaffold(
      appBar: AppBar(
        title: new Text(chatRoomName == null ? "로드중.." : chatRoomName),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(CupertinoIcons.pencil),
            tooltip: "채팅방에 새로운 이름 주기",
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("채팅방에 새로운 이름 주기"),
                    content: TextField(
                      controller: chatNameTextEditingController,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: "새로운 채팅방 이름..",
                        hintStyle: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    actions: [
                      FlatButton(
                        child: Text("취소"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      FlatButton(
                        child: Text("적용"),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("채팅방에 새로운 이름 주기"),
                                content: Text(
                                  "채팅방 제목을 새로운 이름으로 변경할 경우 초대되어 있는 사용자 전체에게 이 제목이 적용되요.\n새로운 채팅방 이름을 지정할 때에는 초대되어있는 사용자 모두를 만족할 수 있는 제목으로 지정해주세요.\n채팅방에게 새로운 이름을 부여함으로써 일어난 인한 책임은 본인에게 귀속됩니다.",
                                  style: TextStyle(color: Colors.black),
                                ),
                                actions: [
                                  FlatButton(
                                    child: Text("취소"),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                  ),
                                  FlatButton(
                                    child: Text("여기를 길게 눌러 확인"),
                                    onPressed: () {},
                                    onLongPress: () {
                                      ChatMethods().changeRoomName(
                                          widget.chatRoomId,
                                          chatNameTextEditingController.text);
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      )
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
            icon: Icon(CupertinoIcons.escape),
            tooltip: "채팅방 나가기",
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("채팅방 나가기"),
                    content: Text(
                      "채팅방을 나가시겠어요?\n다른 멤버가 다시 초대할 때 까지 채팅에 참여하실 수 없으며 일부 버전에서는 로그아웃이 진행될 수 있어요.",
                      style: TextStyle(color: Colors.black),
                    ),
                    actions: [
                      FlatButton(
                        child: Text("취소"),
                        onPressed: () => Navigator.pop(context),
                      ),
                      FlatButton(
                        child: Text("여기를 길게 눌러 나가기"),
                        onPressed: () {},
                        onLongPress: () {
                          ChatMethods().getOutChatRoom(widget.chatRoomId);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
            icon: Icon(CupertinoIcons.plus),
            tooltip: "초대",
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FriendsCheckScreen(
                          widget.chatRoomId, chatRoomName)));
            },
          ),
        ],
      ),
      body: Container(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              margin: const EdgeInsets.only(bottom: 65),
              decoration: BoxDecoration(
                color: Color(0xff1F1F1F),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ChatMessageList(),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0x99FFFFFF),
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("파일/이미지 공유"),
                              content: Text("파일 또는 이미지를 공유할까요?"),
                              actions: [
                                FlatButton(
                                  child: Text("취소"),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                FlatButton(
                                  child: Text("파일 공유"),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    StorageMethods()
                                        .toUploadFile(widget.chatRoomId);
                                  },
                                ),
                                FlatButton(
                                  child: Text("이미지 공유"),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    StorageMethods()
                                        .toUploadImage(widget.chatRoomId);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Container(
                        height: 35,
                        width: 35,
                        padding: EdgeInsets.all(1),
                        margin: EdgeInsets.only(right: 5),
                        child: Icon(
                          CupertinoIcons.plus_app,
                          color: Colors.black26,
                          size: 30,
                        ),
                      ),
                    ),
                    Expanded(
                        child: TextField(
                      controller: messageController,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: "텍스트 입력",
                        hintStyle: TextStyle(color: Colors.black54),
                        border: InputBorder.none,
                      ),
                    )),
                    GestureDetector(
                      onTap: () {
                        messageController.text.trimLeft().trimRight() != ""
                            ? sendMessage()
                            : null;
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: EdgeInsets.all(5),
                        child: Icon(
                          CupertinoIcons.paperplane_fill,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
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

/// type 에 관련된 정보
/// info: 정보, text: 단문 텍스트, file: 파일, image: 이미지파일
class MessageTile extends StatelessWidget {
  final String message;
  final bool isSendByMe;
  final String time;
  final String sendBy;
  final String type;
  final String download_Url;
  final String chatRoomId;

  MessageTile(this.message, this.isSendByMe, this.time, this.sendBy, this.type,
      this.download_Url, this.chatRoomId);

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case "info":
        return Container(
          padding: EdgeInsets.only(top: 3, bottom: 3, left: 20, right: 20),
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(left: 20, right: 20, bottom: 5),
                padding:
                    EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color(0x3AFFFFFF),
                ),
                child: Text(message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'OverpassRegular',
                        fontWeight: FontWeight.w300)),
              ),
            ],
          ),
        );
        break;
      case "file":
        return GestureDetector(
          onTap: () {
            StorageMethods()
                .toDownloadFile(this.message, this.download_Url, chatRoomId);
          },
          child: Container(
            padding: EdgeInsets.only(
                top: 3,
                bottom: 3,
                left: isSendByMe ? 0 : 20,
                right: isSendByMe ? 20 : 0),
            alignment:
                isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: isSendByMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                isSendByMe
                    ? Row()
                    : Row(
                        children: [
                          Container(
                            height: 30,
                            width: 30,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(40)),
                            child: Text(
                              "${sendBy.substring(0, 1).toUpperCase()}",
                              style: mediumTextStyle(),
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Container(
                            child: Text(
                              sendBy,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                isSendByMe ? Container() : SizedBox(height: 3),
                Container(
                  margin: isSendByMe
                      ? EdgeInsets.only(left: 20)
                      : EdgeInsets.only(right: 20),
                  padding:
                      EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isSendByMe ? Color(0xff007EF4) : Color(0x1AFFFFFF),
                  ),
                  child: Row(
                    mainAxisAlignment: isSendByMe
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_circle_down_outlined,
                          color: Colors.white,
                        ),
                        iconSize: 25,
                        padding: EdgeInsets.all(0),
                      ),
                      Flexible(
                        child: Text(message,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'OverpassRegular',
                                fontWeight: FontWeight.w300)),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: isSendByMe
                      ? EdgeInsets.only(left: 20)
                      : EdgeInsets.only(right: 20),
                  child: Text(time,
                      textAlign: isSendByMe ? TextAlign.right : TextAlign.left,
                      style: TextStyle(color: Colors.white30)),
                )
              ],
            ),
          ),
        );
        break;
      case "image":
        return GestureDetector(
          onTap: () {
            StorageMethods()
                .toDownloadFile(this.message, this.download_Url, chatRoomId);
          },
          child: Container(
            padding: EdgeInsets.only(
                top: 3,
                bottom: 3,
                left: isSendByMe ? 0 : 20,
                right: isSendByMe ? 20 : 0),
            alignment:
                isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: isSendByMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                isSendByMe
                    ? Row()
                    : Row(
                        children: [
                          Container(
                            height: 30,
                            width: 30,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(40)),
                            child: Text(
                              "${sendBy.substring(0, 1).toUpperCase()}",
                              style: mediumTextStyle(),
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Container(
                            child: Text(
                              sendBy,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                isSendByMe ? Container() : SizedBox(height: 3),
                Container(
                  margin: isSendByMe
                      ? EdgeInsets.only(left: 20)
                      : EdgeInsets.only(right: 20),
                  padding:
                      EdgeInsets.only(top: 3, bottom: 3),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),),
                  child: Image(
                    height: 150,
                    width: 150,
                    filterQuality: FilterQuality.low,
                    fit: BoxFit.cover,
                    image: FirebaseImage('gs://chatappsample-a6614.appspot.com/$download_Url',
                        shouldCache: true,
                        scale: 0.1,
                        maxSizeBytes: 3000 * 3000,
                        cacheRefreshStrategy: CacheRefreshStrategy.NEVER // Switch off update checking
                        ),
                  ),
                ),
                Container(
                  margin: isSendByMe
                      ? EdgeInsets.only(left: 20)
                      : EdgeInsets.only(right: 20),
                  child: Text(time,
                      textAlign: isSendByMe ? TextAlign.right : TextAlign.left,
                      style: TextStyle(color: Colors.white30)),
                )
              ],
            ),
          ),
        );
        break;
      default:
        return Container(
          padding: EdgeInsets.only(
              top: 3,
              bottom: 3,
              left: isSendByMe ? 0 : 20,
              right: isSendByMe ? 20 : 0),
          alignment: isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Column(
            crossAxisAlignment:
                isSendByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              isSendByMe
                  ? Row()
                  : Row(
                      children: [
                        Container(
                          height: 30,
                          width: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(40)),
                          child: Text(
                            "${sendBy.substring(0, 1).toUpperCase()}",
                            style: mediumTextStyle(),
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Container(
                          child: Text(
                            sendBy,
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ),
                      ],
                    ),
              isSendByMe ? Container() : SizedBox(height: 3),
              Container(
                margin: isSendByMe
                    ? EdgeInsets.only(left: 20)
                    : EdgeInsets.only(right: 20),
                padding:
                    EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                decoration: BoxDecoration(
                  borderRadius: isSendByMe
                      ? BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(2))
                      : BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomLeft: Radius.circular(2),
                          bottomRight: Radius.circular(20)),
                  color: isSendByMe ? Color(0xff007EF4) : Color(0x1AFFFFFF),
                ),
                child: Text(message,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'OverpassRegular',
                        fontWeight: FontWeight.w300)),
              ),
              Container(
                margin: isSendByMe
                    ? EdgeInsets.only(left: 20)
                    : EdgeInsets.only(right: 20),
                child: Text(time,
                    textAlign: isSendByMe ? TextAlign.right : TextAlign.left,
                    style: TextStyle(color: Colors.white30)),
              )
            ],
          ),
        );
        break;
    }
  }
}
