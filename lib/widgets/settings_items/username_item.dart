import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todoapp/services/database_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class UsernameItem extends StatefulWidget {
  final String? uid;

  UsernameItem(this.uid);

  @override
  _UsernameItemState createState() => _UsernameItemState();
}

class _UsernameItemState extends State<UsernameItem> {
  FocusNode focus = FocusNode();
  String? username;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    DocumentSnapshot userData = await DatabaseService(widget.uid).getUserData();
    if (userData.data() != null) {
      username = (userData.data() as Map)['username'];
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
        ? Container(
            // Loading Widget!
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
                        Icons.account_circle,
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
                        Icons.account_circle,
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
                          text: username!,
                          selection:
                              TextSelection.collapsed(offset: username!.length),
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
                            username = value;
                          });
                        },
                        onEditingComplete: () {
                          DatabaseService(widget.uid).updateUsername(username);
                          focus.unfocus();
                        },
                        onSubmitted: (value) {
                          DatabaseService(widget.uid).updateUsername(username);
                          focus.unfocus();
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
