import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_mac/models/message.dart';
import 'package:flutter_mac/models/state_enums.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});

  final CollectionReference _messageCollection =
      FirebaseFirestore.instance.collection('messages-list');
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');
  DocumentSnapshot? _lastDoc;
  var loading = false;
  final _messageLimit = 30;

  Stream<List<MessageV2>> get messages {
    return _messageCollection
        .orderBy('timestamp', descending: true)
        .limit(_messageLimit)
        .snapshots()
        .map(_messageListFromSnapshot);
  }

  Future sendMessage({required String msg}) async {
    return await _messageCollection.add({
      'uid': uid,
      'msg': msg,
      'message_type': MessageType.TEXT,
      'timestamp': DateTime.timestamp().millisecondsSinceEpoch
    });
  }

  Future sendImage({required String url}) async {
    return await _messageCollection.add({
      'uid': uid,
      'url': url,
      'message_type': MessageType.IMAGE,
      'timestamp': DateTime.timestamp().millisecondsSinceEpoch
    });
  }

  Future sendGIF({required String url}) async {
    return await _messageCollection.add({
      'uid': uid,
      'url': url,
      'message_type': MessageType.GIF,
      'timestamp': DateTime.timestamp().millisecondsSinceEpoch
    });
  }

  Future sendSticker({required String url}) async {
    return await _messageCollection.add({
      'uid': uid,
      'url': url,
      'message_type': MessageType.STICKER,
      'timestamp': DateTime.timestamp().millisecondsSinceEpoch
    });
  }

  Future<bool> createUser(String uid) async {
    final response = await _userCollection.doc(uid).get();
    if (!response.exists) {
      await _userCollection.doc(uid).set({'uid': uid});
      return false;
    } else {
      return true;
    }
  }

  Future<List<MessageV2>?> getOldMessageListSnapshot() async {
    if (!loading && _lastDoc != null) {
      loading = true;
      var data = await _messageCollection
          .orderBy('timestamp', descending: true)
          .startAfterDocument(_lastDoc!)
          .limit(_messageLimit)
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

  List<MessageV2> _messageListFromSnapshot(QuerySnapshot snapshot) {
    final list = <MessageV2>[];
    _lastDoc ??= snapshot.docs.last;
    for (var e in snapshot.docChanges) {
      switch (e.type) {
        case DocumentChangeType.added:
          list.add(MessageV2.fromMap(e.doc, uid, false));
          print('added');
          break;
        case DocumentChangeType.modified:
          print('modified');
          break;
        case DocumentChangeType.removed:
          print('removed');
          break;
      }
    }
    return list;
  }

  /// Method that creates the chat list from querySnapshot.
  List<MessageV2> _setChatListFromQuerySnapshot(QuerySnapshot data) {
    final list = <MessageV2>[];
    if (data.docs.isNotEmpty) {
      for (var e in data.docs) {
        list.add(MessageV2.fromMap(e, uid, false));
      }
    }
    return list;
  }
}
