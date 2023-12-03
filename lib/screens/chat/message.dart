import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mac/common/constants.dart';
import 'package:flutter_mac/models/message.dart';
import 'package:flutter_mac/models/reply_type.dart';
import 'package:flutter_mac/models/state_enums.dart';
import 'package:flutter_mac/navigator.dart';
import 'package:flutter_mac/preference/app_preference.dart';
import 'package:flutter_mac/services/utils.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

class MessageWidget extends StatefulWidget {
  const MessageWidget(
      {super.key,
      required this.msg,
      required this.messagePref,
      required this.showReplyWidget,
      required this.guestName});
  final String guestName;
  final MessageV2 msg;
  final MessagePref messagePref;
  final Function(MessageV2) showReplyWidget;
  @override
  State<MessageWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MessageWidget> {
  final yourKey = GlobalKey();

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
                    if (!Platform.isMacOS &&
                        msg.messageType == MessageType.TEXT) {
                      await Clipboard.setData(ClipboardData(text: msg.msg!));
                      BotToast.showText(
                          text: StringConstants.coppiedSuccessfully);
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildMessageOptions(
                          msg, widget.messagePref, widget.showReplyWidget),
                      _buildReplyWidget(msg, widget.guestName),
                      _buildMessageWidget(msg),
                      _buildDateWidget(msg)
                    ],
                  ))),
        ),
      ],
    );
  }

  Visibility _buildDateWidget(MessageV2 msg) {
    return Visibility(
      visible: msg.messageType != MessageType.DATE,
      child: Container(
        padding: const EdgeInsets.only(top: 5),
        child: Text(
          DateTimeUtils.getTimeByTimezone(
              msg.timestamp, DateTimeUtils.hourMinute),
          style: TextStyle(
            fontSize: widget.messagePref.messageTimeSize.toDouble(),
            color: _getTimeColor(msg, widget.messagePref),
          ),
        ),
      ),
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
        : EdgeInsets.fromLTRB(msg.isMe! ? 8 : 8, 4, msg.isMe! ? 8 : 30, 4);
  }

  _getBoxPadding(MessageV2 msg) {
    return msg.messageType != MessageType.TEXT
        ? const EdgeInsets.all(8.0)
        : EdgeInsets.fromLTRB(msg.isMe! ? 8 : 8, 8, msg.isMe! ? 8 : 8, 8);
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

  _buildMessageOptions(MessageV2 msg, MessagePref pref, showReplyWidget) {
    return Platform.isMacOS && msg.messageType != MessageType.DATE
        ? PopupMenuButton(
            constraints: const BoxConstraints(),
            iconSize: 10,
            child: Icon(
              key: yourKey,
              Icons.arrow_drop_down_outlined,
              size: 18,
              color: (msg.isMe != null && msg.isMe!)
                  ? pref.senderTextColor
                  : pref.receiverTextColor,
            ),
            onSelected: (value) async {
              if (value == 1) {
                await Clipboard.setData(
                    ClipboardData(text: msg.msg.toString()));
                BotToast.showText(text: StringConstants.coppiedSuccessfully);
              } else {
                showReplyWidget(msg);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 1, child: Text(StringConstants.copy)),
              PopupMenuItem(value: 2, child: Text(StringConstants.reply)),
            ],
          )
        : const SizedBox();
  }

  _buildReplyWidget(MessageV2 msg, String name) {
    if (msg.reply != null) {
      return Container(
          padding: const EdgeInsets.all(5),
          margin: const EdgeInsets.only(bottom: 5),
          decoration: BoxDecoration(
              border: Border.all(
                  color: Colors.white, width: 1, style: BorderStyle.solid),
              color: Colors.white60,
              borderRadius: BorderRadius.circular(5)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              msg.reply!.isMe ? '${StringConstants.you}:' : '$name:',
              style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600, fontSize: 12),
            ),
            const SizedBox(height: 8),
            _getReplyWidgetByType(msg.reply!),
          ]));
    } else {
      return const SizedBox();
    }
  }

  _getReplyWidgetByType(ReplyType reply) {
    if (reply.messageType == MessageType.TEXT) {
      return Text(
        reply.value,
        style:
            GoogleFonts.montserrat(fontWeight: FontWeight.normal, fontSize: 12),
      );
    } else {
      return CachedNetworkImage(
        imageUrl: reply.value,
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
        height: 80,
        width: 120,
      );
    }
  }
}
