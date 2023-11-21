import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

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
