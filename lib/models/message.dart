import 'package:cloud_firestore/cloud_firestore.dart';
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
        uid: e.get('uid'),
        id: e.id,
        isMe: e.get('uid') == uid,
        msg: e.get('msg'),
        timestamp: e.get('timestamp'),
        imageUrl: e.get('image_url'));
  }
}

class MessageV2 {
  String uid;
  String id;
  String? msg;
  String? url;
  String messageType;
  int timestamp;
  bool isMe;
  MessageV2(
      {required this.id,
      required this.uid,
      this.msg,
      this.url,
      required this.timestamp,
      required this.messageType,
      required this.isMe});

  Map<String, dynamic> toMapEntry() {
    return {
      "uid": uid,
      "msg": msg,
      "url": url,
      "message_type": messageType,
      "timestamp": timestamp,
    };
  }

  static MessageV2 fromMap(
      DocumentSnapshot<Object?> e, String uid, bool print1) {
    final v = MessageV2(
        id: e.id,
        uid: e.get('uid'),
        isMe: e.get('uid') == uid,
        msg: e.get('message_type') != MessageType.TEXT ? null : e.get('msg'),
        messageType: e.get('message_type'),
        timestamp: e.get('timestamp'),
        url: (e.get('message_type') == MessageType.GIF ||
                e.get('message_type') == MessageType.STICKER ||
                e.get('message_type') == MessageType.IMAGE)
            ? e.get('url')
            : null);
    if (print1)
      print("${v.id}, ${v.messageType}, msg -> ${v.msg}, url -> ${v.url}");
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
