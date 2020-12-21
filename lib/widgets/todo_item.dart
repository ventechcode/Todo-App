import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

class TodoItem extends StatelessWidget {
  final DateFormat _format = DateFormat('EE, d. MMMM');
  final String id;
  final String title;
  final String list;
  final bool done;
  final bool priority;
  final Function delete;
  final Function toggleDone;
  final ValueKey key;
  final Timestamp dueDate;
  final Timestamp reminderDate;
  final String notes;
  final bool gotFiles;

  TodoItem({
    this.id,
    this.title,
    this.done,
    this.delete,
    this.toggleDone,
    this.key,
    this.list,
    this.priority,
    this.dueDate,
    this.reminderDate,
    this.notes,
    this.gotFiles,
  });

  Future<String> getUid() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    return user.uid;
  }

  bool gotRowData() {
    return gotFiles || notes != null && notes != '' || dueDate != null || reminderDate != null && DateTime.now().isAfter(reminderDate.toDate()) == false;
  }

  bool hasDueAndReminderDate() {
    return dueDate != null && reminderDate != null && DateTime.now().isAfter(reminderDate.toDate()) == false;
  }

  bool gotOnlyFiles() {
    return dueDate == null && reminderDate == null && notes == null || notes == '';
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    return done
        ? Dismissible(
      key: key,
      onDismissed: (_) => delete(),
      child: Card(
        elevation: 1,
        margin: EdgeInsets.fromLTRB(7, 4, 7, 4),
        child: ListTile(
          dense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 4),
          onTap: () async {
            Navigator.of(context).pushNamed('/todo_details', arguments: {
              'id': id,
              'value': done,
              'uid': await getUid(),
              'list': list,
            });
          },
          leading: Container(
            margin: const EdgeInsets.only(left: 8),
            child: GestureDetector(
              onTap: () => toggleDone(),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                  child: Icon(
                    Icons.check_box,
                    color: Colors.lightBlue,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.trim(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  decoration: done
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ],
          ),
          trailing: done
              ? Container(
            padding: EdgeInsets.only(top: 1),
            child: IconButton(
              iconSize: 24,
              icon: Icon(Icons.delete),
              onPressed: () => delete(),
            ),
          )
              : null,
        ),
      ),
    )
        : Container(
      child: Card(
        key: key,
        margin: EdgeInsets.fromLTRB(7, 4, 7, 4),
        elevation: 1,
        child: Container(
          child: ListTile(
            key: ValueKey(id),
            dense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 4),
            onTap: () async {
              if(gotFiles) print('test');
              Navigator.of(context)
                  .pushNamed('/todo_details', arguments: {
                'id': id,
                'value': done,
                'uid': await getUid(),
                'list': list,
              });
            },
            leading: Container(
              margin: const EdgeInsets.only(left: 8),
              child: GestureDetector(
                onTap: () => toggleDone(),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(44),
                    color: Colors.transparent,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                    child: Icon(
                      Icons.check_box_outline_blank,
                      size: 28,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    title.trim(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      decoration: done
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                if (priority)
                  Container(
                    margin: EdgeInsets.only(top: 3),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    height: 3.6,
                    width: 16,
                  ),
                if(gotRowData())
                  Container(
                    margin: priority ? EdgeInsets.fromLTRB(0, 2, 5, 0) : EdgeInsets.fromLTRB(0, 0, 5, 0),
                    height: 20,
                    width: screenWidth * 0.44,
                    child: Row(
                      children: [
                        if(dueDate != null)
                          Icon(
                            Icons.calendar_today,
                            size: 13,
                            color: dueDate.toDate().day == DateTime.now().day - 1 || dueDate.toDate().day < DateTime.now().day -1 ? Colors.red : Colors.grey[700],
                          ),
                        if(dueDate != null)
                          SizedBox(width: 3),
                        if(dueDate != null)
                          Container(
                            margin: EdgeInsets.only(top: 1),
                            child: Text(
                              _format.format(dueDate.toDate()) ==
                                  _format.format(DateTime.now())
                                  ? 'Heute'
                                  : dueDate
                                  .toDate()
                                  .day ==
                                  DateTime
                                      .now()
                                      .day + 1
                                  ? 'Morgen'
                                  : dueDate.toDate().day == DateTime.now().day - 1 ? 'Gestern' :_format
                                  .format(dueDate.toDate())
                                  .toString(),
                              style: TextStyle(
                                color: dueDate.toDate().day == DateTime.now().day - 1 || dueDate.toDate().day < DateTime.now().day -1 ? Colors.red : Colors.grey[700],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        if(hasDueAndReminderDate())
                          Container(
                            margin: EdgeInsets.fromLTRB(1, 1.87, 1, 0),
                            child: Transform.scale(
                              scale: 0.21,
                              child: Image(
                                image: AssetImage('assets/images/dot.png'),
                              ),
                            ),
                          ),
                        if(reminderDate != null && DateTime.now().isAfter(reminderDate.toDate()) == false) // got reminder date
                          Container(
                            margin: dueDate == null ? EdgeInsets.fromLTRB(0, 0.88, 1, 0) : EdgeInsets.fromLTRB(0, 0.88, 0, 0),
                            child: Icon(
                              Icons.notifications,
                              size: 15,
                              color: Colors.grey[700],
                            ),
                          ),
                        if(reminderDate != null && dueDate == null && DateTime.now().isAfter(reminderDate.toDate()) == false) // got valid reminder and due date
                          Container(
                            margin: EdgeInsets.fromLTRB(2, 1, 0, 0),
                            child: Text(
                              _format.format(reminderDate.toDate()) ==
                                  _format.format(DateTime.now())
                                  ? 'Heute'
                                  : reminderDate
                                  .toDate()
                                  .day ==
                                  DateTime
                                      .now()
                                      .day + 1
                                  ? 'Morgen'
                                  :_format
                                  .format(reminderDate.toDate())
                                  .toString(),
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        if((reminderDate != null && !DateTime.now().isAfter(reminderDate.toDate())) || dueDate != null) // has valid notes and a reminder or due date
                          if(notes != null && notes != '' || gotFiles)
                            Container(
                              margin: EdgeInsets.fromLTRB(1, 1.87, 1, 0),
                              child: Transform.scale(
                                scale: 0.21,
                                child: Image(
                                  image: AssetImage('assets/images/dot.png'),
                                ),
                              ),
                            ),
                        if(notes != null && notes != '')
                          Container(
                            margin: notes != null && notes != '' && reminderDate != null || dueDate != null ? EdgeInsets.fromLTRB(0.3, 1.44, 0, 0) : EdgeInsets.fromLTRB(0, 1, 0, 0),
                            child: Icon(
                              Icons.note_outlined,
                              size: 15,
                              color: Colors.grey[700],
                            ),
                          ),
                        if(gotFiles)
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
                if (!priority) Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
