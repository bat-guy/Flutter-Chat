import 'dart:io';

import 'package:flutter_mac/common/constants.dart';
import 'package:flutter_mac/models/user.dart';
import 'package:flutter_mac/services/database.dart';
import 'package:flutter_mac/services/storage.dart';
import 'package:flutter_mac/services/utils.dart';

class ProfileViewModel {
  final String uid;

  late final DatabaseService _dbService;
  late final StorageService _storageService;
  late final ChatUtils _chatUtils;
  late UserProfile profile;

  ProfileViewModel({required this.uid}) {
    _dbService = DatabaseService(uid: uid);
    _storageService = StorageService(uid: uid);
    _chatUtils = ChatUtils(uid: uid);
  }

  Future<UserProfile> getProfile() async {
    profile = await _dbService.getUserprofile(uid);
    return profile;
  }

  updateProfilePicture() async {
    File? imageFile = await _chatUtils.pickImage(95, KeyConstants.oneMB);
    String? url = await _storageService.uploadImage(
        imageFile,
        (profile.profilePicture.isNotEmpty)
            ? profile.profilePicture
            : profile.uid);
    if (url != null) {
      await _dbService.updateUserProfilePicture(uid, url);
    }
  }

  updateUserDetails(String name, String quote) async {
    await _dbService.updateUserDetails(uid, name, quote);
  }
}
