import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_mac/models/message.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid}) {
    FirebaseFirestore.instance.settings.persistenceEnabled;
  }

  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('messages');
  DocumentSnapshot? _lastDoc;
  var loading = false;

  Stream<List<Message>> get messages {
    return _collection
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .map(_messageListFromSnapshot);
  }

  Future sendMessage(
      {String? msg,
      String? name,
      String? imageUrl,
      required String uid}) async {
    return await _collection.add({
      'name': name,
      'msg': msg,
      'uid': uid,
      'image_url': imageUrl,
      'timestamp': FieldValue.serverTimestamp()
    });
  }

  Future<List<Message>?> getOldMessageListSnapshot() async {
    if (!loading) {
      loading = true;
      var data = await _collection
          .orderBy('timestamp', descending: true)
          .startAfterDocument(_lastDoc!)
          .limit(20)
          .get();
      loading = false;
      if (data.docs.isNotEmpty) {
        _lastDoc = data.docs.last;
        return _setChatListFromQuerySnapshot(data);
      }
    }
    loading = false;
    return null;
  }

  List<Message> _messageListFromSnapshot(QuerySnapshot snapshot) {
    var list = snapshot.docs.map((e) {
      try {
        Timestamp a = e.get('timestamp');
        // print(a);
      } catch (e, s) {
        print(e);
      }
      return Message(
          id: e.id,
          isMe: e.get('uid') == uid,
          msg: e.get('msg'),
          uid: e.get('uid'),
          name: e.get('name'),
          imageUrl: e.get('image_url'));
    }).toList();
    _lastDoc ??= snapshot.docs.last;
    return list;
  }

  /// Method that creates the chat list from querySnapshot.
  List<Message> _setChatListFromQuerySnapshot(QuerySnapshot data) {
    final list = <Message>[];
    if (data.docs.isNotEmpty) {
      for (var e in data.docs) {
        list.add(Message(
            id: e.id,
            isMe: e.get('uid') == uid,
            msg: e.get('msg'),
            uid: e.get('uid'),
            name: e.get('name'),
            imageUrl: e.get('image_url')));
      }
    }
    return list;
  }
}
