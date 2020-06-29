import 'package:flutter/material.dart';

class TodoDetailsScreen extends StatelessWidget {
  final TextEditingController _titleController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    _titleController.text = 'wadawd';
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            'Aufgabendetails'.toUpperCase(),
            style: TextStyle(
              fontSize: 17,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          elevation: 0,
        ),
        body: Column(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(22, 10, 0, 10),
              child: Row(
                children: [
                  Container(
                    width: 280,
                    child: TextField(
                      cursorColor: Colors.black,
                      controller: _titleController,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 31,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Ich möchte...',
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
}
