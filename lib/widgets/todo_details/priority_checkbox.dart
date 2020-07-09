import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:todoapp/services/database_service.dart';

class PriorityCheckbox extends StatefulWidget {
  final DatabaseService databaseService;
  final String todoID;
  final bool priority;
  PriorityCheckbox(this.databaseService, this.todoID, this.priority);

  @override
  _PriorityCheckboxState createState() => _PriorityCheckboxState();
}

class _PriorityCheckboxState extends State<PriorityCheckbox> with TickerProviderStateMixin {
  bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.priority;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(9, 0, 0, 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(36),
        splashColor: Colors.transparent,
        highlightColor: Colors.amberAccent,
        radius: 5,
        onTap: () {
          setState(() {
            _value = !_value;
            widget.databaseService.togglePriority(widget.todoID, _value);
          });
        },
        child: Padding(
          padding: EdgeInsets.all(8),
          child: _value
              ? Icon(
                  Icons.star,
                  size: 36,
                  color: Colors.amber,
                )
              : Icon(
                  Icons.star_border,
                  size: 36,
                ),
        ),
      ),
    );
  }
}