import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:todoapp/services/database_service.dart';

class AttachSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    return Container(
      margin: const EdgeInsets.fromLTRB(0.88, 16, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(left: 1),
            child: Text(
              'Dateien',
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Nexa'
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(0.88, 12, 0, 0),
            width: screenWidth * 0.87,
            child: GestureDetector(
              onTap: () {},
              child: DottedBorder(
                dashPattern: [4, 3],
                strokeCap: StrokeCap.round,
                strokeWidth: 0.88,
                borderType: BorderType.RRect,
                radius: Radius.circular(8),
                color: Colors.grey,
                child: Container(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(8, 10, 8, 10),
                    child: Text(
                      'Tippe, um Dateien hinzuzufügen',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}