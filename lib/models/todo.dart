import 'package:uuid/uuid.dart';

class Todo {
  final String _id = new Uuid().v1();
  final String _title;
  DateTime _dueDate;
  DateTime _reminderDate;
  bool _value = false;
  bool _priority = false;
  String _notes = '';

  Todo(
    this._title,
  );

  String get id {
    return _id;
  }

  String get title {
    return _title;
  }

  bool get value {
    return _value;
  }

  bool get priority {
    return _priority;
  }

  DateTime get dueDate {
    return _dueDate;
  }

  DateTime get reminderDate {
    return _reminderDate;
  }

  String get notes {
    return _notes;
  }

  void setValue(bool newValue) {
    this._value = newValue;
  }

  void setNotes(String notes) {
    this._notes = notes;
  }

  void setPriority(bool priority) {
    this._priority = priority;
  }

  void setDueDate(DateTime date) {
    this._dueDate = date;
  }

  void setReminderDate(DateTime date) {
    this._reminderDate = date;
  }
}