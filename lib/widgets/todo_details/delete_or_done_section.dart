import 'package:flutter/material.dart';
import 'package:todoapp/services/database_service.dart';

class DeleteOrDoneSection extends StatelessWidget {
  final Function delete;
  final String todoId;
  DeleteOrDoneSection({this.delete, this.todoId});

  createDeleteDialog(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Aufgabe Löschen?'),
            content:
                Text('Sind Sie sicher, dass Sie den Eintrag löschen möchten?'),
            contentTextStyle: TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
            actions: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, screenWidth * 0.037, 0),
                child: FlatButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Löschen',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      margin: EdgeInsets.only(top: 8),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Container(
                height: 55,
                child: FlatButton.icon(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.black54,
                    size: 26,
                  ),
                  label: Text(
                    'Löschen',
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.black54,
                    ),
                  ),
                  onPressed: () => createDeleteDialog(context),
                ),
              ),
            ),
            Container(
              height: 28,
              child: VerticalDivider(
                width: 2,
                color: Colors.grey,
                thickness: 1.4,
              ),
            ),
            Expanded(
              child: Container(
                height: 55,
                child: FlatButton.icon(
                  icon: Icon(
                    Icons.done,
                    color: Colors.lightBlue,
                    size: 26,
                  ),
                  label: Text(
                    'Erledigt',
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.lightBlue,
                    ),
                  ),
                  onPressed: () => print('done'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
