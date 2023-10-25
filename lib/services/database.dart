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

  Stream<List<MessageV2>> get messages {
    return _messageCollection
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .map(_messageListFromSnapshot);
  }

  Future sendMessage({required String msg, required String name}) async {
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
    if (!loading) {
      loading = true;
      var data = await _messageCollection
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

  List<MessageV2> _messageListFromSnapshot(QuerySnapshot snapshot) {
    var list = snapshot.docs.map((e) {
      return MessageV2.fromMap(e, uid);
    }).toList();
    _lastDoc ??= snapshot.docs.last;
    return list;
  }

  /// Method that creates the chat list from querySnapshot.
  List<MessageV2> _setChatListFromQuerySnapshot(QuerySnapshot data) {
    final list = <MessageV2>[];
    if (data.docs.isNotEmpty) {
      for (var e in data.docs) {
        list.add(MessageV2.fromMap(e, uid));
      }
    }
    return list;
  }
}
