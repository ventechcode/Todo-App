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
  bool gotFiles = false;
  int _index;

  Todo(this._title, this._list, this._index)
      : this._id = Uuid().v4(),
        this._createdAt = DateTime.now(),
        this._value = false,
        this._priority = false,
        this._notes = '',
        this._deviceToken = '',
        this._tags = [
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
    snapshot
        .data()['tags']
        .forEach((tag) => {this._tags.add(Tag.fromDocument(tag))});
    this.gotFiles = snapshot.data()['gotFiles'];
    this._index = snapshot.data()['index'];
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
      'gotFiles': gotFiles,
      'index': index,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'list': list,
      'title': title,
      'createdAt': Timestamp.fromDate(createdAt),
      'priority': priority,
      'dueDate': dueDate,
      'reminderDate': reminderDate,
      'value': value,
      'notes': notes,
      'tags': _tags.map((tag) => tag.toDocument()).toList(),
      'gotFiles': gotFiles,
      'index': index,
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
  bool get hasDueDate => _dueDate != null;
  bool get hasReminderDate => _reminderDate != null;
  bool get hasNotes => _notes != null && _notes != '';
  bool get hasFiles => _files.isNotEmpty;
  String get list => _list;
  List<Tag> get tags => _tags;
  List<Tag> get activeTags => _tags.where((tag) => tag.active == true).toList();
  List<File> get files => _files;
  int get index => _index;

  dynamic get(String property) {
    if(this.toMap().containsKey(property)) {
      if(property == 'value') return value ? 1 : 0;
      return this.toMap()[property];
    }
    throw ArgumentError('Property $property not found!');
  }

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
