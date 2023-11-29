import 'package:flutter/material.dart';
import 'package:flutter_mac/common/constants.dart';
import 'package:flutter_mac/common/pair.dart';
import 'package:flutter_mac/models/message_preference.dart';
import 'package:flutter_mac/preference/app_preference.dart';
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
  final _maxImageSize = 'maxImageSize';
  final _maxProfileImageSize = 'maxProfileImageSize';
  final _messageSound = 'messageSound';

  getImagePref() async {
    final SharedPreferences prefs = await _prefs;
    return ImagePreference(
        maxImageSize: prefs.getInt(_maxImageSize),
        maxProfileImageSize: prefs.getInt(_maxProfileImageSize));
  }

  getAppColorPref() async {
    final SharedPreferences prefs = await _prefs;
    return AppColorPref(
      appBarColor: prefs.getInt(_appBarColor),
      appBackgroundColor: Pair(prefs.getInt(_primaryBackgroundColor),
          prefs.getInt(_secondaryBackgroundColor)),
    );
  }

  Future<String> getMessageSound() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString(_messageSound) ??
        AssetsConstants.soundArray[0].second;
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

  setImagePref(ImagePreference pref) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setInt(_maxImageSize, pref.maxImageSize);
    await prefs.setInt(_maxProfileImageSize, pref.maxProfileImageSize);
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

  setMessageSound(String path) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString(_messageSound, path);
  }

  setMessageColorPreference(MessageColorPreference type, Color color) async {
    final SharedPreferences prefs = await _prefs;
    switch (type) {
      case MessageColorPreference.receiverBackgroundColor:
        prefs.setInt(_receiverBackgroundColor, color.value);
        break;
      case MessageColorPreference.receiverTextColor:
        prefs.setInt(_receiverTextColor, color.value);
        break;
      case MessageColorPreference.receiverTimeColor:
        prefs.setInt(_receiverTimeColor, color.value);
        break;
      case MessageColorPreference.senderBackgroundColor:
        prefs.setInt(_senderBackgroundColor, color.value);
        break;
      case MessageColorPreference.senderTextColor:
        prefs.setInt(_senderTextColor, color.value);
        break;
      case MessageColorPreference.senderTimeColor:
        prefs.setInt(_senderTimeColor, color.value);
        break;
      case MessageColorPreference.dateBackgroundColor:
        prefs.setInt(_dateBackgroundColor, color.value);
        break;
      case MessageColorPreference.dateTextColor:
        prefs.setInt(_dateTextColor, color.value);
        break;
    }
  }

  setMessageTimePreference(MessageSizePreference type, int value) async {
    final SharedPreferences prefs = await _prefs;
    switch (type) {
      case MessageSizePreference.messageTextSize:
        prefs.setInt(_messageTextSize, value);
        break;
      case MessageSizePreference.messageTimeSize:
        prefs.setInt(_messageTimeSize, value);
        break;
      case MessageSizePreference.dateTextSize:
        prefs.setInt(_dateTextSize, value);
        break;
    }
  }

  setMessageColorPreferenceV2(MessagePref msgPref) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setInt(
        _receiverBackgroundColor, msgPref.receiverBackgroundColor.value);
    prefs.setInt(_receiverTextColor, msgPref.receiverTextColor.value);
    prefs.setInt(_receiverTimeColor, msgPref.receiverTimeColor.value);
    prefs.setInt(_senderBackgroundColor, msgPref.senderBackgroundColor.value);
    prefs.setInt(_senderTextColor, msgPref.senderTextColor.value);
    prefs.setInt(_senderTimeColor, msgPref.senderTimeColor.value);
    prefs.setInt(_dateBackgroundColor, msgPref.dateBackgroundColor.value);
    prefs.setInt(_dateTextColor, msgPref.dateTextColor.value);
  }

  setMessageTimePreferenceV2(MessagePref msgPref) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setInt(_messageTextSize, msgPref.messageTextSize);
    prefs.setInt(_messageTimeSize, msgPref.messageTimeSize);
    prefs.setInt(_dateTextSize, msgPref.dateTextSize);
  }

  clearPreference() async {
    final SharedPreferences prefs = await _prefs;
    prefs.clear();
  }
}
