import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_mac/common/logger.dart';
import 'package:flutter_mac/models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserCred? _userFromFireBase(User? user) {
    return user != null ? UserCred(uid: user.uid) : null;
  }

  Stream<UserCred?> get user {
    return _auth.userChanges().map(_userFromFireBase);
  }

  Future signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
      return user;
    } catch (e) {
      Logger.print('FIrebase Auth Exception - $e');
      return null;
    }
  }

  Future logInWithEmailPass(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      return _userFromFireBase(user);
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
      // analytics.logEvent(
      //   name: 'firebase_auth_error',
      //   parameters: <String, dynamic>{'error': e.toString(), 'error_1': s},
      // );
      Logger.print('Firebase Auth Exception - ${s.toString()}');
      return null;
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      Logger.print(e.toString());
      return null;
    }
  }
}
