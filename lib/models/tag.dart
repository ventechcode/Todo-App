import 'package:flutter/material.dart';

/// Represents a Tag from a Todo Item
class Tag {
  String _name;
  String _colorString;
  bool active;
  bool editing;
  FocusNode? focusNode;

  Tag(this._name, this._colorString, this.active) : editing = false, focusNode = FocusNode();

  Tag.fromDocument(Map<String, dynamic> tag) :
    this._name = tag['name'],
    this._colorString = tag['colorString'],
    this.active = tag['active'],
    this.editing = false,
    this.focusNode = FocusNode();
  
  Map<String, dynamic> toDocument() =>
      {'name': name, 'colorString': colorString, 'active': active};

  String get name => _name;
  String get colorString => _colorString;

  set name(String value) {
    if (value.isNotEmpty) {
      _name = value;
    }
  }

  set colorString(String value) {
    if (value.isNotEmpty) {
      _colorString = value;
    }
  }
}