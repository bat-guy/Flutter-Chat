import 'package:cloud_firestore/cloud_firestore.dart';

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
      this.name,
      this.imageUrl,
      required this.timestamp,
      required this.isMe});

  static Message fromMap(QueryDocumentSnapshot<Object?> e, String uid) {
    return Message(
        uid: uid,
        id: e.id,
        isMe: e.get('uid') == uid,
        msg: e.get('msg'),
        name: e.get('name'),
        timestamp: e.get('timestamp'),
        imageUrl: e.get('image_url'));
  }
}

class MessageV2 {
  String id;
  String? msg;
  String? name;
  String? url;
  String messageType;
  int timestamp;
  bool isMe;
  MessageV2(
      {required this.id,
      this.msg,
      this.name,
      this.url,
      required this.timestamp,
      required this.messageType,
      required this.isMe});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "msg": msg,
      "name": name,
      "url": url,
      "message_type": messageType,
      "timestamp": timestamp,
    };
  }

  static MessageV2 fromMap(QueryDocumentSnapshot<Object?> e, String uid) {
    return MessageV2(
        id: e.id,
        isMe: e.get('uid') == uid,
        msg: e.get('msg'),
        name: e.get('name'),
        messageType: e.get('message_type'),
        timestamp: e.get('timestamp'),
        url: e.get('url'));
  }
}
