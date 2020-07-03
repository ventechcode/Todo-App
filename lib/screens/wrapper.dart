import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../screens/authenticate.dart';
import '../screens/task_screen.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    if(user == null) {
      return Authenticate();
    } else {
      return TaskScreen(user, 'Alle Aufgaben');
    }
  }
}
