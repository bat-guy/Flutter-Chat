import 'dart:developer';
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_mac/common/pair.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_compression/image_compression.dart';

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
          return await ImageUtils().compressFile(File(file.path), size);
        } else {
          return Pair(File(file.path), null);
        }
      }
      log("file == null");
      return Pair(null, null);
    } catch (e, s) {
      log('Failed to pick image: $e');
      return Pair(null, ImageStatus.IMAGE_PICKER_EXCEPTION);
    }
  }

  Future<Pair<File?, ImageStatus?>> compressFile(File file, int? size) async {
    try {
      final filePath = file.absolute.path;
      final lastIndex = filePath.lastIndexOf(RegExp(r'.png|.jp'));
      final String splitted = filePath.substring(0, (lastIndex));
      String outPath;
      int quality;
      log("File - $filePath");
      log("File Size - ${file.lengthSync()}");

      if (Platform.isAndroid || Platform.isIOS) {
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
            log("Next Compressed file Size - ${await result!.length()}, quality- $quality");
            quality--;
          }
          log("File - ${result.path}");
          log("Final file Size - ${await result.length()}, quality- $quality");
          if (await result.length() > (size ?? _imageSize)) {
            return Pair(null, ImageStatus.IMAGE_SIZE_OVERLOAD);
          }
          return Pair(File(result.path), null);
        }
        return Pair(null, ImageStatus.IMAGE_COMPRESSION_NULL);
      } else {
        final path = await getTemporaryDirectory();
        outPath = "${path.path}/1${filePath.substring(lastIndex)}";
        quality = 10;
        var output = await compressInQueue(ImageFileConfiguration(
            config: Configuration(jpgQuality: quality),
            input: ImageFile(
              rawBytes: file.readAsBytesSync(),
              filePath: file.path,
            )));
        quality--;
        while (output.sizeInBytes > (size ?? _imageSize) && quality > 0) {
          File tmpFile = await File(outPath).create();
          tmpFile.writeAsBytesSync(output.rawBytes);

          log("Next compression size - ${output.sizeInBytes}");
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
        log("Final File size - ${output.sizeInBytes}, quality - $quality");
        if (output.sizeInBytes > (size ?? _imageSize)) {
          return Pair(null, ImageStatus.IMAGE_SIZE_OVERLOAD);
        }
        return Pair(File(output.filePath), null);
      }
    } catch (e, s) {
      log(e.toString());
      log(s.toString());
      return Pair(null, ImageStatus.IMAGE_COMPRESSION_EXCEPTION);
    }
  }
}

class TextUtils {
  //This method takes a raw string and gives out a List<TexSpan> that contain normal text and links.
  static List<TextSpan> extractLinkText(
      String rawString, Color textColor, int fontSize) {
    List<TextSpan> textSpan = [];

    final urlRegExp = RegExp(
        r"((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?");

    getLink(String linkString) {
      textSpan.add(
        TextSpan(
          text: linkString,
          style: GoogleFonts.montserrat(
              color: textColor,
              fontSize: fontSize.toDouble(),
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              if (!await launchUrl(Uri.parse(linkString.contains('https://')
                  ? linkString
                  : "https://$linkString"))) {
                Fluttertoast.showToast(msg: "Could not launch $linkString");
              }
            },
        ),
      );
      return linkString;
    }

    getNormalText(String normalText) {
      textSpan.add(
        TextSpan(
          text: normalText,
          style: GoogleFonts.montserrat(
              color: textColor,
              fontSize: fontSize.toDouble(),
              fontWeight: FontWeight.w600),
        ),
      );
      return normalText;
    }

    rawString.splitMapJoin(
      urlRegExp,
      onMatch: (m) => getLink("${m.group(0)}"),
      onNonMatch: (n) => getNormalText("${n.substring(0)}"),
    );

    return textSpan;
  }
}

class DateTimeUtils {
  static String hourMinute = 'HH:mm';
  static String dayMonthYear = 'dd MMMM yyyy';

  static bool isDifferentDay(int previousTimeStamp, int currentTimeStamp) {
    return getDayMonthYearString(previousTimeStamp) !=
        getDayMonthYearString(currentTimeStamp);
  }

  static String getDayMonthYearString(int timeStamp) {
    return DateFormat(dayMonthYear)
        .format(DateTime.fromMillisecondsSinceEpoch(timeStamp));
  }

  static String getTimeByTimezone(int timestamp, String dateFormat) {
    return DateFormat(dateFormat).format(
        DateTime.fromMillisecondsSinceEpoch(timestamp).toUtc().add(
            DateTime.fromMillisecondsSinceEpoch(timestamp).timeZoneOffset));
  }
}

class ColorUtils {
  static int getColor(String hex) {
    String formattedHex = 'FF${hex.toUpperCase().replaceAll("#", "")}';
    return int.parse(formattedHex, radix: 16);
  }
}
