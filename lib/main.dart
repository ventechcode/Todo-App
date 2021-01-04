import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import './models/user.dart';
import './screens/wrapper.dart';
import './services/auth_service.dart';
import 'screens/detail_screen.dart';
import './screens/notes_screen.dart';
import './screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      value: AuthService().user,
      child: MaterialApp(
        title: 'Todo-App',
        theme: ThemeData(
          canvasColor: Colors.transparent,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (_) => Wrapper(),
          '/settings': (_) => SettingsScreen(),
          '/details': (_) => DetailScreen(),
        },
        onGenerateRoute: (settings) {
          var routes = {
            '/notes': (_) => NotesScreen(settings.arguments),
          };
          WidgetBuilder builder = routes[settings.name];
          return MaterialPageRoute(builder: (ctx) => builder(ctx));
        },
      ),
    );
  }
}