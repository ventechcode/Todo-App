import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:todoapp/services/todo_service.dart';
import 'package:todoapp/models/todo.dart';

class NotesSection extends StatefulWidget {
  final Todo todo;
  final TodoService todoService;

  NotesSection({this.todo, this.todoService});

  @override
  _NotesSectionState createState() => _NotesSectionState();
}

class _NotesSectionState extends State<NotesSection> {
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notizen',
            style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontFamily: 'Nexa'),
          ),
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: screenWidth * 0.88,
            child: widget.todo.notes == '' || widget.todo.notes == null
                ? GestureDetector(
                    onTap: () {
                      widget.todo.notes = null;
                      Navigator.of(context).pushNamed('/notes', arguments: {
                        'todo': widget.todo,
                        'todoService': widget.todoService,
                      }).then((notes) {
                        setState(() {
                          widget.todo.notes = notes;
                        });
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
                  )
                : GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed('/notes', arguments: {
                        'todo': widget.todo,
                        'todoService': widget.todoService,
                      }).then((notes) {
                        setState(() {
                          widget.todo.notes = notes;
                        });
                      });
                    },
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.todo.notes.trim(),
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
