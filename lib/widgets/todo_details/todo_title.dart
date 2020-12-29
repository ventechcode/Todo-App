import 'package:flutter/material.dart';
import 'package:todoapp/services/database_service.dart';
import 'package:todoapp/widgets/todo_details/priority_checkbox.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';

class TodoTitle extends StatefulWidget {
  final String title;
  final String id;
  final String uid;
  final String list;
  final bool value;
  final bool priority;

  TodoTitle(
      this.title, this.id, this.uid, this.list, this.value, this.priority);

  @override
  _TodoTitleState createState() => _TodoTitleState();
}

class _TodoTitleState extends State<TodoTitle> {
  final TextEditingController _titleController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final KeyboardVisibilityNotification keyboard =
      KeyboardVisibilityNotification();
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
    keyboard.addNewListener(onHide: () {
      _focusNode.unfocus();
      _databaseService.updateTodoTitle(widget.id, _titleController.text);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
    keyboard.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Row(
      children: [
        Container(
          width: screenWidth * 0.744,
          child: TextFormField(
            focusNode: _focusNode,
            autofocus: false,
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
            onFieldSubmitted: (value) async {
              await _databaseService.updateTodoTitle(widget.id, value);
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
