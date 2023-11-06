import 'dart:developer';
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatUtils {
  final String uid;
  ChatUtils({required this.uid});

  Future<File?> pickImage(int? size) async {
    try {
      final ImagePicker picker = ImagePicker();
      final c = await picker.pickImage(source: ImageSource.gallery);
      if (c != null) {
        return await ImageUtils().compressFile(File(c.path), size);
      }
      log("file == null");
      return null;
    } catch (e, s) {
      log('Failed to pick image: $e');
      return null;
    }
  }
}

class ImageUtils {
  Future<File?> compressFile(File file, int? size) async {
    try {
      var quality = 95;
      final filePath = file.absolute.path;
      log("File - $filePath");
      log("File Size - ${file.lengthSync()}");
      final lastIndex = filePath.lastIndexOf(RegExp(r'.png|.jp'));
      final String splitted = filePath.substring(0, (lastIndex));

      final outPath = "${splitted}1${filePath.substring(lastIndex)}";

      var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        outPath,
        quality: quality,
      );

      if (result != null) {
        quality--;
        while (await result!.length() > (size ?? 250000)) {
          result = await FlutterImageCompress.compressAndGetFile(
            file.absolute.path,
            outPath,
            quality: quality,
          );
          quality--;
        }
        log("File - ${result.path}");
        log("Final file Size - ${await result.length()}, quality- $quality");
        return File(result.path);
      }
      return null;
    } catch (e, s) {
      log(e.toString());
      log(s.toString());
      return null;
    }
  }
}

class TextUtils {
  //This method takes a raw string and gives out a List<TexSpan> that contain normal text and links.
  static List<TextSpan> extractLinkText(String rawString) {
    List<TextSpan> textSpan = [];

    final urlRegExp = RegExp(
        r"((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?");

    getLink(String linkString) {
      textSpan.add(
        TextSpan(
          text: linkString,
          style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 16,
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
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
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
