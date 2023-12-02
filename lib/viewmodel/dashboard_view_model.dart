import 'dart:async';
import 'package:flutter_mac/models/user.dart';
import 'package:flutter_mac/preference/app_preference.dart';
import 'package:flutter_mac/preference/shared_preference.dart';
import 'package:flutter_mac/services/database.dart';

class DashboardViewModel {
  late DatabaseService _dbService;
  final UserCred _user;
  final _pref = AppPreference();
  final StreamController<AppColorPref> _appColoPrefStream = StreamController();

  Stream<AppColorPref> get appColoPrefStream => _appColoPrefStream.stream;

  DashboardViewModel(this._user) {
    _dbService = DatabaseService(uid: _user.uid);
    _setPreference();
    _setImagePref();
    _refreshUserPref();
  }

  Future<List<UserProfile>> getUserList() async {
    return await _dbService.getUserList(_user.uid);
  }

  _setPreference() async {
    _appColoPrefStream.add(await _pref.getAppColorPref());
  }

  _setImagePref() async {
    _pref.setImagePref(await _dbService.getImagePreference());
  }

  _refreshUserPref() async {
    final AppPreferenceWrapper? prefData = await _dbService.getUserPreference();
    if (prefData == null) {
      final appColorPref = await _pref.getAppColorPref();
      final msgPref = await _pref.getMessagePref();
      final messageSoundPref = await _pref.getMessageSound();
      await _dbService.setPreference(msgPref, appColorPref, messageSoundPref);
    } else {
      await _pref.setMessageColorPreferenceV2(prefData.msgPref);
      await _pref.setMessageTimePreferenceV2(prefData.msgPref);
      await _pref.setAppBarColor(prefData.appColorPref.appBarColor);
      await _pref
          .setAppBackgroundColor(prefData.appColorPref.appBackgroundColor);
      await _pref.setMessageSound(prefData.messageSoundPref);
      _setPreference();
    }
  }

  void signOut() {
    _pref.clearPreference();
  }

  void refresh() {
    _setPreference();
  }

  void dispose() {
    _appColoPrefStream.close();
  }
}
