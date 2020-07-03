import 'package:uuid/uuid.dart';

class Todo {
  final String _id = new Uuid().v1();
  final String _title;
  bool _value = false;

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

  void setValue(bool newValue) {
    this._value = newValue;
  }
}