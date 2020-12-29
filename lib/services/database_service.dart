import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/todo.dart';

class DatabaseService {
  final String uid;
  final String list;
  DatabaseService(this.uid, {this.list});

  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  Future addTodo(Todo todo) async {
    return await users.doc(uid).collection(list).doc(todo.id).set({
      'id': todo.id,
      'title': todo.title,
      'value': todo.value,
      'createdAt': Timestamp.now(),
      'priority': todo.priority,
      'dueDate': todo.dueDate,
      'reminderDate': todo.reminderDate,
      'deviceToken': await _firebaseMessaging.getToken(),
      'notes': null,
      'gotFiles': false,
      'tags': {
        '1': {'name': 'Priorität', 'active': false, 'color': '0xFFFFD740'},
        '2': {'name': 'Wichtig', 'active': false, 'color': '0xffff4081'},
        '3': {
          'name': 'Mittlere Priorität',
          'active': false,
          'color': '0xffe0e0e0'
        },
        '4': {'name': 'Nicht kritisch', 'active': false, 'color': '0xff9575cd'},
        '5': {'name': 'In Bearbeitung', 'active': false, 'color': '0xffff6e40'},
        '6': {'name': 'Familie', 'active': false, 'color': '0xffb2ff59'},
        '7': {'name': 'Arbeit', 'active': false, 'color': '0xff40c4ff'}
      }
    });
  }

  Future deleteTodo(String id) async {
    deleteTodoFiles(id).whenComplete(() async {
      return await users.doc(uid).collection(list).doc(id).delete();
    });
  }

  Future deleteTodoFiles(String id) async {
    QuerySnapshot snapshot =
        await users.doc(uid).collection(list).doc(id).collection('files').get();
    snapshot.docs.forEach((file) async {
      await FirebaseStorage.instance
          .ref()
          .child('users/$uid/$id/${file.id}')
          .delete();
      await file.reference.delete();
    });
  }

  Future toggleDone(String id, bool value) async {
    return await users.doc(uid).collection(list).doc(id).update({
      'value': !value,
    });
  }

  Future togglePriority(String id, bool priority) async {
    return await users.doc(uid).collection(list).doc(id).update({
      'priority': priority,
    });
  }

  Future updateDueDate(String id, DateTime dueDate) async {
    return await users.doc(uid).collection(list).doc(id).update({
      'dueDate': dueDate,
    });
  }

  Future updateReminderDate(String id, DateTime reminderDate) async {
    return await users.doc(uid).collection(list).doc(id).update({
      'reminderDate': reminderDate,
    });
  }

  Future updateNotes(String id, String notes) async {
    return await users.doc(uid).collection(list).doc(id).update({
      'notes': notes.trim(),
    });
  }

  Stream<QuerySnapshot> getTodos({String orderBy}) {
    return users.doc(uid).collection(list).orderBy(orderBy).snapshots();
  }

  Future addUser(
      String username, String email, String photoUrl, String authMethod) async {
    return await users.doc(uid).set({
      'username': username,
      'email': email,
      'createdAt': Timestamp.now(),
      'photoUrl': photoUrl != null ? photoUrl : '',
      'authMethod': authMethod,
    });
  }

  Future<DocumentSnapshot> getUserData() async {
    return await users.doc(uid).get();
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

  Stream<DocumentSnapshot> todoStream(String id) {
    return users.doc(uid).collection(list).doc(id).snapshots();
  }

  Future updateTodoTitle(String id, String title) async {
    return await users.doc(uid).collection(list).doc(id).update({
      'title': title,
    });
  }

  Future updateUsername(String username) async {
    return await users.doc(uid).update({
      'username': username,
    });
  }

  Future updateEmail(String newEmail) async {
    return await users.doc(uid).update({
      'email': newEmail,
    });
  }

  Future updatePhotoUrl(String url) async {
    return await users.doc(uid).update({
      'photoUrl': url,
    });
  }

  Future addFile(String fileName, String url, String todoId, int bytes) async {
    return await users
        .doc(uid)
        .collection(list)
        .doc(todoId)
        .collection('files')
        .doc(fileName)
        .set({
      'url': url,
      'bytes': bytes,
      'type': fileName.split(".")[1],
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

  Future storeFile(File file, String todoId) async {
    String fileName = path.basename(file.path);
    int bytes = file.lengthSync();
    final Reference reference = FirebaseStorage.instance
        .ref()
        .child('users')
        .child('$uid/$todoId')
        .child('$fileName');

    try {
      await reference.putFile(file);
      print('File stored.');
    } on FirebaseException catch (e) {
      print(e.stackTrace);
      print(e.message);
    }

    await reference.getDownloadURL().then((url) async {
      await addFile(fileName, url, todoId, bytes);
    });
  }

  Future deleteFile(String fileName, String todoId) async {
    await FirebaseStorage.instance
        .ref()
        .child('users')
        .child('$uid/$todoId')
        .child('$fileName')
        .delete();
    await users
        .doc(uid)
        .collection(list)
        .doc(todoId)
        .collection('files')
        .doc(fileName)
        .delete();
  }

  Future<List<File>> getFiles(String todoId) async {
    List<File> files = [];
    final Directory systemTempDir = Directory.systemTemp;
    final Reference reference =
        FirebaseStorage.instance.ref().child('users').child('$uid/$todoId');
    final snapshot = await users
        .doc(uid)
        .collection(list)
        .doc(todoId)
        .collection('files')
        .get();
    snapshot.docs.forEach((file) {
      File tempFile = File('${systemTempDir.path}/tmp${file.id}');
      if (tempFile.existsSync()) {
        tempFile.delete();
      }
      tempFile.create();
      reference.child('${file.id}').writeToFile(tempFile);
      files.add(tempFile);
    });
    return files;
  }

  Stream files(String todoId) {
    return users
        .doc(uid)
        .collection(list)
        .doc(todoId)
        .collection('files')
        .snapshots();
  }

  Future updateGotFiles(String todoId, bool val) async {
    return users.doc(uid).collection(list).doc(todoId).update({
      'gotFiles': val,
    });
  }

  Stream subtasks(String todoId) {
    return users
        .doc(uid)
        .collection(list)
        .doc(todoId)
        .collection('subtasks')
        .snapshots();
  }

  Future<Map> getTags(String todoId) async {
    DocumentSnapshot todo =
        await users.doc(uid).collection(list).doc(todoId).get();
    return todo.data()['tags'];
  }

  Future<void> updateTags(String todoId, Map tags) async {
    return await users.doc(uid).collection(list).doc(todoId).update({
      'tags': tags,
    });
  }
}
