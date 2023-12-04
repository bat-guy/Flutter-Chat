import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_mac/common/constants.dart';
import 'package:flutter_mac/common/pair.dart';
import 'package:flutter_mac/extensions.dart';
import 'package:flutter_mac/models/message.dart';
import 'package:flutter_mac/models/reply_type.dart';
import 'package:flutter_mac/models/state_enums.dart';
import 'package:flutter_mac/models/user.dart';
import 'package:flutter_mac/preference/app_preference.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});

  final CollectionReference _messageCollection =
      FirebaseFirestore.instance.collection('messages-list');
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference _preferenceCollection =
      FirebaseFirestore.instance.collection('preference');
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

  Future sendMessage(
      {required String msg,
      required bool isLinktext,
      required ReplyType? reply}) async {
    final Map<String, dynamic> map = {
      ChatConstants.uid: uid,
      ChatConstants.msg: msg,
      ChatConstants.messageType:
          isLinktext ? MessageType.LINK_TEXT : MessageType.TEXT,
      ChatConstants.timestamp: DateTime.timestamp().millisecondsSinceEpoch
    };
    _addReplyObject(reply, map);
    return await _messageCollection.add(map);
  }

  Future sendImage({required String url, required ReplyType? reply}) async {
    final Map<String, dynamic> map = {
      ChatConstants.uid: uid,
      ChatConstants.url: url,
      ChatConstants.messageType: MessageType.IMAGE,
      ChatConstants.timestamp: DateTime.timestamp().millisecondsSinceEpoch
    };
    _addReplyObject(reply, map);
    return await _messageCollection.add(map);
  }

  Future sendGIF({required String url, required ReplyType? reply}) async {
    final Map<String, dynamic> map = {
      ChatConstants.uid: uid,
      ChatConstants.url: url,
      ChatConstants.messageType: MessageType.GIF,
      ChatConstants.timestamp: DateTime.timestamp().millisecondsSinceEpoch
    };
    _addReplyObject(reply, map);
    return await _messageCollection.add(map);
  }

  Future sendSticker({required String url, required ReplyType? reply}) async {
    final Map<String, dynamic> map = {
      ChatConstants.uid: uid,
      ChatConstants.url: url,
      ChatConstants.messageType: MessageType.STICKER,
      ChatConstants.timestamp: DateTime.timestamp().millisecondsSinceEpoch
    };
    _addReplyObject(reply, map);
    return await _messageCollection.add(map);
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
          break;
        case DocumentChangeType.modified:
          break;
        case DocumentChangeType.removed:
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

  Future<List<UserProfile>> getUserList(String userId) async {
    var data = await _userCollection.get();
    var list = <UserProfile>[];
    if (data.docs.isNotEmpty) {
      for (var e in data.docs) {
        if (e.get(ChatConstants.uid) != uid) {
          list.add(UserProfile.fromMap(e));
        }
      }
    }
    return list;
  }

  getImagePreference() async {
    var data = await _preferenceCollection.get();
    if (data.docs.isNotEmpty) {
      return ImagePreference.fromMap(data.docs.first);
    } else {
      await _preferenceCollection.add({
        PrefenceConstants.maxImageSizeLabel: 250000,
        PrefenceConstants.maxProfileImageSizeLabel: 500000,
      });
      return ImagePreference();
    }
  }

  getUserPreference() async {
    var collection = await _userCollection.doc(uid).get();
    final d = collection.data() as Map<String, dynamic>?;
    final AppColorPref appColorPref;
    final MessagePref msgPref;
    final String msgSoundPref;

    if (d!.containsKey(PrefenceConstants.preference)) {
      final Map<String, dynamic>? data =
          d.valueOrNull(PrefenceConstants.preference);
      msgPref = MessagePref(
        messageTextSize: data!.valueOrNull(PrefenceConstants.messageTextSize),
        messageTimeSize: data.valueOrNull(PrefenceConstants.messageTimeSize),
        dateTextSize: data.valueOrNull(PrefenceConstants.dateTextSize),
        dateBackgroundColor:
            data.valueOrNull(PrefenceConstants.dateBackgroundColor),
        dateTextColor: data.valueOrNull(PrefenceConstants.dateTextColor),
        senderBackgroundColor:
            data.valueOrNull(PrefenceConstants.senderBackgroundColor),
        receiverBackgroundColor:
            data.valueOrNull(PrefenceConstants.receiverBackgroundColor),
        senderTextColor: data.valueOrNull(PrefenceConstants.senderTextColor),
        receiverTextColor:
            data.valueOrNull(PrefenceConstants.receiverTextColor),
        senderTimeColor: data.valueOrNull(PrefenceConstants.senderTimeColor),
        receiverTimeColor:
            data.valueOrNull(PrefenceConstants.receiverTimeColor),
      );
      appColorPref = AppColorPref(
        appBarColor: data.valueOrNull(PrefenceConstants.appBarColor),
        appBackgroundColor: Pair(
            data.valueOrNull(PrefenceConstants.primaryBackgroundColor),
            data.valueOrNull(PrefenceConstants.secondaryBackgroundColor)),
      );
      msgSoundPref = data.valueOrNull(PrefenceConstants.messageSound) ??
          AssetsConstants.soundArray.first.second;
    } else {
      return null;
    }
    return AppPreferenceWrapper(
        appColorPref: appColorPref,
        msgPref: msgPref,
        messageSoundPref: msgSoundPref);
  }

  setPreference(
      MessagePref msgPref, AppColorPref appColorPref, String soundPref) async {
    final Map<String, dynamic> map = {};

    map.addAll({
      PrefenceConstants.receiverBackgroundColor:
          msgPref.receiverBackgroundColor.value,
      PrefenceConstants.receiverTimeColor: msgPref.receiverTimeColor.value,
      PrefenceConstants.senderBackgroundColor:
          msgPref.senderBackgroundColor.value,
      PrefenceConstants.senderTextColor: msgPref.senderTextColor.value,
      PrefenceConstants.senderTimeColor: msgPref.senderTimeColor.value,
      PrefenceConstants.dateBackgroundColor: msgPref.dateBackgroundColor.value,
      PrefenceConstants.dateTextColor: msgPref.dateTextColor.value,
      PrefenceConstants.messageTextSize: msgPref.messageTextSize,
      PrefenceConstants.messageTimeSize: msgPref.messageTimeSize,
      PrefenceConstants.dateTextSize: msgPref.dateTextSize,
      PrefenceConstants.appBarColor: appColorPref.appBarColor.value,
      PrefenceConstants.primaryBackgroundColor:
          appColorPref.appBackgroundColor.first.value,
      PrefenceConstants.secondaryBackgroundColor:
          appColorPref.appBackgroundColor.second.value,
      PrefenceConstants.messageSound: soundPref
    });

    if (map.isNotEmpty) {
      await _userCollection
          .doc(uid)
          .update({PrefenceConstants.preference: map});
    }
  }

  void _addReplyObject(ReplyType? reply, Map<String, dynamic> map) {
    if (reply != null) {
      map.addAll({ChatConstants.reply: ReplyType.toMap(reply)});
    }
  }

  getMessagesFrom(int timestamp) async {
    if (!loading && _lastDoc != null) {
      loading = true;
      var data = await _messageCollection
          .orderBy(ChatConstants.timestamp, descending: true)
          .startAfterDocument(_lastDoc!)
          .where(ChatConstants.timestamp, isGreaterThanOrEqualTo: timestamp)
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
}
