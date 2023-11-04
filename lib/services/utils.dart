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

  Future<File?> pickImage(int? quality, int? size) async {
    try {
      final ImagePicker picker = ImagePicker();
      final c = await picker.pickImage(source: ImageSource.gallery);
      if (c != null) {
        File? f = File(c.path);
        while (f!.lengthSync() > (size ?? 250000)) {
          f = await ImageUtils().compressFile(File(c.path), quality);
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
  Future<File?> compressFile(File file, int? quality) async {
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
        quality: quality ?? 5,
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
