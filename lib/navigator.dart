import 'package:flutter/material.dart';
import 'package:flutter_mac/screens/chat/chat.dart';
import 'package:flutter_mac/screens/image_preview.dart';
import 'package:flutter_mac/screens/profile/profile.dart';

class ScreenNavigator {
  static String chatScreen = 'chat';
  static String profileScreen = 'profile';

  static openChatScreen(String uid, BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ChatScreen(uid: uid)));
  }

  static openProfileScreen(String uid, bool edit, BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProfileScreen(uid: uid, edit: edit)));
  }

  static openImagePreview(String imageUrl, BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ImagePreview(imageUrl: imageUrl)));
  }
}
