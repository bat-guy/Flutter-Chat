import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_mac/common/constants.dart';
import 'package:flutter_mac/models/state_enums.dart';

class Message {
  String id;
  String? msg;
  String uid;
  String? name;
  String? imageUrl;
  Timestamp timestamp;
  bool isMe;
  Message(
      {required this.id,
      this.msg,
      required this.uid,
      this.imageUrl,
      required this.timestamp,
      required this.isMe});

  static Message fromMap(QueryDocumentSnapshot<Object?> e, String uid) {
    return Message(
        uid: e.get(ChatConstants.uid),
        id: e.id,
        isMe: e.get(ChatConstants.uid) == uid,
        msg: e.get(ChatConstants.msg),
        timestamp: e.get(ChatConstants.timestamp),
        imageUrl: e.get(ChatConstants.imageUrl));
  }
}

class MessageV2 {
  String? uid;
  String? id;
  String? msg;
  String? url;
  String messageType;
  int timestamp;
  bool? isMe;
  MessageV2(
      {this.id,
      this.uid,
      this.msg,
      this.url,
      required this.timestamp,
      required this.messageType,
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
    final v = (isDate)
        ? MessageV2(
            timestamp: e.get(ChatConstants.messageType),
            messageType: MessageType.DATE)
        : MessageV2(
            id: e.id,
            uid: e.get(ChatConstants.uid),
            isMe: e.get(ChatConstants.uid) == uid,
            msg: e.get(ChatConstants.messageType) != MessageType.TEXT
                ? null
                : e.get(ChatConstants.msg),
            messageType: e.get(ChatConstants.messageType),
            timestamp: e.get(ChatConstants.timestamp),
            url: (e.get(ChatConstants.messageType) == MessageType.GIF ||
                    e.get(ChatConstants.messageType) == MessageType.STICKER ||
                    e.get(ChatConstants.messageType) == MessageType.IMAGE)
                ? e.get(ChatConstants.url)
                : null);
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
