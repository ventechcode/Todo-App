import 'package:flutter/material.dart';

import '../screens/login_screen.dart';
import '../screens/register_screen.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool showSignIn = false;

  void toggleView() => setState(() => showSignIn = !showSignIn);

  @override
  Widget build(BuildContext context) {
    if (showSignIn) {
      return LoginScreen(
        toggleView: toggleView,
      );
    } else {
      return RegisterScreen(
        toggleView: toggleView,
      );
    }
  }
}