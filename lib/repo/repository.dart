import 'dart:io';
import 'package:flutter_mac/models/reply_type.dart';
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

  getUserprofile(String userId) async => await _db.getUserprofile(userId);

  updateUserProfilePicture(String userId, String profilePictureUrl) async =>
      await _db.updateUserProfilePicture(userId, profilePictureUrl);

  updateUserDetails(String userId, String name, String quote) async =>
      await _db.updateUserDetails(userId, name, quote);

  uploadProfileImage(File? file) async =>
      await _storage.uploadProfileImage(file);

  get messages => _db.messages;

  get loading => _db.loading;

  getOldMessageListSnapshot() async => await _db.getOldMessageListSnapshot();

  sendMessage(
          {required String msg,
          required bool isLinktext,
          required ReplyType? reply}) async =>
      await _db.sendMessage(msg: msg, isLinktext: isLinktext, reply: reply);

  sendMedia(
          {required String url,
          required String messagType,
          required ReplyType? reply}) async =>
      await _db.sendMedia(url: url, messagType: messagType, reply: reply);

  Future<String?> uploadImage(File? file, String? path) async =>
      await _storage.uploadImage(file, path);
}
