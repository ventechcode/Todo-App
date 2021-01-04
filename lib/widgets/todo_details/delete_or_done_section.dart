import 'package:flutter/material.dart';

class DeleteOrDoneSection extends StatelessWidget {
  final Function delete;
  final Function toggleDone;
  DeleteOrDoneSection({this.delete, this.toggleDone});

  createDeleteDialog(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Aufgabe Löschen?'),
            content: Text('Sind Sie sicher, dass Sie den Eintrag löschen möchten?'),
            contentTextStyle: TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
            actions: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, screenWidth * 0.037, 0),
                child: FlatButton(
                  splashColor: Colors.transparent,
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    delete();
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
    var screenHeight = MediaQuery.of(context).size.height;
    return Container(
      color: Colors.grey[100],
      margin: EdgeInsets.only(top: 6),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Container(
                height: screenHeight * 0.08,
                child: FlatButton.icon(
                  icon: Icon(
                    Icons.cancel_rounded,
                    color: Colors.black54,
                    size: 24,
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
                color: Colors.grey[400],
                thickness: 1.4,
              ),
            ),
            Expanded(
              child: Container(
                height: screenHeight * 0.08,
                child: FlatButton.icon(
                  icon: Icon(
                    Icons.check_circle,
                    color: Colors.lightBlue,
                    size: 24,
                  ),
                  label: Text(
                    'Erledigt',
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.lightBlue,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    toggleDone();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
