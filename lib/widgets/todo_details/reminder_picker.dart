import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:todoapp/services/local_notification_service.dart';
import 'package:todoapp/services/todo_service.dart';
import 'package:todoapp/models/todo.dart';

class ReminderPicker extends StatefulWidget {
  final Todo? todo;
  final TodoService? todoService;
  final String? uid;

  ReminderPicker({this.todo, this.uid, this.todoService});

  @override
  _ReminderPickerState createState() => _ReminderPickerState();
}

class _ReminderPickerState extends State<ReminderPicker> {
  final DateFormat _dateFormat = DateFormat('EE, d. MMMM');
  DateTime? _dateTime;

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'de_DE';
    initializeDateFormatting('de_DE');
    _dateTime = widget.todo!.reminderDate;
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
          width: _dateTime != null && _dateTime != null
              ? screenWidth * 0.715
              : screenWidth * 0.88,
          height: screenHeight * 0.09,
          color: Colors.grey[100],
          child: ButtonTheme(
            child: TextButton(
              onPressed: () {
                showDatePicker(
                  helpText: 'Datum auswählen',
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2119),
                ).then((value) {
                  if (value != null) {
                    _dateTime = value;
                    showTimePicker(
                      helpText: 'Uhrzeit auswählen',
                      initialTime: TimeOfDay.now(),
                      context: context,
                    ).then((value) async {
                      if (value != null) {
                        setState(() {
                          _dateTime = DateTime(_dateTime!.year, _dateTime!.month, _dateTime!.day, value.hour, value.minute);
                          widget.todo!.reminderDate = _dateTime;
                          widget.todoService!.updateTodo(widget.todo!);                         
                        });
                        await localNotificationService.scheduleNotification(widget.todo!, _dateTime!);
                      }
                    });
                  }
                });
              },
              child: Row(
                children: [
                  _dateTime == null
                      ? Icon(
                          Icons.notifications,
                          size: 31,
                          color: Colors.grey[700],
                        )
                      : Icon(
                          Icons.notifications,
                          size: 31,
                          color: DateTime.now().isAfter(_dateTime!)
                              ? Colors.grey[700]
                              : Colors.lightBlue,
                        ),
                  SizedBox(
                    width: 8,
                  ),
                  _dateTime == null 
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
                                    TimeOfDay(hour: _dateTime!.hour, minute: _dateTime!.minute).format(context) + ' Uhr',
                                style: TextStyle(
                                  color: DateTime.now().isAfter(_dateTime!)
                                      ? Colors.grey[700]
                                      : Colors.lightBlue,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 3.5),
                              Container(
                                margin: const EdgeInsets.only(left: 0.5),
                                child: Text(
                                  _dateFormat.format(_dateTime!) ==
                                          _dateFormat.format(DateTime.now())
                                      ? 'Heute'
                                      : _dateTime!.day == DateTime.now().day + 1 && _dateTime!.month == DateTime.now().month && _dateTime!.year == DateTime.now().year
                                          ? 'Morgen'
                                          : _dateTime!.day == DateTime.now().day - 1 && _dateTime!.month == DateTime.now().month && _dateTime!.year == DateTime.now().year
                                              ? 'Gestern'
                                              : _dateFormat
                                                  .format(_dateTime!),
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
        if (_dateTime != null)
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
              onPressed: () async {
                setState(() {
                  _dateTime = null;
                  widget.todo!.reminderDate = _dateTime;
                  widget.todoService!.updateTodo(widget.todo!);                 
                });
                await localNotificationService.cancelNotification(widget.todo!);
              },
            ),
          ),
      ],
    );
  }
}