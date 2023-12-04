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
      required this.replyClicked,
      required this.guestName});
  final String guestName;
  final MessageV2 msg;
  final MessagePref messagePref;
  final Function(MessageV2) showReplyWidget;
  final Function(MessageV2) replyClicked;
  @override
  State<MessageWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MessageWidget> {
  final yourKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    MessageV2 msg = widget.msg;

    return Align(
      alignment: _getAlignment(msg),
      child: Container(
          margin: _getBoxMargin(msg),
          padding: _getBoxPadding(msg),
          decoration: BoxDecoration(
            color: _getBoxColor(msg, widget.messagePref),
            borderRadius: BorderRadius.circular(8.0),
            // boxShadow: _getBoxShadow(msg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              msg.messageType != MessageType.DATE
                  ? _showMessageOptions(
                      msg, widget.messagePref, widget.showReplyWidget)
                  : const SizedBox(),
              _buildReplyWidget(msg, widget.guestName, widget.replyClicked),
              _buildMessageWidget(msg),
              _buildDateWidget(msg)
            ],
          )),
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
      return Alignment.center;
    } else if (msg.isMe!) {
      return Alignment.centerRight;
    } else {
      return Alignment.centerLeft;
    }
  }

  Widget _buildMessageWidget(MessageV2 msg) {
    if (msg.messageType == MessageType.TEXT ||
        msg.messageType == MessageType.LINK_TEXT) {
      return SelectableText.rich(
        TextSpan(
          children: TextUtils.extractLinkText(
              msg.msg ?? '',
              msg.isMe!
                  ? widget.messagePref.senderTextColor
                  : widget.messagePref.receiverTextColor,
              widget.messagePref.messageTextSize),
        ),
      );
    } else if (msg.messageType == MessageType.IMAGE) {
      return GestureDetector(
          onTap: () =>
              ScreenNavigator.openImagePreview(msg.url as String, context),
          child: CachedNetworkImage(
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
            placeholder: (context, url) =>
                const SpinKitCircle(color: Colors.red),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            height: 150,
            width: 150,
          ));
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
    return (msg.messageType != MessageType.TEXT ||
            msg.messageType != MessageType.LINK_TEXT)
        ? const EdgeInsets.all(8.0)
        : EdgeInsets.fromLTRB(msg.isMe! ? 8 : 8, 4, msg.isMe! ? 8 : 30, 4);
  }

  _getBoxPadding(MessageV2 msg) {
    return (msg.messageType != MessageType.TEXT ||
            msg.messageType != MessageType.LINK_TEXT)
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

  PopupMenuButton<int> _showMessageOptions(
      MessageV2 msg, MessagePref pref, showReplyWidget) {
    return PopupMenuButton(
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
        if (value == 0) {
          showReplyWidget(msg);
        } else {
          await Clipboard.setData(ClipboardData(text: msg.msg.toString()));
          BotToast.showText(text: StringConstants.coppiedSuccessfully);
        }
      },
      itemBuilder: (context) {
        final list = [
          PopupMenuItem(value: 0, child: Text(StringConstants.reply))
        ];
        if (msg.messageType != MessageType.TEXT ||
            msg.messageType != MessageType.LINK_TEXT) {
          list.add(PopupMenuItem(value: 1, child: Text(StringConstants.copy)));
        }
        return list;
      },
    );
  }

  _buildReplyWidget(
      MessageV2 msg, String name, Function(MessageV2) replyClicked) {
    if (msg.reply != null) {
      return GestureDetector(
          onTap: () => replyClicked(msg),
          child: Container(
              padding: const EdgeInsets.all(5),
              margin: const EdgeInsets.only(bottom: 5),
              decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.white, width: 1, style: BorderStyle.solid),
                  color: Colors.white60,
                  borderRadius: BorderRadius.circular(5)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      msg.reply!.isMe ? '${StringConstants.you}:' : '$name:',
                      style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    _getReplyWidgetByType(msg.reply!),
                  ])));
    } else {
      return const SizedBox();
    }
  }

  _getReplyWidgetByType(ReplyType reply) {
    if (reply.messageType == MessageType.TEXT ||
        reply.messageType == MessageType.LINK_TEXT) {
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
