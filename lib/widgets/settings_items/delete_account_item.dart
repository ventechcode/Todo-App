import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todoapp/services/auth_service.dart';

class DeleteAccountItem extends StatefulWidget {
  final String authMethod;

  DeleteAccountItem(this.authMethod);

  @override
  _DeleteAccountItemState createState() => _DeleteAccountItemState();
}

class _DeleteAccountItemState extends State<DeleteAccountItem> {
  final AuthService _authService = AuthService();
  String password = '';

  // Creates the logout confirmation Popup
  createLogoutDialog(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Wirklich Löschen?'),
            content: Container(
              height: widget.authMethod == 'email' ? 100 : 55,
              child: widget.authMethod == 'email' ? Column(
                children: [
                  Text('Geben Sie ihr Passwort als Bestätigung ein.', style: TextStyle(fontSize: 12),),
                  TextField(
                    obscureText: true,
                    onSubmitted: (value) {
                      setState(() {
                        password = value;
                      });
                    },
                  ),
                ],
              ) : Text('Ihr Konto wird unwiderruflich gelöscht.', style: TextStyle(fontSize: 12),),
            ),
            contentTextStyle: TextStyle(
              color: Colors.black54,
              fontSize: 13,
            ),
            actions: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, screenWidth * 0.037, 0),
                child: FlatButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    await _authService.deleteAccount(FirebaseAuth.instance.currentUser(), password, widget.authMethod);
                  },
                  child: Text(
                    'Konto löschen',
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
                  Icons.delete_forever,
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
                    'Konto löschen',
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
