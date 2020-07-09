import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:todoapp/services/database_service.dart';

class CustomDatePicker extends StatefulWidget {
  final DatabaseService databaseService;
  final Timestamp dueDate;
  final String todoID;

  CustomDatePicker(this.databaseService, this.todoID, this.dueDate);

  @override
  _CustomDatePickerState createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  final DateFormat _format = DateFormat('EE, d. MMMM');
  DateTime _dateTime;

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'de_DE';
    initializeDateFormatting('de_DE');
    if (widget.dueDate != null) {
      _dateTime = widget.dueDate.toDate();
    }
  }

  void _removeDueDate() {
    setState(() {
      _dateTime = null;
      widget.databaseService.updateDueDate(widget.todoID, null);
    });
  }

  @override
  Widget build(BuildContext context) {
    var padding = MediaQuery.of(context).padding;
    var screenHeight = MediaQuery.of(context).size.height - (kToolbarHeight + padding.top);
    var screenWidth = MediaQuery.of(context).size.width;
    return Row(
      children: [
        Container(
          margin: EdgeInsets.only(top: 16),
          width: _dateTime != null ? screenWidth * 0.715 : screenWidth * 0.88,
          height: screenHeight * 0.09,
          color: Colors.grey[100],
          child: ButtonTheme(
            child: FlatButton(
              onPressed: () {
                showDatePicker(
                  helpText: 'Datum auswählen',
                  context: context,
                  initialDate: _dateTime == null ? DateTime.now() : _dateTime,
                  firstDate: DateTime(2003),
                  lastDate: DateTime(2119),
                ).then((value) {
                  setState(() {
                    _dateTime = value;
                    widget.databaseService.updateDueDate(widget.todoID, _dateTime);
                  });
                });
              },
              child: Row(
                children: [
                  _dateTime == null
                      ? Icon(
                          Icons.date_range,
                          size: 31,
                          color: Colors.grey[700],
                        )
                      : Icon(
                          Icons.date_range,
                          size: 31,
                          color: _dateTime.day == DateTime.now().day -1 || _dateTime.day < DateTime.now().day -1 ? Colors.red : Colors.lightBlue,
                        ),
                  SizedBox(
                    width: 8,
                  ),
                  _dateTime == null
                      ? Container(
                          margin: const EdgeInsets.only(left: 6),
                          child: Text(
                            'Fälligkeitsdatum hinzufügen',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : Container(
                          margin: const EdgeInsets.only(left: 6),
                          child: Text(
                            _format.format(_dateTime) ==
                                    _format.format(DateTime.now())
                                ? 'Fällig Heute'
                                : _dateTime.day == DateTime.now().day + 1
                                    ? 'Fällig Morgen'
                                    : _dateTime.day == DateTime.now().day -1 ? 'Fällig Gestern' : 'Fällig ' + _format.format(_dateTime).toString(),
                            style: TextStyle(
                              color: _dateTime.day == DateTime.now().day - 1 || _dateTime.day < DateTime.now().day -1 ? Colors.red : Colors.lightBlue,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
        if(_dateTime != null)
          Container(
            margin: EdgeInsets.fromLTRB(0, 16, 0, 0),
            width:  screenWidth * 0.165,
            height: screenHeight * 0.09,
            color: Colors.grey[100],
            child: IconButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: Icon(Icons.clear, size: 23, color: Colors.grey[700],),
              onPressed: _removeDueDate,
            ),
        ),
      ],
    );
  }
}
