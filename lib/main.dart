import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todoapp/screens/settings_screen.dart';

import './models/user.dart';
import './screens/wrapper.dart';
import './services/auth_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      value: AuthService().user,
      child: MaterialApp(
        title: 'Todo-App',
        theme: ThemeData.light(),
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (_) => Wrapper(),
          '/settings': (_) => SettingsScreen(),
        },
      ),
    );
  }
}