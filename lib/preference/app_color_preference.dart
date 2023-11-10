import 'package:flutter/material.dart';
import 'package:flutter_mac/common/constants.dart';
import 'package:flutter_mac/common/pair.dart';

class AppColorPref {
  Color appBarColor = AppColors.appRed;
  Pair<Color, Color> appBackgroundColor = Pair(Colors.red, Colors.blue);

  AppColorPref({
    int? appBarColor,
    Pair<int?, int?>? appBackgroundColor,
  }) {
    if (appBarColor != null) {
      this.appBarColor = Color(appBarColor);
    }
    if (appBackgroundColor != null) {
      Pair(Color(appBackgroundColor.first ?? Colors.blue.value),
          Color(appBackgroundColor.second ?? Colors.blue.value));
    }
  }
}

class MessagePref {
  int messageTextSize = 16;
  int messageTimeSize = 12;
  int dateTextSize = 12;
  Color dateBackgroundColor = const Color.fromARGB(70, 85, 85, 85);
  Color dateTextColor = const Color.fromARGB(255, 245, 241, 241);
  Color senderBackgroundColor = Colors.blue;
  Color receiverBackgroundColor = const Color.fromARGB(255, 19, 206, 44);
  Color senderTextColor = Colors.white;
  Color receiverTextColor = Colors.white;
  Color senderTimeColor = Colors.white;
  Color receiverTimeColor = Colors.white;

  MessagePref({
    int? dateTextSize,
    int? dateBackgroundColor,
    int? dateTextColor,
    int? senderBackgroundColor,
    int? senderTextColor,
    int? receiverBackgroundColor,
    int? receiverTextColor,
    int? messageTextSize,
    int? messageTimeSize,
    int? senderTimeColor,
    int? receiverTimeColor,
  }) {
    if (senderBackgroundColor != null) {
      this.senderBackgroundColor = Color(senderBackgroundColor);
    }
    if (senderBackgroundColor != null) {
      this.senderBackgroundColor = Color(senderBackgroundColor);
    }
    if (receiverBackgroundColor != null) {
      this.receiverBackgroundColor = Color(receiverBackgroundColor);
    }
    if (senderTextColor != null) {
      this.senderTextColor = Color(senderTextColor);
    }
    if (receiverTextColor != null) {
      this.receiverTextColor = Color(receiverTextColor);
    }
    if (senderTimeColor != null) {
      this.senderTimeColor = Color(senderTimeColor);
    }
    if (receiverTimeColor != null) {
      this.receiverTimeColor = Color(receiverTimeColor);
    }
    if (dateBackgroundColor != null) {
      this.dateBackgroundColor = Color(dateBackgroundColor);
    }
    if (dateTextColor != null) {
      this.dateTextColor = Color(dateTextColor);
    }
    if (messageTextSize != null) {
      this.messageTextSize = messageTextSize;
    }
    if (messageTimeSize != null) {
      this.messageTimeSize = messageTimeSize;
    }
    if (dateTextSize != null) {
      this.dateTextSize = dateTextSize;
    }
  }
}
