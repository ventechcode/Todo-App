import 'package:flutter/material.dart';

import '../../widgets/sidebar/profile_section.dart';
import '../../models/user.dart';

class Sidebar extends StatelessWidget {
  final User user;
  Sidebar(this.user);

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    return Drawer(
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            height: screenHeight * 0.13,
            color: Colors.grey[100],
            child: ProfileSection(user),
          ),
          Container(
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
