import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mac/models/message.dart';
import 'package:flutter_mac/models/state_enums.dart';
import 'package:flutter_mac/navigator.dart';
import 'package:flutter_mac/preference/app_color_preference.dart';
import 'package:flutter_mac/services/utils.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MessageWidget extends StatefulWidget {
  const MessageWidget(
      {super.key, required this.msg, required this.messagePref});
  final MessageV2 msg;
  final MessagePref messagePref;
  @override
  State<MessageWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MessageWidget> {
  @override
  Widget build(BuildContext context) {
    MessageV2 msg = widget.msg;

    return Row(
      mainAxisAlignment: _getAlignment(msg),
      children: [
        Flexible(
          child: Container(
              margin: _getBoxMargin(msg),
              padding: _getBoxPadding(msg),
              decoration: BoxDecoration(
                color: _getBoxColor(msg, widget.messagePref),
                borderRadius: BorderRadius.circular(8.0),
                // boxShadow: _getBoxShadow(msg),
              ),
              child: GestureDetector(
                  onTap: () {
                    if (msg.messageType == MessageType.IMAGE) {
                      ScreenNavigator.openImagePreview(
                          msg.url as String, context);
                    }
                  },
                  onLongPress: () async {
                    if (msg.messageType == MessageType.TEXT) {
                      await Clipboard.setData(ClipboardData(text: msg.msg!));
                      Fluttertoast.showToast(
                          msg: 'Copied Successfully',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildMessageWidget(msg),
                      Visibility(
                        visible: msg.messageType != MessageType.DATE,
                        child: Container(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            DateTimeUtils.getTimeByTimezone(
                                msg.timestamp, DateTimeUtils.hourMinute),
                            style: TextStyle(
                              fontSize:
                                  widget.messagePref.messageTimeSize.toDouble(),
                              color: _getTimeColor(msg, widget.messagePref),
                            ),
                          ),
                        ),
                      )
                    ],
                  ))),
        ),
      ],
    );
  }

  Color _getTimeColor(MessageV2 msg, MessagePref pref) {
    if (msg.messageType == MessageType.DATE) {
      return pref.senderTimeColor;
    } else if (msg.isMe!) {
      return widget.messagePref.senderTimeColor;
    } else {
      return widget.messagePref.receiverTimeColor;
    }
  }

  _getAlignment(MessageV2 msg) {
    if (msg.messageType == MessageType.DATE) {
      return MainAxisAlignment.center;
    } else if (msg.isMe!) {
      return MainAxisAlignment.end;
    } else {
      return MainAxisAlignment.start;
    }
  }

  Widget _buildMessageWidget(MessageV2 msg) {
    if (msg.messageType == MessageType.TEXT) {
      return SelectableText.rich(TextSpan(
        children: TextUtils.extractLinkText(
            msg.msg ?? '',
            msg.isMe!
                ? widget.messagePref.senderTextColor
                : widget.messagePref.receiverTextColor,
            widget.messagePref.messageTextSize),
      ));
    } else if (msg.messageType == MessageType.IMAGE) {
      return CachedNetworkImage(
        imageUrl: msg.url as String,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
              colorFilter: const ColorFilter.mode(
                Colors.transparent,
                BlendMode.colorBurn,
              ),
            ),
          ),
        ),
        placeholder: (context, url) => const SpinKitCircle(color: Colors.red),
        errorWidget: (context, url, error) => const Icon(Icons.error),
        height: 150,
        width: 150,
      );
    } else if (msg.messageType == MessageType.GIF ||
        msg.messageType == MessageType.STICKER) {
      return CachedNetworkImage(
        imageUrl: msg.url as String,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.fitHeight,
              colorFilter: const ColorFilter.mode(
                Colors.transparent,
                BlendMode.colorBurn,
              ),
            ),
          ),
        ),
        placeholder: (context, url) => const SpinKitCircle(color: Colors.red),
        errorWidget: (context, url, error) => const Icon(Icons.error),
        height: 150,
        width: 200,
      );
    } else {
      return Text(
        DateTimeUtils.getDayMonthYearString(msg.timestamp),
        style: TextStyle(
            color: widget.messagePref.dateTextColor,
            fontSize: widget.messagePref.dateTextSize.toDouble()),
      );
    }
  }

  _getBoxColor(MessageV2 msg, MessagePref pref) {
    if (msg.messageType == MessageType.DATE) {
      return pref.dateBackgroundColor;
    } else if (msg.isMe!) {
      return pref.senderBackgroundColor;
    } else {
      return pref.receiverBackgroundColor;
    }
  }

  _getBoxMargin(MessageV2 msg) {
    return msg.messageType != MessageType.TEXT
        ? const EdgeInsets.all(8.0)
        : EdgeInsets.fromLTRB(msg.isMe! ? 30 : 8, 4, msg.isMe! ? 8 : 30, 4);
  }

  _getBoxPadding(MessageV2 msg) {
    return msg.messageType != MessageType.TEXT
        ? const EdgeInsets.all(8.0)
        : EdgeInsets.fromLTRB(msg.isMe! ? 10 : 8, 8, msg.isMe! ? 8 : 10, 8);
  }

  _getBoxShadow(MessageV2 msg) {
    if (msg.messageType != MessageType.STICKER) {
      return [
        BoxShadow(
          color: const Color.fromARGB(255, 191, 191, 191).withOpacity(0.5),
          spreadRadius: 1,
          blurRadius: 4,
          offset: const Offset(0, 4), // changes position of shadow
        ),
      ];
    } else {
      return null;
    }
  }
}
