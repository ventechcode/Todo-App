import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:circular_check_box/circular_check_box.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:todoapp/models/todo.dart';

// TODO: überarbeiten der leiste unter dem todo titel 

class TodoItem extends StatelessWidget {
  final Todo todo;
  final DateFormat _format = DateFormat('EE, d. MMMM');
  final Function delete;
  final Function toggleDone;
  final ValueKey key;

  TodoItem({
    this.delete,
    this.toggleDone,
    this.key,
    this.todo,
  });

  String getUid() {
    return auth.FirebaseAuth.instance.currentUser.uid;
  }

  bool gotRowData() {
    return todo.hasFiles ||
        todo.notes != null && todo.notes != '' ||
        todo.reminderDate != null ||
        todo.reminderDate != null &&
            DateTime.now().isAfter(todo.reminderDate) == false;
  }

  bool hasDueAndReminderDate() {
    return todo.dueDate != null &&
        todo.reminderDate != null &&
        DateTime.now().isAfter(todo.reminderDate) == false;
  }

  bool gotOnlyFiles() {
    return todo.dueDate == null &&
            todo.reminderDate == null &&
            todo.notes == null ||
        todo.notes == '';
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return todo.value
        ? Dismissible(
            key: key,
            onDismissed: (_) => delete(),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 1.5,
              margin: EdgeInsets.fromLTRB(7, 4, 7, 4),
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 4),
                horizontalTitleGap: 8,
                onTap: null,
                leading: Container(
                  margin: const EdgeInsets.only(left: 8),
                  child: CircularCheckBox(
                    value: true,
                    onChanged: (_) => toggleDone(),
                    activeColor: Colors.lightBlue,               
                  ),
                ),
                title: Text(
                  todo.title.trim(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey,
                  ),
                ),
                trailing: Container(
                  margin: EdgeInsets.only(right: 3),
                  padding: EdgeInsets.only(top: 1),
                  child: IconButton(
                    iconSize: 21,
                    icon: Icon(
                      Icons.cancel_rounded,
                      color: Colors.grey[400],
                    ),
                    onPressed: () => delete(),
                  ),
                ),
              ),
            ),
          )
        : Container(
            child: Card(
              clipBehavior: Clip.antiAlias,
              key: key,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: EdgeInsets.fromLTRB(7, 4, 7, 4),
              elevation: 1.5,
              child: Container(
                child: ListTile(
                  key: ValueKey(todo.id),
                  dense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 4),
                  horizontalTitleGap: 8,
                  onTap: () async {
                    Navigator.of(context).pushNamed('/details', arguments: {
                      'todo': todo,
                      'delete': () => delete(),
                      'toggleDone': () => toggleDone()
                    });
                  },
                  leading: Container(
                    margin: const EdgeInsets.only(left: 8),
                    child: CircularCheckBox(
                      value: false,
                      onChanged: (_) => toggleDone(),
                      activeColor: Colors.lightBlue,
                      inactiveColor: Colors.grey[600],
                    ),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(right: 8),
                        child: Text(
                          todo.title.trim(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                      if (todo.priority)
                        Container(
                          margin: EdgeInsets.only(top: 3),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          height: 3.6,
                          width: 16,
                        ),
                      if (gotRowData())
                        Container(
                          margin: todo.priority
                              ? EdgeInsets.fromLTRB(0, 2, 5, 0)
                              : EdgeInsets.fromLTRB(0, 0, 5, 0),
                          height: 20,
                          width: screenWidth * 0.44,
                          child: Row(
                            children: [
                              if (todo.dueDate != null)
                                Icon(
                                  Icons.calendar_today,
                                  size: 13,
                                  color: todo.dueDate.day ==
                                              DateTime.now().day - 1 ||
                                          todo.dueDate.day <
                                              DateTime.now().day - 1
                                      ? Colors.red
                                      : Colors.grey[700],
                                ),
                              if (todo.dueDate != null) SizedBox(width: 3),
                              if (todo.dueDate != null)
                                Container(
                                  margin: EdgeInsets.only(top: 1),
                                  child: Text(
                                    _format.format(todo.dueDate) ==
                                            _format.format(DateTime.now())
                                        ? 'Heute'
                                        : todo.dueDate.day ==
                                                DateTime.now().day + 1
                                            ? 'Morgen'
                                            : todo.dueDate.day ==
                                                    DateTime.now().day - 1
                                                ? 'Gestern'
                                                : _format
                                                    .format(todo.dueDate)
                                                    .toString(),
                                    style: TextStyle(
                                      color: todo.dueDate.day ==
                                                  DateTime.now().day - 1 ||
                                              todo.dueDate.day <
                                                  DateTime.now().day - 1
                                          ? Colors.red
                                          : Colors.grey[700],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              if (hasDueAndReminderDate())
                                Container(
                                  margin: EdgeInsets.fromLTRB(1, 1.87, 1, 0),
                                  child: Transform.scale(
                                    scale: 0.21,
                                    child: Image(
                                      image:
                                          AssetImage('assets/images/dot.png'),
                                    ),
                                  ),
                                ),
                              if (todo.reminderDate != null &&
                                  DateTime.now().isAfter(todo.reminderDate) ==
                                      false)
                                Container(
                                  margin: todo.dueDate == null
                                      ? EdgeInsets.fromLTRB(0, 0.88, 1, 0)
                                      : EdgeInsets.fromLTRB(0, 0.88, 0, 0),
                                  child: Icon(
                                    Icons.notifications,
                                    size: 15,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              if (todo.reminderDate != null &&
                                  todo.dueDate == null &&
                                  DateTime.now().isAfter(todo.reminderDate) ==
                                      false) // got valid reminder and due date
                                Container(
                                  margin: EdgeInsets.fromLTRB(2, 1, 0, 0),
                                  child: Text(
                                    _format.format(todo.reminderDate) ==
                                            _format.format(DateTime.now())
                                        ? 'Heute'
                                        : todo.reminderDate.day ==
                                                DateTime.now().day + 1
                                            ? 'Morgen'
                                            : _format
                                                .format(todo.reminderDate)
                                                .toString(),
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              if ((todo.reminderDate != null &&
                                      !DateTime.now()
                                          .isAfter(todo.reminderDate)) ||
                                  todo.dueDate !=
                                      null) // has valid notes and a reminder or due date
                                if (todo.notes != null && todo.notes != '' ||
                                    todo.hasFiles)
                                  Container(
                                    margin: EdgeInsets.fromLTRB(1, 1.87, 1, 0),
                                    child: Transform.scale(
                                      scale: 0.21,
                                      child: Image(
                                        image:
                                            AssetImage('assets/images/dot.png'),
                                      ),
                                    ),
                                  ),
                              if (todo.notes != null && todo.notes != '')
                                Container(
                                  margin: todo.notes != null &&
                                              todo.notes != '' &&
                                              todo.reminderDate != null ||
                                          todo.dueDate != null
                                      ? EdgeInsets.fromLTRB(0.3, 1.44, 0, 0)
                                      : EdgeInsets.fromLTRB(0, 1, 0, 0),
                                  child: Icon(
                                    Icons.note_outlined,
                                    size: 15,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              if (todo.hasFiles)
                                Container(
                                  margin: EdgeInsets.only(top: 2),
                                  child: Icon(
                                    Icons.attach_file,
                                    size: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      if (!todo.priority) Container(),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
