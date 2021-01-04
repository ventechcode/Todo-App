import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:todoapp/models/tag.dart';
import 'package:uuid/uuid.dart';

class Todo {
  final String _id;
  final DateTime _createdAt;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final String _deviceToken;
  final String _list;
  String _title;
  DateTime _dueDate;
  DateTime _reminderDate;
  bool _value;
  bool _priority;
  String _notes;
  List<Tag> _tags = [];
  List<File> _files = [];

  Todo(this._title, this._list)
      : this._id = Uuid().v4(),
        this._createdAt = DateTime.now(),
        this._value = false,
        this._priority = false,
        this._notes = '',
        this._deviceToken = '',
        this._tags = [
          Tag('Priority', '0xffffd740', false),
          Tag('Wichtig', '0xffff4081', false),
          Tag('Mittlere Priorität', '0xffe0e0e0', false),
          Tag('Nicht kritisch', '0xff9575cd', false),
          Tag('In Bearbeitung', '0xffff6e40', false),
          Tag('Familie', '0xffb2ff59', false),
          Tag('Arbeit', '0xff40c4ff', false),
        ];

  Todo.fromDocument(DocumentSnapshot snapshot)
      : this._id = snapshot.data()['id'],
        this._deviceToken = snapshot.data()['deviceToken'],
        this._createdAt = snapshot.data()['createdAt'] != null
            ? snapshot.data()['createdAt'].toDate()
            : null,
        this._list = snapshot.data()['list'] {
    this._title = snapshot.data()['title'];
    this._dueDate = snapshot.data()['dueDate'] != null
        ? snapshot.data()['dueDate'].toDate()
        : null;
    this._reminderDate = snapshot.data()['reminderDate'] != null
        ? snapshot.data()['reminderDate'].toDate()
        : null;
    this._value = snapshot.data()['value'];
    this._priority = snapshot.data()['priority'];
    this._notes = snapshot.data()['notes'];
    snapshot.data()['tags'].forEach((tag) =>
        {this._tags.add(Tag.fromDocument(tag))});
  }

  Future<Map<String, dynamic>> toDocument() async {
    return {
      'id': id,
      'list': list,
      'title': title,
      'createdAt': Timestamp.fromDate(createdAt),
      'priority': priority,
      'dueDate': dueDate,
      'reminderDate': reminderDate,
      'value': value,
      'deviceToken': await _firebaseMessaging.getToken(),
      'notes': notes,
      'tags': _tags.map((tag) => tag.toDocument()).toList(),
    };
  }

  String get id => _id;
  String get title => _title;
  DateTime get dueDate => _dueDate;
  DateTime get reminderDate => _reminderDate;
  DateTime get createdAt => _createdAt;
  bool get value => _value;
  bool get priority => _priority;
  String get notes => _notes;
  String get deviceToken => _deviceToken;
  bool get hasFiles => _files.isEmpty ? false : true;
  String get list => _list;
  List<Tag> get tags => _tags;
  List<File> get files => _files;

  set title(String value) {
    if (value.isNotEmpty) {
      _title = value;
    }
  }

  set files(List<File> value) => _files = value;

  set dueDate(DateTime value) => _dueDate = value;

  set reminderDate(DateTime value) => _reminderDate = value;

  set value(bool value) => _value = value;

  set priority(bool value) => _priority = value;

  set notes(String value) => _notes = value;
}
