import 'package:flutter/material.dart';

/*
  Add this ScrollBehavior as a property to a ListView to remove the over scroll visuals
 */
class CustomScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
