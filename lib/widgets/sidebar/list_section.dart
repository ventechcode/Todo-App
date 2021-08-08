import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todoapp/models/todo_list.dart';
import 'package:todoapp/models/user.dart';
import 'package:todoapp/services/database_service.dart';
import 'package:todoapp/widgets/sidebar/todo_list_item.dart';

class ListSection extends StatefulWidget {
  final User user;
  ListSection(this.user);

  @override
  _ListSectionState createState() => _ListSectionState();
}

class _ListSectionState extends State<ListSection> {
  List<TodoList> staticLists = [];
  List<TodoList> dynamicLists = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder(
        stream: DatabaseService(widget.user.uid).getUserLists(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.none ||
              snapshot.data == null) return Container();

          var _docs = (snapshot.data as QuerySnapshot).docs;

          _docs.forEach((doc) {
            if((doc.data() as Map)['static'] == false) {
              dynamicLists.add(TodoList.fromDocument(doc));
            } else {
              staticLists.add(TodoList.fromDocument(doc));
            }
          });

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for(TodoList list in staticLists)
                TodoListItem(list)
            ],
          );
        },
      ),
    );
  }
}
