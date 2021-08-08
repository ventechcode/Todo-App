import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:todoapp/models/todo_list.dart';
import 'package:todoapp/screens/task_screen.dart';
import 'package:todoapp/models/user.dart';

class TodoListItem extends StatefulWidget {
  final TodoList list;
  const TodoListItem(this.list);

  @override
  _TodoListItemState createState() => _TodoListItemState();
}

class _TodoListItemState extends State<TodoListItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          TextButton.icon(onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => TaskScreen(User.fromFirebaseUser(fb.FirebaseAuth.instance.currentUser), widget.list))
            );
          }, icon: Icon(widget.list.icon), label: Text(widget.list.name))
        ],
      ),
    );
  }
}