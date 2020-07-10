import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:todoapp/models/todo.dart';

class DatabaseService {
  final String uid;
  final String list;
  DatabaseService(this.uid, {this.list});

  final CollectionReference users = Firestore.instance.collection('users');
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  Future addTodo(Todo todo) async {
    return await users.document(uid).collection(list).document(todo.id).setData({
      'id': todo.id,
      'title': todo.title,
      'value': todo.value,
      'createdAt': Timestamp.now(),
      'priority': todo.priority,
      'dueDate': todo.dueDate,
      'reminderDate': todo.reminderDate,
      'deviceToken': await _firebaseMessaging.getToken(),
    });
  }

  Future deleteTodo(String id) async {
    return await users.document(uid).collection(list).document(id).delete();
  }

  Future toggleDone(String id, bool value) async {
    return await users.document(uid).collection(list).document(id).updateData({
      'value': !value,
    });
  }

  Future togglePriority(String id, bool priority) async {
    return await users.document(uid).collection(list).document(id).updateData({
      'priority': priority,
    });
  }

  Future updateDueDate(String id, DateTime dueDate) async {
    return await users.document(uid).collection(list).document(id).updateData({
      'dueDate': dueDate,
    });
  }

  Future updateReminderDate(String id, DateTime reminderDate) async {
    return await users.document(uid).collection(list).document(id).updateData({
      'reminderDate': reminderDate,
    });
  }

  Stream<QuerySnapshot> getTodos({String orderBy}) {
    return users.document(uid).collection(list).orderBy(orderBy).snapshots();
  }

  Future createUserDocument(String username) async {
    return await users.document(uid).collection('Alle Aufgaben').document().setData(
        {
          'todos': [{
            'id': '1337',
            'title': 'Willkommen ' + username,
            'value': false,
          }]
        }
    );
  }

  Future addUser(String username, String email, String photoUrl, String authMethod) async {
    return await users.document(uid).setData({
      'username': username,
      'email': email,
      'createdAt': Timestamp.now(),
      'photoUrl': photoUrl != null ? photoUrl : '',
      'authMethod': authMethod,
    });
  }

  Future<DocumentSnapshot> getUserData() async {
    return await users.document(uid).get();
  }

  Future isUserExisting() async {
    if((await users.document(uid).get()).exists) {
      return true;
    } else {
      return false;
    }
  }

  Stream<DocumentSnapshot> get userDataStream {
    return users.document(uid).snapshots();
  }

  Stream<DocumentSnapshot> todoStream(String id) {
    return users.document(uid).collection(list).document(id).snapshots();
  }

  Future updateTodoTitle(String id, String title) async {
    return await users.document(uid).collection(list).document(id).updateData({
      'title': title,
    });
  }

  // User Methods
  Future updateUsername(String username) async {
    return await users.document(uid).updateData({
      'username': username,
    });
  }

  Future updateEmail(String newEmail) async {
    return await users.document(uid).updateData({
      'email': newEmail,
    });
  }

  Future updatePhotoUrl(String url) async {
    return await users.document(uid).updateData({
      'photoUrl': url,
    });
  }

  Future storeImage(File image) async {
    final StorageReference reference = FirebaseStorage.instance.ref().child('user_images').child(uid + '.jpg');
    await reference.putFile(image).onComplete;
    final String url = await reference.getDownloadURL();
    await updatePhotoUrl(url);
  }
}