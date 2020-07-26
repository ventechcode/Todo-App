import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:todoapp/services/database_service.dart';

class NotesSection extends StatefulWidget {
  final DatabaseService databaseService;
  final String todoId;
  NotesSection(this.databaseService, this.todoId);
  @override
  _NotesSectionState createState() => _NotesSectionState();
}

class _NotesSectionState extends State<NotesSection> {
  bool hasNotes = false;
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    return Container(
      margin: const EdgeInsets.fromLTRB(0.88, 16, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(left: 1),
            child: Text(
              'Notizen',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontFamily: 'Nexa'
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(0.88, 12, 0, 0),
            width: screenWidth * 0.87,
            child: StreamBuilder(
              stream: widget.databaseService.todoStream(widget.todoId),
              builder: (context, snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting) {
                  return DottedBorder(
                    dashPattern: [4, 3],
                    strokeCap: StrokeCap.round,
                    strokeWidth: 0.88,
                    borderType: BorderType.RRect,
                    radius: Radius.circular(8),
                    color: Colors.grey,
                    child: Container(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(8, 10, 8, 10),
                        child: Text(
                          'Tippe, um eine neue Notiz hinzuzufügen',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                if(snapshot.data['notes'].trim() == '' || snapshot.data['notes'] == null) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed('/notes', arguments: {
                        'title': snapshot.data['title'],
                        'notes': null,
                        'db_service': widget.databaseService,
                        'todoId': snapshot.data['id'],
                      });
                    },
                    child: DottedBorder(
                      dashPattern: [4, 3],
                      strokeCap: StrokeCap.round,
                      strokeWidth: 0.88,
                      borderType: BorderType.RRect,
                      radius: Radius.circular(8),
                      color: Colors.grey,
                      child: Container(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(8, 10, 8, 10),
                          child: Text(
                            'Tippe, um eine neue Notiz hinzuzufügen',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed('/notes', arguments: {
                        'title': snapshot.data['title'],
                        'notes': snapshot.data['notes'].trim(),
                        'db_service': widget.databaseService,
                        'todoId': snapshot.data['id'],
                      });
                    },
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        snapshot.data['notes'].trim(),
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}