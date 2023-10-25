import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;
import 'package:image_picker/image_picker.dart';

class StorageService {
  final String uid;
  StorageService({required this.uid});

  Future<Map<String, String>?> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      String extension = Path.extension(pickedFile!.path);

      if (pickedFile != null) {
        var map = Map<String, String>();
        map.putIfAbsent(pickedFile.path, extension as String Function());
        return map;
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('Image picker error: $e');
    }
  }

  Future<String?> uploadImage(XFile? file) async {
    if (file != null) {
      var snapshot = await FirebaseStorage.instance
          .ref()
          .child('images/${DateTime.now().millisecondsSinceEpoch.toString()}')
          .putFile(File(file.path));
      return await snapshot.ref.getDownloadURL();
    } else {
      print('Picked File returned null');
      return null;
    }
  }
}
