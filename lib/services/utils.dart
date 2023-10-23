import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_mac/services/database.dart';
import 'package:image_picker/image_picker.dart';

class ChatUtils {
  final String uid;
  ChatUtils({required this.uid});

  final ImagePicker _picker = ImagePicker();
  Future<String?> sendImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? response =
          await picker.pickImage(source: ImageSource.gallery);

      // File? file;
      // if (response != null) {
      //   file = await ImageUtils().compressFile(File(response.path));
      // } else {
      //   print('Image Picker returned null');
      //   return;
      // }
      if (response != null) {
        var snapshot = await FirebaseStorage.instance
            .ref()
            .child('images/${DateTime.now().millisecondsSinceEpoch.toString()}')
            .putFile(File(response.path));
        return await snapshot.ref.getDownloadURL();
      } else {
        print('File compressor returned null');
        return null;
      }
    } catch (e, s) {
      print('Failed to upload image: $s');
      return null;
    }
  }
}

class ImageUtils {
  Future<File?> compressFile(File file) async {
    try {
      final filePath = file.absolute.path;

      // Create output file path
      // eg:- "Volume/VM/abcd_out.jpeg"
      final lastIndex = filePath.lastIndexOf(new RegExp(r'.png|.jp'));
      final splitted = filePath.substring(0, (lastIndex));
      final outPath = "${splitted}_out${filePath.substring(lastIndex)}";
      var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        outPath,
        quality: 5,
      );

      if (result != null) {
        var finalFile = File(result.path);
        print(file.lengthSync());
        print(finalFile.lengthSync());

        return file;
      } else {
        return null;
      }
    } catch (e, s) {
      print(s);
      return null;
    }
  }
}
