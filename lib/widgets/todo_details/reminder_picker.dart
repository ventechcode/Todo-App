import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../services/database_service.dart';

class ReminderPicker extends StatefulWidget {
  final DatabaseService databaseService;
  final Timestamp notificationDate;
  final String todoID;

  ReminderPicker({this.todoID, this.notificationDate, this.databaseService});

  @override
  _ReminderPickerState createState() => _ReminderPickerState();
}

class _ReminderPickerState extends State<ReminderPicker> {
  final DateFormat _dateFormat = DateFormat('EE, d. MMMM');
  DateTime _dateTime;
  DateTime _notificationDate;
  TimeOfDay _notificationTime;

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'de_DE';
    initializeDateFormatting('de_DE');
    if (widget.notificationDate != null) {
      _notificationDate = widget.notificationDate.toDate();
      _notificationTime = TimeOfDay(
        hour: _notificationDate.hour,
        minute: _notificationDate.minute,
      );
    }
  }

  double toDouble(TimeOfDay timeOfDay) {
    return timeOfDay.hour + timeOfDay.minute / 60.0;
  }

  @override
  Widget build(BuildContext context) {
    var padding = MediaQuery.of(context).padding;
    var screenHeight =
        MediaQuery.of(context).size.height - (kToolbarHeight + padding.top);
    var screenWidth = MediaQuery.of(context).size.width;
    return Row(
      children: [
        Container(
          margin: EdgeInsets.only(top: 16),
          width: _notificationDate != null && _notificationTime != null
              ? screenWidth * 0.715
              : screenWidth * 0.88,
          height: screenHeight * 0.09,
          color: Colors.grey[100],
          child: ButtonTheme(
            child: FlatButton(
              onPressed: () {
                showDatePicker(
                  helpText: 'Datum auswählen',
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2119),
                ).then((value) {
                  if (value != null) {
                    _notificationDate = value;
                    showTimePicker(
                      helpText: 'Uhrzeit auswählen',
                      initialTime: TimeOfDay.now(),
                      context: context,
                    ).then((value) {
                      if (value != null) {
                        setState(() {
                          _notificationTime = value;
                          _dateTime = DateTime(
                            _notificationDate.year,
                            _notificationDate.month,
                            _notificationDate.day,
                            _notificationTime.hour,
                            _notificationTime.minute,
                          );
                          widget.databaseService
                              .updateReminderDate(widget.todoID, _dateTime);
                        });
                      }
                    });
                  }
                });
              },
              child: Row(
                children: [
                  _notificationDate == null || _notificationTime == null
                      ? Icon(
                          Icons.notifications,
                          size: 31,
                          color: Colors.grey[700],
                        )
                      : Icon(
                          Icons.notifications,
                          size: 31,
                          color: toDouble(_notificationTime) <
                                      toDouble(TimeOfDay.now()) &&
                                  DateTime.now().isAfter(_notificationDate)
                              ? Colors.grey[700]
                              : Colors.lightBlue,
                        ),
                  SizedBox(
                    width: 8,
                  ),
                  _notificationDate == null || _notificationTime == null
                      ? Container(
                          margin: const EdgeInsets.only(left: 6),
                          child: Text(
                            'Erinnerung hinzufügen',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : Container(
                          margin: const EdgeInsets.only(left: 6),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Erinnerung um ' +
                                    _notificationTime.format(context),
                                style: TextStyle(
                                  color: toDouble(_notificationTime) <
                                              toDouble(TimeOfDay.now()) &&
                                          DateTime.now()
                                              .isAfter(_notificationDate)
                                      ? Colors.grey[700]
                                      : Colors.lightBlue,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 5),
                              Container(
                                margin: const EdgeInsets.only(left: 0.5),
                                child: Text(
                                  _dateFormat.format(_notificationDate) ==
                                          _dateFormat.format(DateTime.now())
                                      ? 'Heute'
                                      : _notificationDate.day ==
                                              DateTime.now().day + 1
                                          ? 'Morgen'
                                          : _notificationDate.day ==
                                                  DateTime.now().day - 1
                                              ? 'Gestern'
                                              : _dateFormat
                                                  .format(_notificationDate),
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
        if (_notificationDate != null && _notificationTime != null)
          Container(
            margin: EdgeInsets.fromLTRB(0, 16, 0, 0),
            width: screenWidth * 0.165,
            height: screenHeight * 0.09,
            color: Colors.grey[100],
            child: IconButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: Icon(
                Icons.clear,
                size: 23,
                color: Colors.grey[700],
              ),
              onPressed: () {
                setState(() {
                  _dateTime = null;
                  _notificationDate = null;
                  _notificationTime = null;
                  widget.databaseService
                      .updateReminderDate(widget.todoID, null);
                });
              },
            ),
          ),
      ],
    );
  }
}
