import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_mac/common/constants.dart';
import 'package:flutter_mac/models/message.dart';
import 'package:flutter_mac/models/state_enums.dart';
import 'package:flutter_mac/models/user.dart';

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
        .orderBy(ChatConstants.timestamp, descending: true)
        .limit(_messageLimit)
        .snapshots()
        .map(_messageListFromSnapshot);
  }

  Future sendMessage({required String msg}) async {
    return await _messageCollection.add({
      ChatConstants.uid: uid,
      ChatConstants.msg: msg,
      ChatConstants.messageType: MessageType.TEXT,
      ChatConstants.timestamp: DateTime.timestamp().millisecondsSinceEpoch
    });
  }

  Future sendImage({required String url}) async {
    return await _messageCollection.add({
      ChatConstants.uid: uid,
      ChatConstants.url: url,
      ChatConstants.messageType: MessageType.IMAGE,
      ChatConstants.timestamp: DateTime.timestamp().millisecondsSinceEpoch
    });
  }

  Future sendGIF({required String url}) async {
    return await _messageCollection.add({
      ChatConstants.uid: uid,
      ChatConstants.url: url,
      ChatConstants.messageType: MessageType.GIF,
      ChatConstants.timestamp: DateTime.timestamp().millisecondsSinceEpoch
    });
  }

  Future sendSticker({required String url}) async {
    return await _messageCollection.add({
      ChatConstants.uid: uid,
      ChatConstants.url: url,
      ChatConstants.messageType: MessageType.STICKER,
      ChatConstants.timestamp: DateTime.timestamp().millisecondsSinceEpoch
    });
  }

  Future<bool> createUser(String uid) async {
    final response = await _userCollection.doc(uid).get();
    if (!response.exists) {
      await _userCollection.doc(uid).set({ChatConstants.uid: uid});
      return false;
    } else {
      return true;
    }
  }

  Future<List<MessageV2>?> getOldMessageListSnapshot() async {
    if (!loading && _lastDoc != null) {
      loading = true;
      var data = await _messageCollection
          .orderBy(ChatConstants.timestamp, descending: true)
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

  Future<String> getUserId() async {
    var data = await _userCollection.get();
    if (data.docs.isNotEmpty) {
      for (var e in data.docs) {
        if (e.get(ChatConstants.uid) != uid) {
          return e.get(ChatConstants.uid);
        }
      }
    }
    return '';
  }

  setOnlineStatus(bool online) async {
    await _userCollection.doc(uid).update({ChatConstants.online: online});
  }

  Stream<bool> getOnlineStatus(String uid) {
    return _userCollection.doc(uid).snapshots().map(_onlineStatus);
  }

  bool _onlineStatus(DocumentSnapshot snapshot) {
    Map<String, dynamic>? map = snapshot.data() as Map<String, dynamic>?;
    return (map!.containsKey(ChatConstants.online))
        ? map[ChatConstants.online]
        : false;
  }

  Future<UserProfile> getUserprofile(String userId) async {
    final data = await _userCollection.doc(userId).get();
    return UserProfile.fromMap(data);
  }

  Future<void> updateUserProfilePicture(
      String userId, String profilePictureUrl) async {
    return await _userCollection
        .doc(userId)
        .update({ChatConstants.profilePicture: profilePictureUrl});
  }

  Future<void> updateUserDetails(
      String userId, String name, String quote) async {
    return await _userCollection
        .doc(userId)
        .update({ChatConstants.name: name, ChatConstants.quote: quote});
  }
}
