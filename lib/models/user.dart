import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:todoapp/services/database_service.dart';

class User {
  final String uid;
  final String email;
  String userName;

  User({
    @required this.uid,
    @required this.email,
    this.userName,
  });

  String get userID {
    return uid;
  }

  Future<String> getPhotoUrl() async {
    DocumentSnapshot snapshot = await DatabaseService(uid).getUserData();
    if (snapshot.data()['photoUrl'] == '' ||
        snapshot.data()['photoUrl'] == null) {
      return null;
    } else {
      return snapshot.data()['photoUrl'];
    }
  }

  set username(String username) {
    userName = username;
  }

  String get username {
    return userName;
  }
}
