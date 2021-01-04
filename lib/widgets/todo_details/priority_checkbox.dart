import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:todoapp/services/todo_service.dart';
import 'package:todoapp/models/todo.dart';

class PriorityCheckbox extends StatefulWidget {
  final Todo todo;
  final TodoService todoService;

  PriorityCheckbox(this.todo, this.todoService);

  @override
  _PriorityCheckboxState createState() => _PriorityCheckboxState();
}

class _PriorityCheckboxState extends State<PriorityCheckbox> with SingleTickerProviderStateMixin {
  Todo todo;
  AnimationController _animationController;
  Animation<Color> _colorAnimation;
  Animation<double> _sizeAnimation;
  Animation _curve;
  bool _value;
  bool case1 = false;
  bool case2 = false;

  @override
  void initState() {
    super.initState();
    todo = widget.todo;
    _value = todo.priority;

    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _curve = CurvedAnimation(parent: _animationController, curve: Curves.slowMiddle);

    _colorAnimation = _value ? ColorTween(begin: Colors.amber, end: Colors.grey[400]).animate(_curve) : ColorTween(begin: Colors.grey[400], end: Colors.amber).animate(_curve);
    if(_value) case1 = true;
    else case2 = true;
    
    _sizeAnimation = TweenSequence(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 36, end: 50),
          weight: 50,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 50, end: 36),
          weight: 50,
        ),
      ],
    ).animate(_curve);

    _animationController.addStatusListener((status) {
      if(status == AnimationStatus.completed) {
        setState(() {
          _value = true;
        });
      }

      if(status == AnimationStatus.dismissed) {
        setState(() {
          _value = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 8),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return IconButton(
            splashColor: null,
            splashRadius: 1,
            tooltip: 'Wichtig',
            onPressed: () {
              if(case1) _value ? _animationController.forward().whenComplete(() {
                _value = !_value;
                todo.priority = _value;
                widget.todoService.updateTodo(todo);
              }) : _animationController.reverse().whenComplete(() {
                _value = !_value;
                todo.priority = _value;
                widget.todoService.updateTodo(todo);
              });
              if(case2) _value ? _animationController.reverse().whenComplete(() {
                todo.priority = _value;
                widget.todoService.updateTodo(todo);
              }) : _animationController.forward().whenComplete(() {
                todo.priority = _value;
                widget.todoService.updateTodo(todo);
              });
            },
            icon: Icon(
              Icons.star,
              size: _sizeAnimation.value,
              color: _colorAnimation.value,
            ),
          );
        },
      ),
    );
  }
}