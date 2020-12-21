import 'package:flutter/material.dart';

class Tag extends StatelessWidget {
  final String name;
  final Color color;
  final Function removeTag;

  Tag(this.name, this.color, this.removeTag);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 8, 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: color,
          style: BorderStyle.solid,
          width: 2.69,
        ),
        borderRadius: BorderRadius.circular(20),
        color: color,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(8, 3, 4, 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 7),
            GestureDetector(
              child: Icon(
                Icons.clear,
                size: 13,
                color: Colors.white,
              ),
              onTap: () => removeTag(),
            ),
          ],
        ),
      ),
    );
  }
}
