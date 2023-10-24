import 'package:flutter/material.dart';

const textInputDeclaration = InputDecoration(
    hintText: 'Password',
    fillColor: Color(0xFFB2EBF2),
    filled: true,
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFB2EBF2), width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color.fromARGB(255, 239, 88, 88), width: 2),
    ));

class StringConstants {
  static String settings = 'Settings';
  static String logout = 'Logout';
  static String home = 'Home';
  static String register = 'Register';
  static String signIn = 'Sign In';
  static String email = 'Email';
  static String enterAnEmail = 'Enter an email';
  static String password = 'Password';
  static String enterPassword = 'Enter a password 6+ character long';
  static String supplyLegalEmail = 'Supply legal email';
  static String couldNotSignIn = 'Couldn\'t Sign In';
  static String name = 'Name';
  static String enterName = 'Enter a name';
  static String update = 'UPDATE';
  static String typeMessage = 'Type a message...';
}

class ChatConstants {
  static String msg = 'msg';
  static String name = 'name';
  static String imageUrl = 'image_url';
  static String uid = 'uid';
}

class KeyConstants {
  static String giphyApiKey = 'jKi0717ZNdPeHV6yCCnKGSwA1lM5sTC8';
}
