import 'package:flutter/material.dart';
import 'package:todoapp/services/database_service.dart';
import 'package:todoapp/widgets/todo_details/attach_section.dart';
import 'package:todoapp/widgets/todo_details/date_picker.dart';
import 'package:todoapp/widgets/todo_details/notes_section.dart';
import 'package:todoapp/widgets/todo_details/reminder_picker.dart';
import 'package:todoapp/widgets/todo_details/tag_section.dart';
import 'package:todoapp/widgets/todo_details/todo_title.dart';

class TodoDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map data = ModalRoute.of(context).settings.arguments;
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
        body: StreamBuilder(
          stream: DatabaseService(data['uid'], list: data['list']).todoStream(data['id']),
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting) {
              return Center();
            }
            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(22, 5, 0, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TodoTitle(
                          snapshot.data['title'],
                          data['id'],
                          data['uid'],
                          data['list'],
                          data['value'],
                          snapshot.data['priority'],
                        ),
                        ReminderPicker(
                          todoID: data['id'],
                          notificationDate: snapshot.data['reminderDate'],
                          databaseService: DatabaseService(data['uid'], list: data['list']),
                        ),
                        CustomDatePicker(DatabaseService(data['uid'], list: data['list']), data['id'], snapshot.data['dueDate']),
                        NotesSection(DatabaseService(data['uid'], list: data['list']), data['id']),
                        AttachSection(DatabaseService(data['uid'], list: data['list']), data['id']),
                        TagSection(DatabaseService(data['uid'], list: data['list']), data['id']),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
}