import 'package:flutter/material.dart';
import 'package:flutter_mac/common/pair.dart';
import 'package:flutter_mac/models/message_preference.dart';
import 'package:flutter_mac/preference/app_color_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreference {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final _appBarColor = 'appBarColor';
  final _primaryBackgroundColor = 'primaryBackgroundColor';
  final _secondaryBackgroundColor = 'secondaryBackgroundColor';
  final _senderBackgroundColor = 'senderBackgroundColor';
  final _senderTextColor = 'senderTextColor';
  final _receiverBackgroundColor = 'receiverBackgroundColor';
  final _receiverTextColor = 'receiverTextColor';
  final _senderTimeColor = 'senderTimeColor';
  final _receiverTimeColor = 'receiverTimeColor';
  final _dateTextColor = 'dateTextColor';
  final _dateBackgroundColor = 'dateBackgroundColor';
  final _dateTextSize = 'dateTextSize';
  final _messageTextSize = 'messageTextSize';
  final _messageTimeSize = 'messageTimeSize';

  getAppColorPref() async {
    final SharedPreferences prefs = await _prefs;
    return AppColorPref(
      appBarColor: prefs.getInt(_appBarColor),
      appBackgroundColor: Pair(prefs.getInt(_primaryBackgroundColor),
          prefs.getInt(_secondaryBackgroundColor)),
    );
  }

  getMessagePref() async {
    final SharedPreferences prefs = await _prefs;
    return MessagePref(
      senderBackgroundColor: prefs.getInt(_senderBackgroundColor),
      senderTextColor: prefs.getInt(_senderTextColor),
      receiverBackgroundColor: prefs.getInt(_receiverBackgroundColor),
      receiverTextColor: prefs.getInt(_receiverTextColor),
      senderTimeColor: prefs.getInt(_senderTimeColor),
      receiverTimeColor: prefs.getInt(_receiverTimeColor),
      messageTextSize: prefs.getInt(_messageTextSize),
      messageTimeSize: prefs.getInt(_messageTimeSize),
      dateTextSize: prefs.getInt(_dateTextSize),
      dateBackgroundColor: prefs.getInt(_dateBackgroundColor),
      dateTextColor: prefs.getInt(_dateTextColor),
    );
  }

  setAppBarColor(Color color) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setInt(_appBarColor, color.value);
  }

  setAppBackgroundColor(Pair<Color, Color> color) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setInt(_primaryBackgroundColor, color.first.value);
    await prefs.setInt(_secondaryBackgroundColor, color.second.value);
  }

  setMessageColorPreference(MessagePreference type, Color color) async {
    final SharedPreferences prefs = await _prefs;
    switch (type) {
      case MessagePreference.receiverBackgroundColor:
        prefs.setInt(_receiverBackgroundColor, color.value);
        break;
      case MessagePreference.receiverTextColor:
        prefs.setInt(_receiverTextColor, color.value);
        break;
      case MessagePreference.receiverTimeColor:
        prefs.setInt(_receiverTimeColor, color.value);
        break;
      case MessagePreference.senderBackgroundColor:
        prefs.setInt(_senderBackgroundColor, color.value);
        break;
      case MessagePreference.senderTextColor:
        prefs.setInt(_senderTextColor, color.value);
        break;
      case MessagePreference.senderTimeColor:
        prefs.setInt(_senderTimeColor, color.value);
        break;
      case MessagePreference.dateBackgroundColor:
        prefs.setInt(_dateBackgroundColor, color.value);
        break;
      case MessagePreference.dateTextColor:
        prefs.setInt(_dateTextColor, color.value);
        break;
      default:
        break;
    }
  }

  setMessageTimePreference(MessagePreference type, int value) async {
    final SharedPreferences prefs = await _prefs;
    switch (type) {
      case MessagePreference.messageTextSize:
        prefs.setInt(_messageTextSize, value);
        break;
      case MessagePreference.messageTimeSize:
        prefs.setInt(_messageTimeSize, value);
        break;
      case MessagePreference.dateTextSize:
        prefs.setInt(_dateTextSize, value);
        break;
      default:
    }
  }
}
