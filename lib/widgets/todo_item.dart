import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:todoapp/models/todo.dart';

class TodoItem extends StatelessWidget {
  final Todo? todo;
  final DateFormat _format = DateFormat('EE, d. MMMM');
  final Function? delete;
  final Function? toggleDone;
  final ValueKey? key;

  TodoItem({
    this.delete,
    this.toggleDone,
    this.key,
    this.todo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Intl.defaultLocale = 'de_DE';
    initializeDateFormatting('de_DE');
    return todo!.value
        ? Dismissible(
            key: key!,
            onDismissed: (_) => delete!(),
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
                  child: Transform.scale(
                    scale: 1.36,
                    child: Checkbox(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      value: true,
                      onChanged: (_) => toggleDone!(),
                      activeColor: Colors.lightBlue,
                    ),
                  ),
                ),
                title: Text(
                  todo!.title.trim(),
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
                    onPressed: () => delete!(),
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
                  key: ValueKey(todo!.id),
                  dense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 4),
                  horizontalTitleGap: 8,
                  onTap: () {
                    Navigator.of(context).pushNamed('/details', arguments: {
                      'todo': todo,
                      'delete': () => delete!(),
                      'toggleDone': () => toggleDone!()
                    });
                  },
                  leading: Container(
                    margin: const EdgeInsets.only(left: 8),
                    child: Transform.scale(
                      scale: 1.36,
                      child: Checkbox(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        value: false,
                        fillColor: MaterialStateProperty.resolveWith(
                            (states) => Colors.grey[600]),
                        onChanged: (_) => toggleDone!(),
                        activeColor: Colors.lightBlue,
                      ),
                    ),
                  ),
                  title: ListView(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Text(
                          todo!.title.trim(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          if (todo!.priority)
                            Container(
                              padding: EdgeInsets.only(top: 3),
                              margin: EdgeInsets.fromLTRB(0, 3, 5, 1.5),
                              decoration: BoxDecoration(
                                color: Color(int.parse('0xffffd740')),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              height: 3.6,
                              width: 16,
                            ),
                          for (var tag in todo!.activeTags)
                            Container(
                              padding: EdgeInsets.only(top: 3),
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
                      if (todo!.activeTags.isNotEmpty) SizedBox(height: 3),
                      Wrap(
                        children: [
                          if (todo!.hasDueDate)
                            Container(
                              padding: EdgeInsets.only(top: 3),
                              margin: EdgeInsets.only(right: 3.5),
                              child: Icon(
                                Icons.calendar_today_rounded,
                                size: 15,
                                color: todo!.dueDate!.day ==
                                            DateTime.now().day - 1 ||
                                        todo!.dueDate!.day <
                                            DateTime.now().day - 1
                                    ? Colors.red
                                    : Colors.grey[700],
                              ),
                            ),
                          if (todo!.hasDueDate)
                            Container(
                              padding: EdgeInsets.only(top: 4),
                              margin: EdgeInsets.fromLTRB(0, 0.75, 3.5, 0),
                              child: Text(
                                _format.format(todo!.dueDate!) ==
                                        _format.format(DateTime.now())
                                    ? 'Heute, ' +
                                        TimeOfDay(
                                                hour: todo!.dueDate!.hour,
                                                minute: todo!.dueDate!.minute)
                                            .format(context) +
                                        ' Uhr'
                                    : todo!.dueDate!.day ==
                                            DateTime.now().day + 1
                                        ? 'Morgen, ' +
                                            TimeOfDay(
                                                    hour: todo!.dueDate!.hour,
                                                    minute:
                                                        todo!.dueDate!.minute)
                                                .format(context) +
                                            ' Uhr'
                                        : todo!.dueDate!.day ==
                                                DateTime.now().day - 1
                                            ? 'Gestern, ' +
                                                TimeOfDay(
                                                        hour:
                                                            todo!.dueDate!.hour,
                                                        minute: todo!
                                                            .dueDate!.minute)
                                                    .format(context) +
                                                ' Uhr'
                                            : _format
                                                    .format(todo!.dueDate!)
                                                    .toString() +
                                                TimeOfDay(
                                                        hour:
                                                            todo!.dueDate!.hour,
                                                        minute:
                                                            todo!.dueDate!.minute)
                                                    .format(context) +
                                                ' Uhr',
                                style: TextStyle(
                                  color: todo!.dueDate!.day ==
                                              DateTime.now().day - 1 ||
                                          todo!.dueDate!.day <
                                              DateTime.now().day - 1
                                      ? Colors.red
                                      : Colors.grey[700],
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          if (todo!.hasDueDate)
                            if (todo!.hasReminderDate ||
                                todo!.gotFiles ||
                                todo!.hasNotes)
                              if (todo!.reminderDate != null)
                                if (!DateTime.now()
                                    .isAfter(todo!.reminderDate!))
                                  Container(
                                    padding: EdgeInsets.only(top: 3),
                                    margin: EdgeInsets.fromLTRB(2, 6, 3.5, 0),
                                    child: Icon(
                                      Icons.circle,
                                      size: 4,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                          if (todo!.hasReminderDate &&
                              !DateTime.now().isAfter(todo!.reminderDate!))
                            Container(
                              padding: EdgeInsets.only(top: 3),
                              margin: EdgeInsets.only(right: 3.5),
                              child: Icon(
                                Icons.notifications,
                                size: 15,
                                color: Colors.grey[700],
                              ),
                            ),
                          if (todo!.hasReminderDate &&
                              !DateTime.now().isAfter(todo!.reminderDate!))
                            Container(
                              padding: EdgeInsets.only(top: 4),
                              margin: EdgeInsets.fromLTRB(0, 0.75, 3.5, 0),
                              child: Text(
                                _format.format(todo!.reminderDate!) ==
                                        _format.format(DateTime.now())
                                    ? 'Heute, ' +
                                        TimeOfDay(
                                                hour: todo!.reminderDate!.hour,
                                                minute:
                                                    todo!.reminderDate!.minute)
                                            .format(context) +
                                        ' Uhr'
                                    : todo!.reminderDate!.day ==
                                            DateTime.now().day + 1
                                        ? 'Morgen, ' +
                                            TimeOfDay(hour: todo!.reminderDate!.hour, minute: todo!.reminderDate!.minute)
                                                .format(context) +
                                            ' Uhr'
                                        : todo!.reminderDate!.day ==
                                                DateTime.now().day - 1
                                            ? 'Gestern, ' +
                                                TimeOfDay(
                                                        hour: todo!
                                                            .reminderDate!.hour,
                                                        minute: todo!
                                                            .reminderDate!
                                                            .minute)
                                                    .format(context) +
                                                ' Uhr'
                                            : _format
                                                    .format(todo!.reminderDate!)
                                                    .toString() +
                                                ', ' +
                                                TimeOfDay(
                                                        hour: todo!.reminderDate!.hour,
                                                        minute: todo!.reminderDate!.minute)
                                                    .format(context) +
                                                ' Uhr',
                                style: TextStyle(
                                  color: todo!.reminderDate!.day ==
                                              DateTime.now().day - 1 ||
                                          todo!.reminderDate!.day <
                                              DateTime.now().day - 1
                                      ? Colors.red
                                      : Colors.grey[700],
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          if (todo!.hasDueDate || todo!.hasReminderDate)
                            if (todo!.gotFiles || todo!.hasNotes)
                              Container(
                                padding: EdgeInsets.only(top: 3),
                                margin: EdgeInsets.fromLTRB(2, 6, 6, 0),
                                child: Icon(
                                  Icons.circle,
                                  size: 4,
                                  color: Colors.grey[400],
                                ),
                              ),
                          if (todo!.hasNotes)
                            Container(
                              padding: EdgeInsets.only(top: 4),
                              margin: EdgeInsets.only(right: 1),
                              child: Icon(
                                Icons.note_outlined,
                                size: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          if (todo!.gotFiles)
                            Container(
                              padding: EdgeInsets.only(top: 4),
                              margin: EdgeInsets.only(right: 3),
                              child: Icon(
                                Icons.attach_file,
                                size: 14,
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
