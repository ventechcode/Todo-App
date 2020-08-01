import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../models/todo.dart';

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
      'notes': null,
    });
  }

  Future deleteTodo(String id) async {
    deleteTodoFiles(id).whenComplete(() async {
      return await users.document(uid).collection(list).document(id).delete();
    });
  }

  Future deleteTodoFiles(String id) async {
    QuerySnapshot snapshot = await users.document(uid).collection(list).document(id).collection('files').getDocuments();
    snapshot.documents.forEach((file) async {
      await FirebaseStorage.instance.ref().child('users/$uid/$id/${file.documentID}').delete();
      await file.reference.delete();
    });
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

  Future updateNotes(String id, String notes) async {
    return await users.document(uid).collection(list).document(id).updateData({
      'notes': notes.trim(),
    });
  }

  Stream<QuerySnapshot> getTodos({String orderBy}) {
    return users.document(uid).collection(list).orderBy(orderBy).snapshots();
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

  Future addFile(String fileName, String url, String todoId, int bytes) async {
    return await users.document(uid).collection(list).document(todoId).collection('files').document(fileName).setData({
      'url': url,
      'bytes': bytes,
      'type': fileName.split(".")[1],
    });
  }

  Future storeImage(File image) async {
    final StorageReference reference = FirebaseStorage.instance.ref().child('users').child('$uid');
    await reference.putFile(image).onComplete;
    final String url = await reference.getDownloadURL();
    await updatePhotoUrl(url);
  }

  Future storeFile(File file, String todoId) async {
    String fileName = path.basename(file.path);
    int bytes = file.lengthSync();
    final StorageReference reference = FirebaseStorage.instance.ref().child('users').child('$uid/$todoId').child('$fileName');
    await reference.putFile(file).onComplete;
    final String url = await reference.getDownloadURL();
    await addFile(fileName, url, todoId, bytes);
  }

  Future deleteFile(String fileName, String todoId) async {
    return await FirebaseStorage.instance.ref().child('users').child('$uid/$todoId').child('$fileName').delete();
  }

  Future<List<File>> getFiles(String todoId) async {
    List<File> files = [];
    final Directory systemTempDir = Directory.systemTemp;
    final StorageReference reference = FirebaseStorage.instance.ref().child('users').child('$uid/$todoId');
    final snapshot = await users.document(uid).collection(list).document(todoId).collection('files').getDocuments();
    snapshot.documents.forEach((file) {
      File tempFile = File('${systemTempDir.path}/tmp${file.documentID}');
      if(tempFile.existsSync()) {
        tempFile.delete();
      }
      tempFile.create();
      reference.child('${file.documentID}').writeToFile(tempFile);
      files.add(tempFile);
    });
    return files;
  }

  Stream files(String todoId) {
    return users.document(uid).collection(list).document(todoId).collection('files').snapshots();
  }
}