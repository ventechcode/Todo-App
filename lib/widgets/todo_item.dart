import 'package:flutter/material.dart';

class TodoItem extends StatelessWidget {
  final String id;
  final String title;
  final bool done;
  final Function delete;
  final Function toggleDone;
  final ValueKey key;

  const TodoItem({
    this.id,
    this.title,
    this.done,
    this.delete,
    this.toggleDone,
    this.key
  });

  @override
  Widget build(BuildContext context) {
    return done ? Dismissible(
      key: key,
      onDismissed: (_) => delete(),
      child: Card(
        elevation: 1,
        margin: EdgeInsets.fromLTRB(7, 4, 7, 4),
        child: ListTile(
          dense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 4),
          onTap: () {},
          leading: Checkbox(
            activeColor: Colors.lightBlue,
            value: done,
            onChanged: (_) => toggleDone(),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              decoration: done ? TextDecoration.lineThrough : TextDecoration.none,
            ),
          ),
          trailing: done
              ? Container(
            padding: EdgeInsets.only(top: 1),
            child: IconButton(
              iconSize: 22,
              icon: Icon(Icons.delete),
              onPressed: () => delete(),
            ),
          )
              : null,
        ),
      ),
    ) : Card(
      key: key,
      margin: EdgeInsets.fromLTRB(7, 4, 7, 4),
      elevation: 1,
      child: ListTile(
        key: ValueKey(id),
        dense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 4),
        onTap: () {},
        leading: Checkbox(
          activeColor: Colors.lightBlue,
          value: done,
          onChanged: (_) => toggleDone(),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            decoration: done ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
      ),
    );
  }
}