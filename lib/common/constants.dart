import 'package:flutter/material.dart';
import 'package:flutter_mac/common/pair.dart';

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
  static String useSmallerImage = 'Please use a smaller image.';
  static String coppiedSuccessfully = 'Copied Successfully';
  static String copy = 'Copy';
  static String reply = 'Reply';
  static String gif = 'Gif';
  static String image = 'Image';
  static String pleaseWait = 'Please Wait...';
  static String you = 'You';
}

class ChatConstants {
  static String msg = 'msg';
  static String name = 'name';
  static String imageUrl = 'image_url';
  static String uid = 'uid';
  static String url = 'url';
  static String messageType = 'message_type';
  static String timestamp = 'timestamp';
  static String online = 'online';
  static String profilePicture = 'profile_picture';
  static String quote = 'quote';
  static String reply = 'reply';
  static String id = 'id';
  static String value = 'value';
}

class PrefenceConstants {
  static String maxImageSizeLabel = 'maxImageSize';
  static String maxProfileImageSizeLabel = 'maxProfileImageSize';
  static int maxImageSize = 250000;
  static int maxProfileImageSize = 1000000;
  static String appBarColor = 'appBarColor';
  static String primaryBackgroundColor = 'primaryBackgroundColor';
  static String secondaryBackgroundColor = 'secondaryBackgroundColor';
  static String messageTextSize = 'messageTextSize';
  static String messageTimeSize = 'messageTimeSize';
  static String dateTextSize = 'dateTextSize';
  static String dateBackgroundColor = 'dateBackgroundColor';
  static String dateTextColor = 'dateTextColor';
  static String senderBackgroundColor = 'senderBackgroundColor';
  static String receiverBackgroundColor = 'receiverBackgroundColor';
  static String senderTextColor = 'senderTextColor';
  static String receiverTextColor = 'receiverTextColor';
  static String senderTimeColor = 'senderTimeColor';
  static String receiverTimeColor = 'receiverTimeColor';
  static String messageSound = 'messageSound';
  static String preference = 'preference';
  static int maxCharReplyObject = 100;
}

class KeyConstants {
  static String giphyApiKey = 'jKi0717ZNdPeHV6yCCnKGSwA1lM5sTC8';
  static String samplePicture =
      'https://dfstudio-d420.kxcdn.com/wordpress/wp-content/uploads/2019/06/digital_camera_photo-980x653.jpg';
  static int oneMB = 1000000;
}

class AppColors {
  static Color appRed = const Color.fromARGB(255, 211, 21, 7);
}

class AssetsConstants {
  static String dot = 'assets/images/dot.png';
  static List<Pair<String, String>> soundArray = [
    Pair('Sound 1', 'audio/notification_1.mp3'),
    Pair('Sound 2', 'audio/notification_2.mp3'),
    Pair('Sound 3', 'audio/notification_3.mp3'),
    Pair('Sound 4', 'audio/notification_4.mp3'),
    Pair('Sound 5', 'audio/notification_5.mp3'),
    Pair('Sound 6', 'audio/notification_6.mp3'),
    Pair('Sound 7', 'audio/notification_7.mp3')
  ];
}
