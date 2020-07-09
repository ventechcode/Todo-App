import 'package:flutter/material.dart';
import 'package:todoapp/services/database_service.dart';
import 'package:todoapp/widgets/todo_details/priority_checkbox.dart';

class TodoTitle extends StatefulWidget {
  final String title;
  final String id;
  final String uid;
  final String list;
  final bool value;
  final bool priority;

  TodoTitle(this.title, this.id, this.uid, this.list, this.value, this.priority);

  @override
  _TodoTitleState createState() => _TodoTitleState();
}

class _TodoTitleState extends State<TodoTitle> {
  final TextEditingController _titleController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  DatabaseService _databaseService;
  bool lineThrough;

  @override
  void initState() {
    super.initState();
    _databaseService = DatabaseService(widget.uid, list: widget.list);
    _titleController.text = widget.title.trim();
    _titleController.text.trim();
    if (widget.value) {
      lineThrough = true;
    } else {
      lineThrough = false;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var padding = MediaQuery.of(context).padding;
    var screenWidth = MediaQuery.of(context).size.width;
    return Row(
      children: [
        Container(
          width: screenWidth * 0.744,
          child: TextField(
            focusNode: _focusNode,
            cursorColor: Colors.black,
            controller: _titleController,
            style: TextStyle(
              color: Colors.black,
              fontSize: 31,
              fontWeight: FontWeight.bold,
              decoration: lineThrough
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Ich möchte...',
              hintStyle: TextStyle(
                decoration: TextDecoration.none,
              ),
            ),
            onTap: () => setState(() => lineThrough = false),
            onSubmitted: (value) async {
              _databaseService.updateTodoTitle(widget.id, value);
              _focusNode.unfocus();
              setState(() {
                _titleController.text = value;
                if (widget.value) {
                  lineThrough = true;
                } else {
                  lineThrough = false;
                }
              });
            },
          ),
        ),
        PriorityCheckbox(_databaseService, widget.id, widget.priority),
      ],
    );
  }
}
