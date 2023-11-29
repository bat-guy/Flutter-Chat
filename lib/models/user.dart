import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_mac/common/constants.dart';
import 'package:flutter_mac/extensions.dart';

class UserCred {
  final String uid;
  bool online = false;
  UserCred({required this.uid});
}

class UserProfile {
  final String uid;
  final String name;
  final String profilePicture;
  final String quote;

  UserProfile(
      {required this.uid,
      required this.name,
      required this.profilePicture,
      required this.quote});

  static UserProfile fromMap(DocumentSnapshot<Object?> e) {
    Map<String, dynamic>? map = e.data() as Map<String, dynamic>?;
    return UserProfile(
        uid: map![ChatConstants.uid],
        name: map.valueOrNull(ChatConstants.name) ?? 'John Doe',
        profilePicture: map.valueOrNull(ChatConstants.profilePicture) ?? '',
        quote: map.valueOrNull(ChatConstants.quote) ?? 'Some Quote Here');
  }
}
