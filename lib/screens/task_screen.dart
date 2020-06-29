import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:todoapp/models/todo.dart';
import 'package:todoapp/models/user.dart';
import 'package:todoapp/widgets/todo_item.dart';
import '../widgets/sidebar/drawer.dart';
import 'package:todoapp/services/database_service.dart';

class TaskScreen extends StatefulWidget {
  final User user;
  final String list;

  TaskScreen(this.user, this.list);

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  DatabaseService databaseService;
  Stream<QuerySnapshot> dataStream;
  TextEditingController _controller = TextEditingController();
  FocusNode inputField = FocusNode();
  bool activateBtn = false;

  @override
  void initState() {
    super.initState();
    databaseService = DatabaseService(widget.user.uid, list: widget.list);
    dataStream = databaseService.getTodos();
  }

  void addTodo(String title) {
    Todo todo = new Todo(title);
    databaseService.addTodo(todo);
  }

  void delete(String id) {
    databaseService.deleteTodo(id);
  }

  void toggleDone(String id, bool value) {
    databaseService.toggleDone(id, value);
  }

  @override
  Widget build(BuildContext context) {
    var padding = MediaQuery.of(context).padding;
    var screenHeight =
        MediaQuery.of(context).size.height - (kToolbarHeight + padding.top);
    var screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            widget.list.toUpperCase(),
            style: TextStyle(
              color: Colors.black,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        drawer: Sidebar(widget.user),
        drawerEnableOpenDragGesture: true,
        body: SingleChildScrollView(
          child: Column(children: [
            Container(
              height: screenHeight * 0.9,
              child: StreamBuilder(
                stream: dataStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      !snapshot.hasData) {
                    return Container(
                      child: Center(
                        child: SpinKitFadingCircle(
                          color: Colors.lightBlue,
                          size: 44,
                        ),
                      ),
                    );
                  }
                  List<DocumentSnapshot> todos = snapshot.data.documents;
                  return Container(
                    child: ListView.builder(
                      itemCount: todos.length,
                      itemBuilder: (context, index) {
                        return TodoItem(
                          key: ValueKey(todos[index].documentID),
                          id: todos[index].documentID,
                          title: todos[index]['title'],
                          done: todos[index]['value'],
                          delete: () => delete(todos[index].documentID),
                          toggleDone: () => toggleDone(todos[index].documentID, todos[index]['value']),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            Container(
              height: screenHeight * 0.1,
              color: Colors.grey[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                    child: TextFormField(
                      focusNode: inputField,
                      cursorColor: Colors.black54,
                      cursorWidth: 1,
                      autofocus: false,
                      controller: _controller,
                      onFieldSubmitted: (value) {
                        if (value != '' && value != null) {
                          setState(() {
                            addTodo(value);
                            _controller.clear();
                            activateBtn = false;
                            inputField.unfocus();
                          });
                        }
                      },
                      onChanged: (value) {
                        if (value != '') {
                          setState(() {
                            activateBtn = true;
                          });
                        } else {
                          setState(() {
                            activateBtn = false;
                          });
                        }
                      },
                      onEditingComplete: () => inputField.unfocus(),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Schnell einfügen...',
                        hintStyle: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Colors.black54,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Colors.black54,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                    width: screenWidth * 0.8,
                    height: screenHeight * 0.07,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 5),
                    child: CircleAvatar(
                      backgroundColor:
                          activateBtn ? Colors.lightBlue : Colors.grey,
                      radius: 21,
                      child: Center(
                        child: IconButton(
                          onPressed: () {
                            String value = _controller.text;
                            if (value != '' && value != null) {
                              setState(() {
                                addTodo(value);
                                _controller.clear();
                                inputField.unfocus();
                                activateBtn = false;
                              });
                            }
                          },
                          padding: EdgeInsets.only(bottom: 1),
                          icon: Icon(
                            Icons.arrow_upward,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    width: screenWidth * 0.15,
                    height: screenHeight * 0.07,
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}