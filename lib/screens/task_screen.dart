import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:todoapp/utils/list_utils.dart';

import '../models/todo.dart';
import '../models/user.dart';
import '../widgets/scroll_behavior.dart';
import '../widgets/todo_item.dart';
import '../widgets/sidebar/drawer.dart';
import '../services/todo_service.dart';
import '../services/local_notification_service.dart';

class TaskScreen extends StatefulWidget {
  final User user;
  final String list;

  TaskScreen(this.user, this.list);

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  TodoService _todoService;
  TextEditingController _controller = TextEditingController();
  FocusNode _inputField = FocusNode();
  bool _activateBtn = false;
  List<DocumentSnapshot> _docs;

  @override
  void initState() {
    super.initState();
    _inputField.unfocus();
    _todoService = TodoService(user: widget.user, list: widget.list);

    localNotificationService.setOnNotificationClick((payload) async {
      List<Todo> todos = _docs.map((doc) {
        return Todo.fromDocument(doc);
      }).toList();

      Todo todo = todos.where((todo) => todo.id == payload).single;

      Navigator.of(context).pushNamed('/details', arguments: {
        'todo': todo,
        'delete': () => delete(todo),
        'toggleDone': () => toggleDone(todo)
      });
    });
  }

  void addTodo(String title) {
    int index = _docs.length;
    _todoService.addTodo(Todo(title, widget.list, index));
  }

  void delete(Todo todo) => _todoService.deleteTodo(todo);

  void toggleDone(Todo todo) {
    todo.value = !todo.value;
    _todoService.updateTodo(todo);
  }

  @override
  Widget build(BuildContext context) {
    var padding = MediaQuery.of(context).padding;
    var screenHeight =
        MediaQuery.of(context).size.height - (kToolbarHeight + padding.top);
    var screenWidth = MediaQuery.of(context).size.width;
    if (MediaQuery.of(context).viewInsets.bottom == 0) _inputField.unfocus();
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
        drawer: Theme(
          data: ThemeData(
            canvasColor: Colors.white,
          ),
          child: Sidebar(widget.user),
        ),
        drawerEnableOpenDragGesture: true,
        body: ScrollConfiguration(
          behavior: CustomScrollBehavior(),
          child: SingleChildScrollView(
            child: Column(children: [
              Container(
                height: screenHeight * 0.9,
                child: StreamBuilder(
                  stream: _todoService.getTodos(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Container(
                        child: Center(
                          child: SpinKitFadingCircle(
                            color: Colors.black,
                            size: 44,
                          ),
                        ),
                      );
                    }

                    _docs = snapshot.data.documents;

                    List<Todo> todos = _docs.map((doc) {
                      return Todo.fromDocument(doc);
                    }).toList();

                    todos = ListUtils.multisort(todos, [true], ['value']);

                    List<TodoItem> todoItems = todos.map((todo) {
                      return TodoItem(
                        key: ValueKey(todo.id),
                        delete: () => delete(todo),
                        toggleDone: () => toggleDone(todo),
                        todo: todo,
                      );
                    }).toList();

                    return Container(
                      child: ScrollConfiguration(
                        behavior: CustomScrollBehavior(),
                        child: ReorderableListView(
                          onReorder: (oldIndex, newIndex) {
                            if (oldIndex < newIndex) newIndex -= 1;
                            todoItems.insert(
                                newIndex, todoItems.removeAt(oldIndex));
                            _docs.insert(newIndex, _docs.removeAt(oldIndex));
                            final batch = FirebaseFirestore.instance.batch();
                            for (int i = 0; i < _docs.length; i++) {
                              batch.update(_docs[i].reference, {'index': i});
                            }
                            batch.commit();
                          },
                          children: todoItems,
                        ),
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
                        focusNode: _inputField,
                        cursorColor: Colors.black54,
                        cursorWidth: 1,
                        autofocus: false,
                        controller: _controller,
                        onFieldSubmitted: (value) {
                          if (value != '' && value != null) {
                            setState(() {
                              addTodo(value);
                              _controller.clear();
                              _activateBtn = false;
                              _inputField.unfocus();
                            });
                          }
                        },
                        onChanged: (value) {
                          if (value != '') {
                            setState(() {
                              _activateBtn = true;
                            });
                          } else {
                            setState(() {
                              _activateBtn = false;
                            });
                          }
                        },
                        onEditingComplete: () => _inputField.unfocus(),
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
                      margin: EdgeInsets.only(left: 4),
                      child: CircleAvatar(
                        backgroundColor:
                            _activateBtn ? Colors.lightBlue : Colors.grey,
                        radius: 21,
                        child: Center(
                          child: IconButton(
                            splashColor: Colors.transparent,
                            onPressed: () {
                              String value = _controller.text;
                              if (value != '' && value != null) {
                                setState(() {
                                  addTodo(value);
                                  _controller.clear();
                                  _inputField.unfocus();
                                  _activateBtn = false;
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
      ),
    );
  }
}
