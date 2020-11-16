import 'dart:math';

import 'package:chat_app/views/chat_rooms_screen.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:chat_app/helper/helperfunctions.dart';
import 'package:chat_app/helper/theme.dart';
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/services/database.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  final Function toggleView;

  SignUp(this.toggleView);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController emailEditingController = new TextEditingController();
  TextEditingController passwordEditingController = new TextEditingController();
  TextEditingController usernameEditingController = new TextEditingController();
  static const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();
  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  AuthService authService = new AuthService();
  DatabaseMethods databaseMethods = new DatabaseMethods();

  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  HelperFunctions helperFunctions = new HelperFunctions();

  signMeUp() async {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      String userId = getRandomString(20);
      await authService
          .signUpWithEmailAndPassword(
              emailEditingController.text, passwordEditingController.text)
          .then((val) {
        if (val != null) {
          Map<String, dynamic> userDataMap = {
            "email": emailEditingController.text,
            "name": usernameEditingController.text,
            "userId": userId,
          };

          databaseMethods.uploadUserInfo(userId, userDataMap);

          HelperFunctions.saveUserLoggedInSharedPreference(true);
          HelperFunctions.saveUserNameSharedPreference(
              usernameEditingController.text);
          HelperFunctions.saveUserEmailSharedPreference(
              emailEditingController.text);
          HelperFunctions.saveUserIdSharedPreference(userId);

          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => ChatRoom()));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarCustom(context, "회원가입", true),
      body: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [const Color(0x002F2F2F), const Color(0xff2F2F2F)],
                    stops: [0.05, 0.5],
                  ),
                  borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  Spacer(),
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          style: simpleTextStyle(),
                          controller: usernameEditingController,
                          validator: (val) {
                            return val.isEmpty || val.length < 1
                                ? "1자 이상의 이름을 입력해주세요."
                                : null;
                          },
                          decoration: textFieldInputDecoration("사용자 이름"),
                        ),
                        TextFormField(
                          controller: emailEditingController,
                          style: simpleTextStyle(),
                          validator: (val) {
                            return RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(val)
                                ? null
                                : "이메일이 올바르지 않습니다. 올바른 이메일을 입력해 주세요.";
                          },
                          decoration: textFieldInputDecoration("이메일"),
                        ),
                        TextFormField(
                          obscureText: true,
                          style: simpleTextStyle(),
                          decoration: textFieldInputDecoration("비밀번호"),
                          controller: passwordEditingController,
                          validator: (val) {
                            return val.length >= 6
                                ? null
                                : "6자 이상의 비밀번호를 입력해 주세요.";
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  GestureDetector(
                    onTap: () {
                      signMeUp();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xff007EF4),
                              const Color(0xff009955)
                            ],
                          )),
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        "가입",
                        style: biggerTextStyle(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xff4285F4),
                            const Color(0xffEA4335),
                            const Color(0xffEA4335),
                            const Color(0xffFBBC05),
                            const Color(0xffFBBC05),
                            const Color(0xff34A853),
                          ],
                          stops: [0.25, 0.25, 0.50, 0.50, 0.75, 0.75],
                        )),
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      "Google 계정으로 가입",
                      style:
                          TextStyle(fontSize: 17, color: CustomTheme.textColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "이미 계정이 있으신가요? ",
                        style: simpleTextStyle(),
                      ),
                      GestureDetector(
                        onTap: () {
                          widget.toggleView();
                        },
                        child: Text(
                          "로그인하세요",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 50,
                  )
                ],
              ),
            ),
    );
  }
}
