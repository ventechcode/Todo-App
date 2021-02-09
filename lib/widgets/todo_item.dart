import 'dart:ui';

import 'package:circular_check_box/circular_check_box.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:todoapp/models/todo.dart';

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

  @override
  Widget build(BuildContext context) {
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
                  title: ListView(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Text(
                          todo.title.trim(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          if (todo.priority)
                            Container(
                              margin: EdgeInsets.fromLTRB(0, 3, 5, 1.5),
                              decoration: BoxDecoration(
                                color: Color(int.parse('0xffffd740')),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              height: 3.6,
                              width: 16,
                            ),
                          for (var tag in todo.activeTags)
                            Container(
                              margin: EdgeInsets.fromLTRB(0, 3, 5, 1.5),
                              decoration: BoxDecoration(
                                color: Color(int.parse(tag.colorString)),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              height: 3.6,
                              width: 16,
                            ),
                        ],
                      ),
                      if (todo.activeTags.isNotEmpty) SizedBox(height: 3),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (todo.hasDueDate)
                            Container(
                              margin: EdgeInsets.only(right: 5),
                              child: Icon(
                                Icons.calendar_today_rounded,
                                size: 15,
                                color: todo.dueDate.day ==
                                            DateTime.now().day - 1 ||
                                        todo.dueDate.day <
                                            DateTime.now().day - 1
                                    ? Colors.red
                                    : Colors.grey[700],
                              ),
                            ),
                          if (todo.hasDueDate)
                            Container(
                              margin: EdgeInsets.fromLTRB(0, 0.75, 5, 0),
                              child: Text(
                                _format.format(todo.dueDate) ==
                                        _format.format(DateTime.now())
                                    ? 'Heute'
                                    : todo.dueDate.day == DateTime.now().day + 1
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
                          if (todo.hasDueDate)
                            if (todo.hasReminderDate ||
                                todo.gotFiles ||
                                todo.hasNotes)
                              Container(
                                margin: EdgeInsets.fromLTRB(2, 6, 6, 0),
                                child: Icon(
                                  Icons.circle,
                                  size: 4,
                                  color: Colors.grey[400],
                                ),
                              ),
                          if (todo.hasReminderDate)
                            Container(
                              margin: EdgeInsets.only(right: 5),
                              child: Icon(
                                Icons.notifications,
                                size: 15,
                                color: Colors.grey[700],
                              ),
                            ),
                          if (todo.hasNotes)
                            Container(
                              margin: EdgeInsets.only(right: 5),
                              child: Icon(
                                Icons.note_outlined,
                                size: 15,
                                color: Colors.grey[700],
                              ),
                            ),
                          if (todo.gotFiles)
                            Container(
                              margin: EdgeInsets.only(right: 5),
                              child: Icon(
                                Icons.attach_file,
                                size: 15,
                                color: Colors.grey[700],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
