import 'package:flutter/material.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NotesScreen extends StatefulWidget {
  final Map data;
  NotesScreen(this.data);

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool showImg;

  @override
  void initState() {
    super.initState();
    if (widget.data['notes'] == null || widget.data['notes'] == '') {
      showImg = true;
    } else {
      showImg = false;
      _controller.text = widget.data['notes'];
    }
    KeyboardVisibilityNotification().addNewListener(onChange: (visible) {
      if (!visible) {
        _focusNode.unfocus();
        widget.data['db_service'].updateNotes(widget.data['todoId'], _controller.text);
        if(_controller.text.length < 1) setState(() => showImg = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var padding = MediaQuery.of(context).padding;
    var screenHeight =
        MediaQuery.of(context).size.height - (kToolbarHeight + padding.top);
    var screenWidth = MediaQuery.of(context).size.width;
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
        body: Stack(
          children: [
            Padding(
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
                  onTap: () {
                    setState(() {
                      showImg = false;
                    });
                  },
                ),
              ),
            ),
            if (showImg)
              Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _focusNode.requestFocus();
                      showImg = false;
                    });
                  },
                  child: Container(
                    child: SvgPicture.asset(
                      'assets/images/notes.svg',
                      width: screenWidth * 0.88,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
