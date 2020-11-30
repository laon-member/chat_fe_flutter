import 'package:chat_app/helper/authenticate.dart';
import 'package:chat_app/helper/helperfunctions.dart';
import 'package:chat_app/views/chat_rooms_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
  print("IT'S RUNNING...\n애플리케이션의 작동을 시작합니다.");
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool userIsLoggedIn = false;
  @override
  void initState() {
    getLoggedInState();
    super.initState();
  }

  ///로그인 여부를 구합니다. 로그인/아웃의 여부는 Auth.dart 에서 다룹니다.
  getLoggedInState() async {
    await HelperFunctions.getUserLoggedInSharedPreference().then((value){
      setState(() {
        userIsLoggedIn = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatting Us',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        primaryColor: Color(0xffEFEFEF),
        primaryColorBrightness: Brightness.light,
        scaffoldBackgroundColor: Color(0xFFEFEFEF),
        bottomAppBarColor: Color(0xFFEFEFEF),
        primaryColorDark: Color(0xffBFBFBF),
        accentColor: Color(0xff0076FF),
        fontFamily: "OverpassRegular",
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(brightness: Brightness.light),
      ),
      darkTheme: ThemeData(
        primaryColor: Color(0xff2F2F2F),
        primaryColorBrightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xff2F2F2F),
        bottomAppBarColor: Color(0xFFEFEFEF),
        accentColor: Color(0xff0076FF),
        fontFamily: "OverpassRegular",
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(brightness: Brightness.dark),
      ),
      home:
      userIsLoggedIn != null ?  userIsLoggedIn ? ChatRoom() : Authenticate()
          : Container(
        child: Center(
          child: Authenticate(),
        ),
      ),
    );
  }
}

///비어 있음
class IamBlink extends StatefulWidget {
  @override
  _IamBlinkState createState() => _IamBlinkState();
}

class _IamBlinkState extends State<IamBlink> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}


