import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_mac/common/logger.dart';
import 'package:flutter_mac/common/pair.dart';
import 'package:image/image.dart';
import 'package:image_compression/image_compression.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

enum ImageStatus {
  IMAGE_SIZE_OVERLOAD,
  IMAGE_COMPRESSION_EXCEPTION,
  IMAGE_PICKER_EXCEPTION,
  IMAGE_PICKER_NULL,
  IMAGE_COMPRESSION_NULL,
}

class ImageUtils {
  final _imageSize = 250000;
  final _maxImageSize = 500000;

  Future<Pair<File?, ImageStatus?>> pickImage(int? size) async {
    try {
      final ImagePicker picker = ImagePicker();
      final file = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: Platform.isMacOS ? 5 : null);
      if (file != null) {
        if (await file.length() > _maxImageSize) {
          return await compressFile(File(file.path), size);
        } else {
          return Pair(File(file.path), null);
        }
      }
      Logger.print("file == null");
      return Pair(null, null);
    } catch (e, s) {
      Logger.print('Failed to pick image: $e');
      return Pair(null, ImageStatus.IMAGE_PICKER_EXCEPTION);
    }
  }

  Future<Pair<File?, ImageStatus?>> compressFile(File file, int? size) async {
    try {
      String outPath;
      int quality;

      if (Platform.isAndroid || Platform.isIOS) {
        final filePath = file.absolute.path;
        final lastIndex = filePath.lastIndexOf(RegExp(r'.png|.jp'));
        final String splitted = filePath.substring(0, (lastIndex));
        Logger.print("File - $filePath");
        Logger.print("File Size - ${file.lengthSync()}");
        quality = 70;
        outPath = "${splitted}1${filePath.substring(lastIndex)}";

        var result = await FlutterImageCompress.compressAndGetFile(
          file.absolute.path,
          outPath,
          quality: quality,
        );

        if (result != null) {
          quality--;
          while (await result!.length() > (size ?? _imageSize) && quality > 0) {
            result = await FlutterImageCompress.compressAndGetFile(
              file.absolute.path,
              outPath,
              quality: quality,
            );
            Logger.print(
                "Next Compressed file Size - ${await result!.length()}, quality- $quality");
            quality--;
          }
          Logger.print("File - ${result.path}");
          Logger.print(
              "Final file Size - ${await result.length()}, quality- $quality");
          if (await result.length() > (size ?? _imageSize)) {
            return Pair(null, ImageStatus.IMAGE_SIZE_OVERLOAD);
          }
          return Pair(File(result.path), null);
        }
        return Pair(null, ImageStatus.IMAGE_COMPRESSION_NULL);
      } else {
        final path = await getTemporaryDirectory();
        File imageFile = await _convertPngToJpg(file, path);
        final lastIndex =
            imageFile.absolute.path.lastIndexOf(RegExp(r'.png|.jp'));
        outPath =
            "${path.path}/2${imageFile.absolute.path.substring(lastIndex)}";
        quality = 10;
        Logger.print("File - ${imageFile.absolute.path}");
        Logger.print("File Size - ${imageFile.lengthSync()}");

        var output = await compressInQueue(ImageFileConfiguration(
            config: Configuration(jpgQuality: quality),
            input: ImageFile(
              rawBytes: imageFile.readAsBytesSync(),
              filePath: imageFile.path,
            )));
        quality--;
        while (output.sizeInBytes > (size ?? _imageSize) && quality > 0) {
          File tmpFile = await File(outPath).create();
          tmpFile.writeAsBytesSync(output.rawBytes);

          Logger.print("Next compression size - ${output.sizeInBytes}");
          output = await compressInQueue(ImageFileConfiguration(
              config: Configuration(
                  jpgQuality: quality,
                  pngCompression: PngCompression.bestCompression),
              input: ImageFile(
                rawBytes: tmpFile.readAsBytesSync(),
                filePath: tmpFile.path,
              )));
          quality--;
        }
        Logger.print(
            "Final File size - ${output.sizeInBytes}, quality - $quality");
        if (output.sizeInBytes > (size ?? _imageSize)) {
          return Pair(null, ImageStatus.IMAGE_SIZE_OVERLOAD);
        }
        return Pair(File.fromRawPath(output.rawBytes), null);
      }
    } catch (e, s) {
      Logger.print(e.toString());
      Logger.print(s.toString());
      return Pair(null, ImageStatus.IMAGE_COMPRESSION_EXCEPTION);
    }
  }

  _convertPngToJpg(File file, Directory path) async {
    // final filePath = file.absolute.path.replaceAll(' ', '%20');
    // final lastIndex = filePath.lastIndexOf(RegExp(r'.png|.jp'));
    // if (filePath.substring(lastIndex) == 'png') {
    // final image = decodeImage(file.readAsBytesSync())!;

    // final w = await File('${path.path}/1.png').writeAsBytes(encodePng(image));
    // return w;
    // }
    return file;
  }
}
