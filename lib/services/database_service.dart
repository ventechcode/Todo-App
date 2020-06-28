import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DatabaseService {
  final String userID;

  DatabaseService(this.userID);

  final CollectionReference userTodos = Firestore.instance.collection('todos');
  final CollectionReference users = Firestore.instance.collection('users');

  Future updateTodos(List<dynamic> todos) async {
    return await userTodos.document(userID).collection('lists')
        .document('all_tasks')
        .setData(
      {
        'todos': FieldValue.arrayUnion(todos),
      }
    );
  }

  Future<DocumentSnapshot> getTodos(String list) async {
    return await userTodos.document(userID).collection('lists').document(list).get();
  }

  Future createUserDocument(String username) async {
    return await userTodos.document(userID).collection('lists').document('all_tasks').setData(
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
    return await users.document(userID).setData({
      'username': username,
      'email': email,
      'createdAt': Timestamp.now(),
      'photoUrl': photoUrl != null ? photoUrl : '',
      'authMethod': authMethod,
    });
  }

  Future<DocumentSnapshot> getUserData() async {
    return await users.document(userID).get();
  }

  Future isUserExisting() async {
    if((await userTodos.document(userID).get()).exists) {
      return true;
    } else {
      return false;
    }
  }

  Stream<DocumentSnapshot> get userDataStream {
    return users.document(userID).snapshots();
  }

  Future updateUsername(String username) async {
    return await users.document(userID).updateData({
      'username': username,
    });
  }

  Future updateEmail(String newEmail) async {
    return await users.document(userID).updateData({
      'email': newEmail,
    });
  }

  Future updatePhotoUrl(String url) async {
    return await users.document(userID).updateData({
      'photoUrl': url,
    });
  }

  Future storeImage(File image) async {
    final StorageReference reference = FirebaseStorage.instance.ref().child('user_images').child(userID + '.jpg');
    await reference.putFile(image).onComplete;
    final String url = await reference.getDownloadURL();
    await updatePhotoUrl(url);
  }
}