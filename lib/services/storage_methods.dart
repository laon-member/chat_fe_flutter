import 'dart:io';

import 'package:chat_app/services/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class StorageMethods {
  toUploadFile(String chatRoomId) async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any,
    );
    if (result != null) {
      File file = File(result.files.single.path);
      try {
        String fileRef =
            "chat/$chatRoomId/${DateTime.now().millisecondsSinceEpoch}";
        UploadTask uploadTask = FirebaseStorage.instance
            .ref("$fileRef/${result.files.single.name}")
            .putFile(file);

        uploadTask.whenComplete(() {
          print(
              "다운로드 URL!!: ${FirebaseStorage.instance.ref("$fileRef/${result.files.single.name}").getDownloadURL()}");
          ChatMethods().addFile(chatRoomId, result.files.single.name,
              "$fileRef/${result.files.single.name}");
        }).catchError((Object e) {
          print("업로드 중 에러 발생!!: $e");
        });
      } on FirebaseException catch (e) {
        print("파이어베이스 오류!!: $e");
      }
    }
  }

  void toUploadImage(String chatRoomId) async {
    FilePickerResult result = await FilePicker.platform
        .pickFiles(allowMultiple: false, type: FileType.image);
    if (result != null) {
      File file = File(result.files.single.path);
      try {
        String fileRef =
            "chat/$chatRoomId/${DateTime.now().millisecondsSinceEpoch}";
        UploadTask uploadTask = FirebaseStorage.instance
            .ref("$fileRef/${result.files.single.name}")
            .putFile(file);

        uploadTask.whenComplete(() {
          print(
              "다운로드 URL!!: ${FirebaseStorage.instance.ref("$fileRef/${result.files.single.name}").getDownloadURL()}");
          ChatMethods().addImage(chatRoomId, result.files.single.name,
              "$fileRef/${result.files.single.name}");
        }).catchError((Object e) {
          print("업로드 중 에러 발생!!: $e");
        });
      } on FirebaseException catch (e) {
        print("파이어베이스 오류!!: $e");
      }
    }
  }

  Future<void> toDownloadFile(
      String message, String downloadUrl, String chatRoomId) async {
    await Permission.storage.request();
    if(await Permission.storage.request().isGranted){
      // appDocDir 은 안드로이드에서만 가능하는것으로 보임. EsxtStorage 가 안드로이드에서만 작동하는것으로 보임.
      String appDocDir = await ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_DOWNLOADS);
      //Directory appDocDir2 = await getApplicationDocumentsDirectory();
      File downloadToFile = File('${appDocDir}/$message');
      print(downloadToFile);

      if (downloadToFile.existsSync()) {
        print('이미 다운로드됨!!:: ${downloadToFile.toString()}');
        await OpenFile.open(downloadToFile.toString());
        await downloadToFile.open(mode: FileMode.read);
      } else {
        try {
          await FirebaseStorage.instance
              .ref('$downloadUrl')
              .writeToFile(downloadToFile)
              .whenComplete(() {
            print('다운로드됨!!:: $downloadToFile');
          });
        } on FirebaseException catch (e) {
          print("오류!!: $e");
        }
      }
    }

  }

  Future<void> toDeleteFile(
      String message, String downloadUrl, String chatRoomId) async {
    // appDocDir 은 안드로이드에서만 가능하는것으로 보임. EsxtStorage 가 안드로이드에서만 작동하는것으로 보임.
    String appDocDir = await ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_DOWNLOADS);
    //Directory appDocDir2 = await getApplicationDocumentsDirectory();
    File downloadToFile = File('${appDocDir}/$message');
    print(downloadToFile);

    if (downloadToFile.existsSync()) {
      downloadToFile.delete();
    } else {
      print("파일이 존재하지 않음");
    }
  }
}
