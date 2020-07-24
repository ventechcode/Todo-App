import 'package:flutter/material.dart';
import 'package:todoapp/services/database_service.dart';

class NotesScreen extends StatefulWidget {
  final Map data;
  NotesScreen(this.data);

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.data['notes'];
  }

  @override
  Widget build(BuildContext context) {
    final Map data = ModalRoute.of(context).settings.arguments;
    var padding = MediaQuery.of(context).padding;
    var screenHeight = MediaQuery.of(context).size.height - (kToolbarHeight + padding.top);
    var screenWidth = MediaQuery.of(context).size.width;
    if(MediaQuery.of(context).viewInsets.bottom == 0) _focusNode.unfocus();
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            widget.data['title'],
            style: TextStyle(
              color: Colors.black,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(21, 0, 21, 0),
          child: Container(
            height: screenHeight,
            width: screenWidth,
            child: TextField(
              focusNode: _focusNode,
              autofocus: false,
              controller: _controller,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              cursorColor: Colors.black,
              decoration: InputDecoration(
                border: InputBorder.none,
              ),
              onChanged: (value) {
                widget.data['db_service'].updateNotes(widget.data['todoId'], value);
              },
            ),
          ),
        ),
      ),
    );
  }
}