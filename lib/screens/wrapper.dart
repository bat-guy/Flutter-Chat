import 'package:flutter/material.dart';
import 'package:flutter_mac/models/user.dart';
import 'package:flutter_mac/screens/auth.dart';
import 'package:flutter_mac/screens/chat/chat.dart';
import 'package:flutter_mac/screens/dashboard/dashboard.dart';
import 'package:flutter_mac/services/database.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  final Stream<UserCred?>? user;

  const Wrapper({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserCred?>(context);
    if (user == null) {
      return const Authenticate();
    } else {
      return _checkUser(user);
    }
  }

  _checkUser(UserCred user) {
    // DatabaseService(uid: user.uid).createUser(user.uid);
    return ChatScreen(uid: user.uid);
  }
}
