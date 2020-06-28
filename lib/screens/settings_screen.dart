import 'package:flutter/material.dart';
import 'package:todoapp/widgets/scroll_behavior.dart';
import 'package:todoapp/widgets/settings_items/delete_account_item.dart';
import 'package:todoapp/widgets/settings_items/email_item.dart';
import 'package:todoapp/widgets/settings_items/logout_item.dart';
import 'package:todoapp/widgets/settings_items/password_item.dart';
import 'package:todoapp/widgets/settings_items/username_item.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map userData = ModalRoute.of(context).settings.arguments;
    var screenHeight = MediaQuery.of(context).size.height - kToolbarHeight;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Einstellungen'.toUpperCase(),
            style: TextStyle(
              color: Colors.black,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          iconTheme: IconThemeData(color: Colors.black),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        backgroundColor: Colors.white,
        body: Container(
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.fromLTRB(30, 20, 0, 12),
                child: Text(
                  'Konto'.toUpperCase(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                height: screenHeight * 0.5,
                child: ScrollConfiguration(
                  behavior: CustomScrollBehavior(),
                  child: ListView(
                    children: [
                      UsernameItem(userData['uid']),
                      if(userData['isSocial'] == false)
                        EmailItem(userData['uid']),
                      PasswordItem(userData['email']),
                      LogoutItem(userData['uid']),
                      DeleteAccountItem(userData['authMethod']),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
