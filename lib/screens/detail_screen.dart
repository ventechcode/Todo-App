import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todoapp/models/todo.dart';
import 'package:todoapp/models/user.dart';
import 'package:todoapp/widgets/scroll_behavior.dart';
import 'package:todoapp/widgets/todo_details/attach_section.dart';
import 'package:todoapp/widgets/todo_details/date_picker.dart';
import 'package:todoapp/widgets/todo_details/delete_or_done_section.dart';
import 'package:todoapp/widgets/todo_details/notes_section.dart';
import 'package:todoapp/widgets/todo_details/reminder_picker.dart';
import 'package:todoapp/widgets/todo_details/tag_section.dart';
import 'package:todoapp/widgets/todo_details/timestamp_section.dart';
import 'package:todoapp/widgets/todo_details/todo_title.dart';
import 'package:todoapp/services/todo_service.dart';

class DetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final Todo todo = data['todo'];
    final Function? delete = data['delete'];
    final Function? toggleDone = data['toggleDone'];
    final User user = Provider.of<User>(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            'Aufgabendetails'.toUpperCase(),
            style: TextStyle(
              fontSize: 17,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          elevation: 0,
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.fromLTRB(22, 5, 0, 10),
                child: ScrollConfiguration(
                  behavior: CustomScrollBehavior(),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TodoTitle(
                          todo: todo,
                          uid: user.uid,
                          todoService: TodoService(user: user, list: todo.list),
                        ),
                        ReminderPicker(
                          todo: todo,
                          uid: user.uid,
                          todoService: TodoService(user: user, list: todo.list),
                        ),
                        CustomDatePicker(
                          todo: todo,
                          todoService: TodoService(user: user, list: todo.list),
                        ),
                        NotesSection(
                          todo: todo,
                          todoService: TodoService(user: user, list: todo.list),
                        ),
                        AttachSection(
                          todo: todo,
                          todoService: TodoService(user: user, list: todo.list),
                        ),
                        TagSection(
                          todo: todo,
                          todoService: TodoService(user: user, list: todo.list),
                        ),
                        TimestampSection(
                          timestamp: todo.createdAt,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            DeleteOrDoneSection(
              delete: () => delete!(),
              toggleDone: () => toggleDone!(),
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
}