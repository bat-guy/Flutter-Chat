import 'package:flutter_mac/common/constants.dart';

class ReplyType {
  String id;
  String uid;
  String messageType;
  int timestamp;
  String value;
  bool isMe;

  ReplyType(
      {required this.messageType,
      required this.id,
      required this.uid,
      required this.timestamp,
      required this.value,
      required this.isMe});

  static Map<String, dynamic> toMap(ReplyType reply) {
    return <String, dynamic>{
      ChatConstants.uid: reply.uid,
      ChatConstants.id: reply.id,
      ChatConstants.messageType: reply.messageType,
      ChatConstants.timestamp: reply.timestamp,
      ChatConstants.value: reply.value,
    };
  }

  static ReplyType? fromMap(Map<String, dynamic>? map, String uid) {
    return map == null
        ? null
        : ReplyType(
            uid: map[ChatConstants.uid],
            id: map[ChatConstants.id],
            messageType: map[ChatConstants.messageType],
            timestamp: map[ChatConstants.timestamp],
            value: map[ChatConstants.value],
            isMe: map[ChatConstants.value] == uid,
          );
  }
}
