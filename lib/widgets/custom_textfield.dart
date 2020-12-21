import 'package:flutter/material.dart';
import 'package:todoapp/fieldtype.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String lblText;
  final FieldType fieldType;
  final Icon suffixIcon;
  final TextInputType keyboardType;
  final FocusNode focusNode;

  CustomTextField({
    this.lblText,
    this.suffixIcon,
    this.fieldType,
    this.controller,
    this.keyboardType,
    this.focusNode,
  });

  String get content {
    return controller.text;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 12),
      height: MediaQuery.of(context).size.height * 0.078,
      width: MediaQuery.of(context).size.width * 0.8,
      child: TextFormField(
        autofocus: false,
        focusNode: focusNode,
        controller: controller,
        obscureText: fieldType == FieldType.PASSWORD ? true : false,
        cursorColor: Colors.black,
        cursorWidth: 1,
        keyboardType: keyboardType,
        textInputAction:
        fieldType == FieldType.PASSWORD ? TextInputAction.done : TextInputAction.next,
        onFieldSubmitted: (_) =>
        fieldType != FieldType.PASSWORD ? FocusScope.of(context).nextFocus() : null,
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.red[600],
              style: BorderStyle.solid,
              width: 1,
            ),
          ),
          filled: true,
          suffixIcon: suffixIcon,
          labelText: lblText,
          labelStyle: TextStyle(
            fontSize: 15,
            color: Colors.black,
          ),
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3),
            borderSide: BorderSide(
              color: Colors.black,
              width: 1.87,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3),
            borderSide: BorderSide(
              color: Colors.black,
              width: 1.87,
            ),
          ),
        ),
      ),
    );
  }
}
