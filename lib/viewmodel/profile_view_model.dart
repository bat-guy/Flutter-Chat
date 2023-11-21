import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_mac/common/constants.dart';
import 'package:flutter_mac/common/pair.dart';
import 'package:flutter_mac/models/user.dart';
import 'package:flutter_mac/services/Image_utils.dart';
import 'package:flutter_mac/services/database.dart';
import 'package:flutter_mac/services/storage.dart';

class ProfileViewModel {
  final String uid;

  late final DatabaseService _dbService;
  late final StorageService _storageService;
  late UserProfile profile;
  final _imageUtils = ImageUtils();
  final _loadingStreamController = StreamController<bool>();
  final _toastStreamController = StreamController<String>();

  ProfileViewModel({required this.uid}) {
    _dbService = DatabaseService(uid: uid);
    _storageService = StorageService(uid: uid);
    _loadingStreamController.add(false);
  }

  Future<UserProfile> getProfile() async {
    profile = await _dbService.getUserprofile(uid);
    return profile;
  }

  updateProfilePicture() async {
    _loadingStreamController.add(true);
    Pair<File?, ImageStatus?> imageFile =
        await _imageUtils.pickImage(KeyConstants.oneMB);

    if (imageFile.second != null) {
      switch (imageFile.second) {
        case ImageStatus.IMAGE_SIZE_OVERLOAD:
          _toastStreamController.add(StringConstants.useSmallerImage);
          break;
        case ImageStatus.IMAGE_PICKER_NULL:
          _toastStreamController
              .add('Error picking the image, please try again');
          break;
        case ImageStatus.IMAGE_PICKER_EXCEPTION:
          _toastStreamController
              .add('Error picking the image, please try again');
          break;
        case ImageStatus.IMAGE_COMPRESSION_NULL:
          break;
        case ImageStatus.IMAGE_COMPRESSION_EXCEPTION:
          break;
        case null:
          break;
      }
    } else {
      log('image received');
      String? url = await _storageService.uploadProfileImage(imageFile.first);
      if (url != null) {
        await _dbService.updateUserProfilePicture(uid, url);
      }
    }
    _loadingStreamController.add(false);
  }

  get loadingStream => _loadingStreamController.stream;
  get toastStream => _toastStreamController.stream;

  updateUserDetails(String name, String quote) async {
    await _dbService.updateUserDetails(uid, name, quote);
  }

  void dispose() {
    _loadingStreamController.close();
    _toastStreamController.close();
  }
}
