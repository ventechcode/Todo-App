import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todoapp/services/auth_service.dart';
import 'package:todoapp/services/database_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class EmailItem extends StatefulWidget {
  final String uid;

  EmailItem(this.uid);

  @override
  _EmailItemState createState() => _EmailItemState();
}

class _EmailItemState extends State<EmailItem> {
  final AuthService _authService = AuthService();
  FocusNode focus = FocusNode();
  String email;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    DocumentSnapshot userData = await DatabaseService(widget.uid).getUserData();
    if (userData.data != null) {
      email = userData.data['email'];
      setState(() {
        loading = false;
      });
    } else {
      initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Container( // Loading Widget!
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
                        Icons.mail,
                      ),
                      margin: const EdgeInsets.only(left: 10.0),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 1),
                      width: 255,
                      child: Container(
                        child: SpinKitThreeBounce(
                          color: Colors.black,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : Container(
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
                        Icons.mail,
                      ),
                      margin: const EdgeInsets.only(left: 10.0),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 1),
                      width: 255,
                      child: TextField(
                        controller:
                            TextEditingController.fromValue(TextEditingValue(
                          text: email,
                          selection:
                              TextSelection.collapsed(offset: email.length),
                        )),
                        focusNode: focus,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          suffixIcon: Icon(
                            Icons.edit,
                            size: 22,
                            color: Colors.black,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            email = value;
                          });
                        },
                        onSubmitted: (value) async {
                          await _authService.changeEmail(FirebaseAuth.instance.currentUser(), email);
                          await DatabaseService(widget.uid).updateEmail(email);
                          focus.unfocus();
                          print(email);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}