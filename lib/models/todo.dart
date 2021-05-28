import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:todoapp/models/tag.dart';
import 'package:uuid/uuid.dart';

class Todo {
  final String _id;
  final DateTime _createdAt;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final String _deviceToken;
  final String _list;
  String _title;
  DateTime? dueDate;
  DateTime? reminderDate;
  bool value;
  bool priority;
  String? notes;
  List<Tag> _tags = [];
  List<File> files = [];
  bool gotFiles = false;
  int index;

  Todo(this._title, this._list, this.index)
      : this._id = Uuid().v4(),
        this._createdAt = DateTime.now(),
        this.value = false,
        this.priority = false,
        this.notes = '',
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
      : this._id = (snapshot.data() as Map)['id'],
        this._deviceToken = (snapshot.data() as Map)['deviceToken'],
        this._createdAt = (snapshot.data() as Map)['createdAt'] != null
            ? (snapshot.data() as Map)['createdAt'].toDate()
            : null,
        this._list = (snapshot.data() as Map)['list'],
        this.value = (snapshot.data() as Map)['value'],
        this._title = (snapshot.data() as Map)['title'],
        this.priority = (snapshot.data() as Map)['priority'],
        this.index = (snapshot.data() as Map)['index'] {
    this.dueDate = (snapshot.data() as Map)['dueDate'] != null
        ? (snapshot.data() as Map)['dueDate'].toDate()
        : null;
    this.reminderDate = (snapshot.data() as Map)['reminderDate'] != null
        ? (snapshot.data() as Map)['reminderDate'].toDate()
        : null;
    this.notes = (snapshot.data() as Map)['notes'];
    (snapshot.data() as Map)['tags'].forEach((tag) => {this._tags.add(Tag.fromDocument(tag))});
    this.gotFiles = (snapshot.data() as Map)['gotFiles'];
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
  DateTime get createdAt => _createdAt;
  String get deviceToken => _deviceToken;
  bool get hasDueDate => dueDate != null;
  bool get hasReminderDate => reminderDate != null;
  bool get hasNotes => notes != null && notes != '';
  bool get hasFiles => files.isNotEmpty;
  String get list => _list;
  List<Tag> get tags => _tags;
  List<Tag> get activeTags => _tags.where((tag) => tag.active == true).toList();

  dynamic get(String property) {
    if(this.toMap().containsKey(property)) {
      if(property == 'value') return value ? 1 : 0;
      else if(property == 'priority') return priority ? 1 : 0;
      else if(property == 'title') return title.toLowerCase();
      else if(property == 'dueDate') return dueDate;
      else return createdAt;
    }
    throw ArgumentError('Property $property not found!');
  }

  set title(String value) {
    if (value.isNotEmpty) {
      _title = value;
    }
  }
}