import 'package:flutter/material.dart';
import 'package:flutter_mac/models/user.dart';
import 'package:flutter_mac/screens/chat/chat.dart';
import 'package:flutter_mac/screens/image_preview.dart';
import 'package:flutter_mac/screens/profile/profile.dart';

class ScreenNavigator {
  static String chatScreen = 'chat';
  static String profileScreen = 'profile';

  static openChatScreen(
      UserCred userCred, UserProfile userProfile, BuildContext context) {
    _push(context, ChatScreen(userCred: userCred, userProfile: userProfile));
  }

  static openProfileScreen(String uid, bool edit, BuildContext context) {
    _push(context, ProfileScreen(uid: uid, edit: edit));
  }

  static openImagePreview(String imageUrl, BuildContext context) {
    _push(context, ImagePreview(imageUrl: imageUrl));
  }

  static _push(BuildContext context, Widget widget) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => widget));
  }
}
