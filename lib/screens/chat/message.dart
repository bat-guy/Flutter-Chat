import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mac/models/message.dart';
import 'package:flutter_mac/models/state_enums.dart';
import 'package:flutter_mac/screens/image_preview.dart';
import 'package:flutter_mac/services/utils.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class MessageWidget extends StatefulWidget {
  const MessageWidget({super.key, required this.msg});
  final MessageV2 msg;
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
                  color: _getBoxColor(msg),
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: _getBoxShadow(msg)),
              child: GestureDetector(
                  onTap: () {
                    if (msg.messageType == MessageType.IMAGE) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ImagePreview(imageUrl: msg.url as String)));
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
                                  color: msg.messageType == MessageType.STICKER
                                      ? Colors.black
                                      : Colors.white),
                            ),
                          ))
                    ],
                  ))),
        ),
      ],
    );
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
        children: TextUtils.extractLinkText(msg.msg ?? ''),
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
        style: TextStyle(color: _getDateTextColor(msg)),
      );
    }
  }

  _getBoxColor(MessageV2 msg) {
    if (msg.messageType == MessageType.DATE) {
      return const Color.fromARGB(70, 85, 85, 85);
    } else if (msg.messageType == MessageType.STICKER) {
      return Colors.transparent;
    } else if (msg.isMe!) {
      return Colors.blue;
    } else {
      return const Color.fromARGB(255, 19, 206, 44);
    }
  }

  _getDateTextColor(MessageV2 msg) {
    if (msg.messageType == MessageType.DATE) {
      return const Color.fromARGB(255, 245, 241, 241);
    } else if (msg.messageType == MessageType.STICKER) {
      return Colors.black;
    } else {
      return Colors.white;
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
