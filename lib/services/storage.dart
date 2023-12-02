import 'dart:developer';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final String uid;
  StorageService({required this.uid});

  Future<String?> uploadImage(File? file, String? path) async {
    if (file != null) {
      final address = (path != null && path.isNotEmpty)
          ? path
          : DateTime.now().millisecondsSinceEpoch.toString();
      var snapshot = await FirebaseStorage.instance
          .ref()
          .child('images/$address')
          .putFile(file);
      return await snapshot.ref.getDownloadURL();
    } else {
      log('Picked File returned null');
      return null;
    }
  }

  Future<String?> uploadProfileImage(File? file) async {
    return uploadImage(file, '$uid/$uid');
  }
}
