import 'package:flutter_mac/preference/app_preference.dart';
import 'package:flutter_mac/services/database.dart';
import 'package:flutter_mac/services/storage.dart';

class Repository {
  late final DatabaseService _db;
  late final StorageService _storage;

  Repository(String uid) {
    _db = DatabaseService(uid: uid);
    _storage = StorageService(uid: uid);
  }

  getUserList(String uid) async => await _db.getUserList(uid);

  getImagePreference() async => await _db.getImagePreference();

  getUserPreference() async => await _db.getUserPreference();

  setPreference(MessagePref msgPref, AppColorPref appColorPref,
          String soundPref) async =>
      await _db.setPreference(msgPref, appColorPref, soundPref);
}
