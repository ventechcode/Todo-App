import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:todoapp/models/todo_list.dart';

import '../models/user.dart';
import '../models/todo.dart';

/// This class handles backend operations for Todo-Items.
class TodoService {
  final User? user;
  final TodoList? list;
  late CollectionReference _todos;

  TodoService({this.user, this.list}) {
    String collectionPath = 'users/${user!.uid}/lists/${list!.id}/todos';
    _todos = FirebaseFirestore.instance.collection(collectionPath);
  }

  // Inserts the todo into the database in JSON format.
  Future<void> addTodo(Todo todo) async =>
      await _todos.doc(todo.id).set(await todo.toDocument());

  // Deletes the todo from the database.
  Future<void> deleteTodo(Todo todo) async {
    await deleteTodoFiles(todo)
        .whenComplete(() async => await _todos.doc(todo.id).delete());
  }

  // Updates the todo in the database.
  Future<void> updateTodo(Todo? todo) async {
    if((await _todos.doc(todo!.id).get()).exists) {
      await _todos.doc(todo.id).update(await todo.toDocument());
    } else {
      todo = null;
    }
  }  

  // Returns a stream of the todo query.
  Stream<QuerySnapshot> getTodos({String? orderBy}) =>
      _todos.orderBy('index').snapshots();

  // Returns a stream of the todo document.
  Stream<DocumentSnapshot> stream(Todo todo) => _todos.doc(todo.id).snapshots();

  // Adds the file metadata into the database.
  Future<void> addFile(
      Todo todo, String fileName, String url, int bytes) async {
    return await _todos.doc(todo.id).collection('files').doc(fileName).set({
      'url': url,
      'bytes': bytes,
      'type': fileName.split(".")[1],
    });
  }

  // Stores the file in Firebase Storage.
  Future<void> storeFile(Todo todo, File file) async {
    String fileName = path.basename(file.path);
    int bytes = file.lengthSync();

    final Reference reference = FirebaseStorage.instance
        .ref()
        .child('users')
        .child('${user!.uid}/${todo.id}')
        .child('$fileName');

    try {
      await reference.putFile(file);
    } on FirebaseException catch (e) {
      print(e.stackTrace);
    }

    await reference.getDownloadURL().then((url) async {
      await addFile(todo, fileName, url, bytes);
    });
  }

  // Downloads the files from Firebase Storage.
  Future<List<File>> getFiles(Todo todo) async {
    List<File> files = [];
    final Directory systemTempDir = Directory.systemTemp;
    final Reference reference = FirebaseStorage.instance
        .ref()
        .child('users')
        .child('${user!.uid}/${todo.id}');

    final snapshot = await _todos.doc(todo.id).collection('files').get();

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

  // Returns a stream of the files query.
  Stream<QuerySnapshot> files(Todo todo) =>
      _todos.doc(todo.id).collection('files').snapshots();

  // Deletes a single file asociated with the Todo from Firebase Storage and Firestore.
  Future<void> deleteFile(Todo todo, String fileName) async {
    await FirebaseStorage.instance
        .ref()
        .child('users')
        .child('${user!.uid}/${todo.id}')
        .child('$fileName')
        .delete();
    await _todos.doc(todo.id).collection('files').doc(fileName).delete();
  }

  // Deletes all files asociated with the Todo from Firebase Storage and Firestore.
  Future deleteTodoFiles(Todo todo) async {
    QuerySnapshot snapshot = await _todos.doc(todo.id).collection('files').get();
    snapshot.docs.forEach((file) async {
      await FirebaseStorage.instance
          .ref()
          .child('users/${user!.uid}/${todo.id}/${file.id}')
          .delete();
      await file.reference.delete();
    });
  }
}
