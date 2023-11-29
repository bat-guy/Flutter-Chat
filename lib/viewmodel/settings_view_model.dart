import 'dart:async';

import 'package:flutter_mac/preference/app_preference.dart';
import 'package:flutter_mac/preference/shared_preference.dart';
import 'package:flutter_mac/services/database.dart';

class SettingsViewModel {
  late DatabaseService _db;
  final _pref = AppPreference();
  final _loading = StreamController<bool>();
  final _appColorPref = StreamController<AppColorPref>();
  final _messagePref = StreamController<MessagePref>();
  final _messageSound = StreamController<String>();

  get loading => _loading.stream;
  get appColorPref => _appColorPref.stream;
  get messagePref => _messagePref.stream;
  get messageSound => _messageSound.stream;

  SettingsViewModel(String uid) {
    _getPref();
    _loading.add(false);
    _db = DatabaseService(uid: uid);
  }

  _getPref() async {
    _appColorPref.add(await _pref.getAppColorPref());
    _messagePref.add(await _pref.getMessagePref());
    _messageSound.add(await _pref.getMessageSound());
  }

  savePreference(
      MessagePref msgPref, AppColorPref appColorPref, String soundPref) async {
    _loading.add(true);
    await _db.setPreference(msgPref, appColorPref, soundPref);
    await _pref.setMessageColorPreferenceV2(msgPref);
    await _pref.setMessageTimePreferenceV2(msgPref);
    await _pref.setAppBarColor(appColorPref.appBarColor);
    await _pref.setAppBackgroundColor(appColorPref.appBackgroundColor);
    await _pref.setMessageSound(soundPref);
    _loading.add(false);
  }

  dispose() {
    _loading.close();
    _appColorPref.close();
    _messagePref.close();
    _messageSound.close();
  }
}
