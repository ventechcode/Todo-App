import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:todoapp/services/todo_service.dart';
import 'package:todoapp/models/todo.dart';
import 'package:todoapp/widgets/todo_details/priority_checkbox.dart';

class TodoTitle extends StatefulWidget {
  final Todo? todo;
  final TodoService? todoService;
  final String? uid;

  TodoTitle({this.todo, this.uid, this.todoService});

  @override
  _TodoTitleState createState() => _TodoTitleState();
}

class _TodoTitleState extends State<TodoTitle> {
  final TextEditingController _titleController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Todo? todo;
  late bool lineThrough;

  @override
  void initState() {
    super.initState();
    todo = widget.todo;
    _titleController.text = todo!.title.trim();
    _titleController.text.trim();
    if (todo!.value) {
      lineThrough = true;
    } else {
      lineThrough = false;
    }
    KeyboardVisibilityController().onChange.listen((bool visible) {
      if (!visible) {
        _focusNode.unfocus();
        todo!.title = _titleController.text;
        widget.todoService!.updateTodo(todo!);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
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
            onFieldSubmitted: (value) {
              todo!.title = value;
              widget.todoService!.updateTodo(todo!);
              _focusNode.unfocus();
              setState(() {
                _titleController.text = value;
                if (todo!.value) {
                  lineThrough = true;
                } else {
                  lineThrough = false;
                }
              });
            },
          ),
        ),
        PriorityCheckbox(todo, widget.todoService),
      ],
    );
  }
}
