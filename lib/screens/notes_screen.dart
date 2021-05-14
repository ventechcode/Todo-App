import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:todoapp/widgets/scroll_behavior.dart';

class NotesScreen extends StatefulWidget {
  final Map? data;
  NotesScreen(this.data);

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late bool _showImg;

  @override
  void initState() {
    super.initState();
    if (widget.data!['todo'].notes == null || widget.data!['todo'].notes == '') {
      _showImg = true;
    } else {
      _showImg = false;
      _controller.text = widget.data!['todo'].notes;
    }

    KeyboardVisibilityController().onChange.listen((bool visible) {
      if(!visible) {
        _focusNode.unfocus();
        widget.data!['todo'].notes = _controller.text;
        widget.data!['todoService'].updateTodo(widget.data!['todo']);
        if (_controller.text.length < 1) setState(() => _showImg = true);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            color: Colors.black,
            onPressed: () => Navigator.pop(context, _controller.text),
          ),
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            widget.data!['todo'].title,
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
        body: WillPopScope(
          onWillPop: () async {
            Navigator.pop(context, _controller.text);
            return true;
          },
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(21, 0, 21, 12),
                child: Container(
                  height: screenHeight,
                  width: screenWidth,
                  child: ScrollConfiguration(
                    behavior: CustomScrollBehavior(),
                    child: TextFormField(
                      expands: true,
                      autofocus: false,
                      cursorWidth: 1.5,
                      style: TextStyle(height: 1.2),
                      focusNode: _focusNode,
                      controller: _controller,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      cursorColor: Colors.black54,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                      onTap: () {
                        setState(() {
                          _showImg = false;
                        });
                      },
                    ),
                  ),
                ),
              ),
              if (_showImg)
                Center(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _focusNode.requestFocus();
                        _showImg = false;
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
      ),
    );
  }
}
