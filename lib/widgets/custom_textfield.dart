import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String lblText;
  final int fieldType; // 1: username, 2: email, 3: password
  final Icon suffixIcon;
  final TextInputType keyboardType;

  CustomTextField({
    this.lblText,
    this.suffixIcon,
    this.fieldType,
    this.controller,
    this.keyboardType,
  });

  String get content {
    return controller.text;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      height: MediaQuery.of(context).size.height * 0.078,
      width: MediaQuery.of(context).size.width * 0.75,
      child: TextFormField(
        autofocus: false,
        controller: controller,
        obscureText: fieldType == 3 ? true : false,
        cursorColor: Colors.white,
        cursorWidth: 1,
        keyboardType: keyboardType,
        textInputAction:
        fieldType == 3 ? TextInputAction.done : TextInputAction.next,
        onFieldSubmitted: (_) =>
        fieldType != 3 ? FocusScope.of(context).nextFocus() : null,
        style: TextStyle(
          color: Colors.white,
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
            fontSize: 14,
            color: Colors.white,
          ),
          fillColor: Color.fromRGBO(43, 43, 43, 1),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3),
            borderSide: BorderSide(
              color: Colors.white,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3),
            borderSide: BorderSide(
              color: Colors.white,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
