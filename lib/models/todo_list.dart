import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class TodoList {
  final String id;
  final String name;
  final bool static;
  IconData? icon;

  TodoList.static(this.name)
      : this.id = name,
        this.static = true {
    switch (name) {
      case 'Alle Aufgaben':
        this.icon = Icons.checklist_rtl_rounded;
        break;
      case 'Wichtig':
        this.icon = Icons.star_outline_rounded;
        break;
      case 'Heute':
        this.icon = Icons.today_rounded;
        break;
      case 'Geplant':
        this.icon = Icons.calendar_today_rounded;
        break;
      default:
        this.icon = null;
    }
  }

  TodoList.dynamic(this.name)
      : this.id = Uuid().v4(),
        this.static = false,
        this.icon = Icons.checklist_rtl_rounded;

  TodoList.fromDocument(DocumentSnapshot snapshot)
      : this.id = snapshot.id,
        this.name = (snapshot.data() as Map)['name'],
        this.static = (snapshot.data() as Map)['static'],
        this.icon = IconData((snapshot.data() as Map)['iconData'], fontFamily: 'MaterialIcons');

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'static': static,
      'iconData': icon == null ? Icons.checklist_rtl_rounded.codePoint : icon!.codePoint,
    };
  }

  @override
  String toString() {
    return '$id' + ', $name' + ', $static';
  }
}
