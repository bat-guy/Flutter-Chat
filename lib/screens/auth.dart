import 'package:flutter/material.dart';
import 'package:flutter_mac/screens/sign_in.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({super.key});

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool showSignIn = true;

  void toggleView() {
    setState(() => showSignIn = !showSignIn);
  }

  @override
  Widget build(BuildContext context) {
    return SignIn(toggleView: toggleView);
    // return showSignIn ? SignIn(toggleView: toggleView) : RegisterState(toggleView: toggleView);
  }
}
