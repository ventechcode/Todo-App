import 'package:flutter/material.dart';
import 'package:todoapp/services/auth_service.dart';

class PasswordItem extends StatefulWidget {
  final String? email;

  PasswordItem(this.email);

  @override
  _PasswordItemState createState() => _PasswordItemState();
}

class _PasswordItemState extends State<PasswordItem> {
  final AuthService _authService = AuthService();
  FocusNode focus = FocusNode();
  String? password;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.fromLTRB(26, 0, 20, 5),
      child: Card(
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                child: Icon(
                  Icons.lock,
                ),
                margin: const EdgeInsets.only(left: 10.0),
              ),
              SizedBox(
                width: 16,
              ),
              GestureDetector(
                onTap: () async {
                  bool result = await _authService.sendPasswordReset(widget.email!);
                  if(result)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: Duration(milliseconds: 3610),
                      content: Container(
                        height: 44,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_box,
                              size: 24,
                              color: Colors.green,
                            ),
                            SizedBox(width: 8,),
                            Text(
                              'Wiederherstellungs-Link wurde gesendet',
                              style: TextStyle(
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.fromLTRB(2, 1, 0, 0),
                  width: 240,
                  child: Text(
                    'Passwort zurücksetzen',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
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
