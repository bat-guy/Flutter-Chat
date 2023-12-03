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
}
