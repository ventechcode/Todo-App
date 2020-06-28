import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todoapp/services/auth_service.dart';
import 'package:todoapp/services/database_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LogoutItem extends StatefulWidget {
  final String uid;

  LogoutItem(this.uid);

  @override
  _LogoutItemState createState() => _LogoutItemState();
}

class _LogoutItemState extends State<LogoutItem> {
  final AuthService _authService = AuthService();

  // Creates the logout confirmation Popup
  createLogoutDialog(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Wirklich Abmelden?'),
            content: Text('Sie werden zum Login weitergeleitet.'),
            contentTextStyle: TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
            actions: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, screenWidth * 0.037, 0),
                child: FlatButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    await _authService.signOut();
                  },
                  child: Text(
                    'Abmelden',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.fromLTRB(26, 0, 20, 5),
      child: Card(
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Icon(
                  Icons.exit_to_app,
                  color: Colors.red,
                ),
                margin: const EdgeInsets.only(left: 10.0),
              ),
              SizedBox(
                width: 16,
              ),
              GestureDetector(
                onTap: () {
                  createLogoutDialog(context);
                },
                child: Container(
                  margin: EdgeInsets.only(top: 1),
                  width: 255,
                  child: Text(
                    'Abmelden',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.red,
                    ),
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
