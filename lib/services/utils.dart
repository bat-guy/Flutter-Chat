import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

class ChatUtils {
  final String uid;
  ChatUtils({required this.uid});

  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final c = await picker.pickImage(source: ImageSource.gallery);
      if (c != null) {
        File? f = File(c.path);
        while (f!.lengthSync() > 250000) {
          f = await ImageUtils().compressFile(File(c.path));
        }
        return f;
      }
      print("c == null");
      return null;
    } catch (e, s) {
      print('Failed to pick image: $s');
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

        return finalFile;
      } else {
        return null;
      }
    } catch (e, s) {
      print(s);
      return null;
    }
  }
}
