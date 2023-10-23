class Message {
  String id;
  String? msg;
  String uid;
  String? name;
  String? imageUrl;
  bool isMe;
  Message(
      {required this.id,
      this.msg,
      required this.uid,
      this.name,
      this.imageUrl,
      required this.isMe});
}
