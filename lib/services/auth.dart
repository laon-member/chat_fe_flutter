import 'package:chat_app/models/user.dart';
import 'package:chat_app/views/chat_rooms_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

///사용자의 인증 기능을 담당합니다.
///로그인/아웃 등 기본기능부터 구글 연동 로그인(예정)까지 다뤄 보안상으로 매우 중요합니다.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ///사용자의 정보가 파이어베이스로부터 존재하는지 묻습니다. 없는 경우 null 값을 반환합니다.
  User _userFromFirebaseUser(FirebaseUser user) {
    return user != null ? User(uid: user.uid) : null;
  }

  ///가장 일반적인 방식인 이메일 및 비밀번호로 로그인 하는 방식 입니다.
  ///email 및 password를 String 값으로 받아옵니다.
  ///옳지 않은 값이 있는 경우 null 값을 반환합니다.
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  ///가장 일반적인 방식인 이메일 및 비밀번호로 가입 하는 방식 입니다.
  ///email 및 password를 String 값으로 받아옵니다.
  ///이미 가입되어있는 이메일로 가입을 한 경우 null 값을 반환합니다.
  Future signUpWithEmailAndPassword(String email, String password) async {
    //print("UPLOADING.. : 사용자 정보: $email, $password");
    try {
      AuthResult result = await _auth
          .createUserWithEmailAndPassword(
          email: email,
          password: password
      );
      FirebaseUser user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print("에러: ${e.toString()}");
      return null;
    }
  }

  Future resetPass(String email) async {
    try {
      return await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<FirebaseUser> signInWithGoogle(BuildContext context) async {
    final GoogleSignIn _googleSignIn = new GoogleSignIn();

    final GoogleSignInAccount googleSignInAccount =
        await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);

    AuthResult result = await _auth.signInWithCredential(credential);
    //FirebaseUser userDetails = result.user;

    if (result == null) {
    } else {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ChatRoom()));
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
