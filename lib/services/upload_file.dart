import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';

class UploadFileMethods {
  // fileUpload(String chatRoomId) async {
  //   FilePickerResult result =
  //       await FilePicker.platform.pickFiles(allowMultiple: false);
  //
  //   if (result != null) {
  //     File file = File(result.files.single.path);
  //     try {
  //       UploadTask uploadTask = FirebaseStorage.instance.ref("gs://chatappsample-a6614.appspot.com/").putFile(file);
  //       uploadTask.then((TaskSnapshot snapshot) {
  //         print(FirebaseStorage.instance.ref("").getDownloadURL());
  //       }).catchError((Object e) {
  //         print("에러!!: $e");
  //       });
  //     } on FirebaseException catch (e) {
  //       print(e);
  //     }
  //   }
  // }
}
