import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:todoapp/models/todo.dart';
import 'package:todoapp/models/user.dart';
import '../widgets/sidebar/drawer.dart';
import 'package:todoapp/widgets/todo_item.dart';
import 'package:todoapp/services/database_service.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  HomeScreen(this.user);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User user;
  DatabaseService databaseService;
  List<dynamic> todos = List<dynamic>();
  List<dynamic> doneTodos = List<dynamic>();
  TextEditingController _controller = TextEditingController();
  FocusNode inputField = FocusNode();

  bool activateBtn = false;
  bool initializedData = false;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeData(user.userID).whenComplete(() {
        print('Initialized Data From Backend Storage');
        print(todos.toString());
      });
    });
  }

  Future<void> initializeData(String uid) async {
    databaseService = DatabaseService(uid);
    DocumentSnapshot userData = await databaseService.getUserData();
    if(userData.data != null) {
      user.username = userData.data['username'];
    } else {
      await initializeData(uid);
    }
    DocumentSnapshot snapshot = await databaseService.getTodos('all_tasks');
    if(snapshot.data != null) {
      todos = snapshot.data['todos'];
      todos.forEach((todo) {
        if(todo['value'] == true) {
          doneTodos.add(todo);
        }
      });
      setState(() => initializedData = true);
    } else {
      await initializeData(uid);
    }
  }

  void delete(String id) {
    setState(() {
      todos.removeWhere((todo) => todo['id'] == id);
      doneTodos.removeWhere((todo) => todo['id'] == id);
    });
    databaseService.updateTodos(todos);
  }

  void addTodo(String title) {
    setState(() {
      Todo todo = new Todo(title);
      final map = {
        'id': todo.id,
        'title': todo.title,
        'value': todo.done,
        'createdAt': Timestamp.now(),
      };
      todos.insert(0, map);
    });
    databaseService.updateTodos(todos);
  }

  void toggleDone(String id) {
    var item;
    var removeIndex;
    var checked;
    for (int i = 0; i < todos.length; i++) {
      if (todos[i]['id'] == id) {
        setState(() {
          todos[i]['value'] = !todos[i]['value'];
          if (!todos[i]['value'] == false) {
            checked = true;
            item = todos[i];
            doneTodos.add(todos[i]);
            removeIndex = i;
          } else if (!todos[i]['value'] == true) {
            checked = false;
            doneTodos.removeWhere((element) => element['id'] == todos[i]['id']);
            final temp = todos.removeAt(i);
            todos.insert(0, temp);
          }
        });
      }
    }
    setState(() {
      if (checked) {
        todos.removeAt(removeIndex);
        print(todos.length);
        print(doneTodos.length);
        todos.insert((todos.length - doneTodos.length) + 1, item);
      }
    });
    databaseService.updateTodos(todos);
  }

  @override
  Widget build(BuildContext context) {
    var padding = MediaQuery.of(context).padding;
    var screenHeight = MediaQuery.of(context).size.height - (kToolbarHeight + padding.top);
    var screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            'Alle Aufgaben'.toUpperCase(),
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
        drawer: Sidebar(user),
        drawerEnableOpenDragGesture: true,
        body: SingleChildScrollView(
          child: Column(children: [
            initializedData
                ? Container(
              height: screenHeight * 0.9,
              color: Colors.white,
              child: ReorderableListView(
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final item = todos.removeAt(oldIndex);
                    todos.insert(newIndex, item);
                    databaseService.updateTodos(todos);
                  });
                },
                children: [
                  for (int i = 0; i < todos.length; i++)
                    TodoItem(
                      key: ValueKey(todos[i]['id']),
                      id: todos[i]['id'],
                      title: todos[i]['title'],
                      delete: () => delete(todos[i]['id']),
                      toggleDone: () => toggleDone(todos[i]['id']),
                      done: todos[i]['value'],
                    ),
                ],
              ),
            )
                : Container(
              height: screenHeight * 0.9,
              color: Colors.white,
              child: SpinKitFadingCircle(
                color: Colors.lightBlue,
                size: 44,
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