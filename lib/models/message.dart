import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_mac/common/constants.dart';
import 'package:flutter_mac/extensions.dart';
import 'package:flutter_mac/models/reply_type.dart';
import 'package:flutter_mac/models/state_enums.dart';

class MessageV2 {
  String? uid;
  String? id;
  String? msg;
  String? url;
  String messageType;
  int timestamp;
  bool? isMe;
  ReplyType? reply;
  MessageV2(
      {this.id,
      this.uid,
      this.msg,
      this.url,
      required this.timestamp,
      required this.messageType,
      this.reply,
      this.isMe});

  Map<String, dynamic> toMapEntry() {
    return {
      ChatConstants.uid: uid,
      ChatConstants.msg: msg,
      ChatConstants.url: url,
      ChatConstants.messageType: messageType,
      ChatConstants.timestamp: timestamp,
    };
  }

  static MessageV2 fromMap(
      DocumentSnapshot<Object?> e, String uid, bool isDate) {
    Map<String, dynamic>? map = e.data() as Map<String, dynamic>?;
    final v = (isDate)
        ? MessageV2(
            timestamp: map!.valueOrNull(ChatConstants.messageType),
            messageType: MessageType.DATE)
        : MessageV2(
            id: e.id,
            uid: map!.valueOrNull(ChatConstants.uid),
            isMe: map.valueOrNull(ChatConstants.uid) == uid,
            msg: map.valueOrNull(ChatConstants.msg),
            messageType: map.valueOrNull(ChatConstants.messageType),
            timestamp: map.valueOrNull(ChatConstants.timestamp),
            url: map.valueOrNull(ChatConstants.url),
            reply:
                ReplyType.fromMap(map.valueOrNull(ChatConstants.reply), uid));
    return v;
  }

  static List<Map<String, dynamic>> toMap(List<MessageV2> msgList) {
    List<Map<String, dynamic>> list = [];
    for (var msg in msgList) {
      Map<String, dynamic> step = msg.toMapEntry();
      list.add(step);
    }
    return list;
  }
}
