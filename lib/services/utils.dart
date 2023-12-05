import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class TextUtils {
  static final RegExp _urlRegExp = RegExp(
      r"((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?");
  //This method takes a raw string and gives out a List<TexSpan> that contain normal text and links.
  static List<TextSpan> extractLinkText(
      String rawString, TextStyle linkTextStyle, TextStyle normalTextStyle) {
    List<TextSpan> textSpan = [];

    getLink(String linkString) {
      textSpan.add(
        TextSpan(
          text: linkString,
          style: linkTextStyle,
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              if (!await launchUrl(Uri.parse(linkString.contains('https://')
                  ? linkString
                  : "https://$linkString"))) {
                BotToast.showText(text: 'Could not launch $linkString');
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
          style: normalTextStyle,
        ),
      );
      return normalText;
    }

    rawString.splitMapJoin(
      _urlRegExp,
      onMatch: (m) => getLink("${m.group(0)}"),
      onNonMatch: (n) => getNormalText("${n.substring(0)}"),
    );

    return textSpan;
  }

  static bool checkLinks(String text) {
    var containsLinks = false;
    text.splitMapJoin(
      _urlRegExp,
      onMatch: (m) {
        containsLinks = true;
        return '';
      },
      onNonMatch: (m) => '',
    );
    return containsLinks;
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
