import 'package:flutter/material.dart';

Widget appBarMain(BuildContext context) {
  return AppBar(
    title: Text("Chatting Us"),
    elevation: 0.0,
    centerTitle: true,
  );
}

Widget appBarCustom(BuildContext context, String text, bool iscenterTitle){
  return AppBar(
    title: Text(text),
    elevation: 0.0,
    centerTitle: iscenterTitle,
  );
}

InputDecoration textFieldInputDecoration(String hintText) {

  return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.white54,),
      focusedBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      enabledBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)));
}

TextStyle simpleTextStyle() {
  return TextStyle(color: Colors.white, fontSize: 16);
}

TextStyle biggerTextStyle() {
  return TextStyle(color: Colors.white, fontSize: 18);
}

TextStyle mediumTextStyle() {
  return TextStyle(color: Colors.white, fontSize: 16);
}

TextStyle smallTextStyle() {
  return TextStyle(color: Colors.white, fontSize: 10);
}
