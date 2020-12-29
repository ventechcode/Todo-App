import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimestampSection extends StatelessWidget {
  final Timestamp timestamp;
  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');

  TimestampSection({this.timestamp});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Erstellt',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontFamily: 'Nexa',
            ),
          ),
          SizedBox(height: 10),
          Text(
            _dateFormat.format(timestamp.toDate()),
            style: TextStyle(fontSize: 16),
          ),
          //SizedBox(height: 10)
        ],
      ),
    );
  }
}
