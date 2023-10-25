import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mac/models/message.dart';
import 'package:flutter_mac/models/state_enums.dart';
import 'package:flutter_mac/screens/image_preview.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MessageWidget extends StatelessWidget {
  const MessageWidget({super.key, this.msg});
  final MessageV2? msg;

  @override
  Widget build(BuildContext context) {
    if (msg == null) {
      return const SpinKitDualRing(
        color: Colors.red,
      );
    } else {
      return Align(
        alignment: msg!.isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: msg!.messageType != MessageType.TEXT
              ? const EdgeInsets.all(8.0)
              : EdgeInsets.fromLTRB(
                  msg!.isMe ? 30 : 8, 4, msg!.isMe ? 8 : 30, 4),
          padding: msg!.messageType != MessageType.TEXT
              ? const EdgeInsets.all(8.0)
              : EdgeInsets.fromLTRB(
                  msg!.isMe ? 10 : 8, 8, msg!.isMe ? 8 : 10, 8),
          decoration: BoxDecoration(
            color: msg!.isMe
                ? Colors.blue
                : const Color.fromARGB(255, 19, 206, 44),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: GestureDetector(
              onTap: () {
                if (msg!.messageType == MessageType.IMAGE) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ImagePreview(imageUrl: msg!.url as String)));
                }
              },
              onLongPress: () async {
                if (msg!.messageType == MessageType.TEXT) {
                  await Clipboard.setData(ClipboardData(text: msg!.msg!));
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
              child: _buildMessageWidget()),
        ),
      );
    }
  }

  _buildMessageWidget() {
    if (msg!.messageType == MessageType.TEXT) {
      Text(
        msg!.msg ?? '',
        softWrap: true,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      );
    } else if (msg!.messageType == MessageType.IMAGE) {
      CachedNetworkImage(
        imageUrl: msg!.url as String,
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
    }
  }
}
