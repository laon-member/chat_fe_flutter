import 'dart:io';

import 'package:chat_app/widgets/widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UploadFile extends StatefulWidget {
  final String chatRoomId;

  UploadFile(this.chatRoomId);

  @override
  _UploadFileState createState() => _UploadFileState();

}

class _UploadFileState extends State<UploadFile> {

  String fileType = '';
  File file;
  String fileName = '';
  String operationText = '';
  bool isUploaded = true;
  String result = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarCustom(context, "파일 업로드", true),
      body: Center(
        child: FlatButton(
          child: Text("여기를 눌러 파일 업로드"),
          onPressed: () {
            filePicker(context);
          },
        ),
      ),
    );
  }

  Future filePicker(BuildContext context) async {
    try {
      FilePickerResult result = await FilePicker.platform.pickFiles();
      if(result != null) {
        file = File(result.files.single.path);
      }
      print(fileName);
      _uploadFile(file, fileName);
    } on PlatformException catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("오류가 발생하였습니다."),
            content: Text("오류내용: $e"),
            actions: <Widget>[
              FlatButton(child: Text("확인"), onPressed: () {
                Navigator.of(context).pop();
              },)
            ],
          );
        },
      );
    }
  }
///TODO :: 토큰 오류가 있다고 나오니 다시한번 살펴볼 것.
  Future<void> _uploadFile(File file, String filename) async {
    Reference storageReference = FirebaseStorage.instance.ref().child("chat/${widget.chatRoomId}/others/$filename");

      final UploadTask uploadTask = storageReference.putFile(file);
      final TaskSnapshot downloadUrl = (await uploadTask.whenComplete(() => null));
    final String url = (await downloadUrl.ref.getDownloadURL());
      print("URL is $url");
  }

}
