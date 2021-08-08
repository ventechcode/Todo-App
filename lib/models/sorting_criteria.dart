import 'package:flutter/material.dart';

class SortingCriteria {
  final String name;
  final String property;
  final IconData icon;
  final String displayText;
  bool ascending;

  SortingCriteria(this.name, this.property, this.ascending, this.icon, this.displayText);
}