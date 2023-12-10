import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_mac/common/constants.dart';
import 'package:flutter_mac/common/pair.dart';
import 'package:flutter_mac/models/user.dart';
import 'package:flutter_mac/preference/app_preference.dart';
import 'package:flutter_mac/preference/shared_preference.dart';
import 'package:flutter_mac/repo/repository.dart';
import 'package:flutter_mac/services/Image_utils.dart';

class ProfileViewModel {
  final String uid;
  late final Repository _repo;
  late UserProfile profile;
  late final ImageUtils _imageUtils;
  late final ImagePreference _imagePref;
  final _loadingStreamController = StreamController<bool>();
  final _toastStreamController = StreamController<String>();

  ProfileViewModel({required this.uid, required AppPreference pref}) {
    _repo = Repository(uid);
    _loadingStreamController.add(false);
    _setImageUtils(pref);
  }

  _setImageUtils(AppPreference pref) async {
    _imagePref = await pref.getImagePref();
    _imageUtils = ImageUtils(pref: await pref.getImagePref());
  }

  Future<UserProfile> getProfile() async {
    profile = await _repo.getUserprofile(uid);
    return profile;
  }

  updateProfilePicture() async {
    _loadingStreamController.add(true);
    Pair<File?, ImageStatus?> imageFile =
        await _imageUtils.pickImage(_imagePref.maxProfileImageSize);

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
      String? url = await _repo.uploadProfileImage(imageFile.first);
      if (url != null) {
        await _repo.updateUserProfilePicture(uid, url);
      }
    }
    _loadingStreamController.add(false);
  }

  get loadingStream => _loadingStreamController.stream;
  get toastStream => _toastStreamController.stream;

  updateUserDetails(String name, String quote) async {
    await _repo.updateUserDetails(uid, name, quote);
  }

  void dispose() {
    _loadingStreamController.close();
    _toastStreamController.close();
  }
}
