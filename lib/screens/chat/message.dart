import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mac/models/message.dart';
import 'package:flutter_mac/models/state_enums.dart';
import 'package:flutter_mac/screens/image_preview.dart';
import 'package:flutter_mac/services/utils.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MessageWidget extends StatefulWidget {
  const MessageWidget({super.key, this.msg});
  final MessageV2? msg;
  @override
  State<MessageWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MessageWidget> {
  @override
  Widget build(BuildContext context) {
    MessageV2? msg = widget.msg;
    if (msg == null) {
      return const SpinKitDualRing(
        color: Colors.red,
      );
    } else {
      return Row(
        mainAxisAlignment:
            msg.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
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
                        const SizedBox(height: 5),
                        Text(
                          DateFormat('HH:mm').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  msg.timestamp)),
                          style: TextStyle(
                              color: msg.messageType == MessageType.STICKER
                                  ? Colors.black
                                  : Colors.white),
                        )
                      ],
                    ))),
          ),
        ],
      );
    }
  }

  Widget _buildMessageWidget(MessageV2? msg) {
    if (msg!.messageType == MessageType.TEXT) {
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
    } else {
      return Image.network(
        msg.url!,
        gaplessPlayback: true,
        fit: BoxFit.contain,
        height: 150,
        width: 150,
      );
    }
  }

  _getBoxColor(MessageV2 msg) {
    if (msg.messageType == MessageType.STICKER) {
      return Colors.transparent;
    } else if (msg.isMe) {
      return Colors.blue;
    } else {
      return const Color.fromARGB(255, 19, 206, 44);
    }
  }

  _getBoxMargin(MessageV2 msg) {
    return msg.messageType != MessageType.TEXT
        ? const EdgeInsets.all(8.0)
        : EdgeInsets.fromLTRB(msg.isMe ? 30 : 8, 4, msg.isMe ? 8 : 30, 4);
  }

  _getBoxPadding(MessageV2 msg) {
    return msg.messageType != MessageType.TEXT
        ? const EdgeInsets.all(8.0)
        : EdgeInsets.fromLTRB(msg.isMe ? 10 : 8, 8, msg.isMe ? 8 : 10, 8);
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
