import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:todoapp/models/todo_list.dart';

class DatabaseService {
  final String? uid;
  DatabaseService(this.uid);

  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  Future addUser(String? username, String? email, String? photoUrl,
      String authMethod) async {
    await users.doc(uid).set({
      'username': username,
      'email': email,
      'createdAt': Timestamp.now(),
      'photoUrl': photoUrl != null ? photoUrl : '',
      'authMethod': authMethod,
    });

    List<TodoList> staticLists = [
      TodoList.static('Alle Aufgaben'),
      TodoList.static('Wichtig'),
      TodoList.static('Geplant'),
      TodoList.static('Heute')
    ];

    for (TodoList list in staticLists) {
      await users.doc(uid).collection('lists').doc(list.id).set(list.toMap());
    }
  }

  Future<DocumentSnapshot> getUserData() async {
    return await users.doc(uid).get();
  }

  Stream<QuerySnapshot> getUserLists() {
    return users.doc(uid).collection('lists').snapshots();
  }

  Future isUserExisting() async {
    if ((await users.doc(uid).get()).exists) {
      return true;
    } else {
      return false;
    }
  }

  Stream<DocumentSnapshot> get userDataStream {
    return users.doc(uid).snapshots();
  }

  Future updateUsername(String? username) async {
    return await users.doc(uid).update({
      'username': username,
    });
  }

  Future updateEmail(String? newEmail) async {
    return await users.doc(uid).update({
      'email': newEmail,
    });
  }

  Future updatePhotoUrl(String url) async {
    return await users.doc(uid).update({
      'photoUrl': url,
    });
  }

  Future storeImage(File image) async {
    final Reference reference =
        FirebaseStorage.instance.ref().child('users').child('$uid');
    await reference.putFile(image).whenComplete(() async {
      final String url = await reference.getDownloadURL();
      await updatePhotoUrl(url);
    });
  }
}