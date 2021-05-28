import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:todoapp/models/choice.dart';
import 'package:todoapp/models/sorting_criteria.dart';

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
  late TodoService _todoService;
  TextEditingController _controller = TextEditingController();
  FocusNode _inputField = FocusNode();
  bool _activateBtn = false;
  List<DocumentSnapshot>? _docs;
  SortingCriteria? currentSortingCriteria;

  List<Choice> choices = [
    Choice(
      text: 'Sortieren nach',
      icon: Icon(Icons.sort_rounded),
    ),
    Choice(
      text: 'Liste umbenennen',
      icon: Icon(Icons.edit_outlined),
    ),
    Choice(
      text: 'Liste löschen',
      icon: Icon(Icons.delete_outline_rounded),
    ),
  ];

  List<SortingCriteria> sortingCriterias = [
    SortingCriteria(
      'Wichtigkeit',
      'priority',
      false,
      Icon(
        Icons.star_border_rounded,
        size: 26,
        color: Colors.grey[600],
      ),
      'Nach Wichtigkeit sortiert',
    ),
    SortingCriteria(
      'Fälligkeitsdatum',
      'dueDate',
      true,
      Icon(
        Icons.calendar_today_rounded,
        size: 26,
        color: Colors.grey[600],
      ),
      'Nach Fälligkeitsdatum sortiert',
    ),
    SortingCriteria(
      'Alphabetisch',
      'title',
      true,
      Icon(
        Icons.sort_by_alpha_rounded,
        size: 26,
        color: Colors.grey[600],
      ),
      'Alphabetisch sortiert',
    ),
    SortingCriteria(
      'Erstellungsdatum',
      'createdAt',
      false,
      Icon(
        Icons.more_time_rounded,
        size: 26,
        color: Colors.grey[600],
      ),
      'Nach Erstellungsdatum sortiert',
    )
  ];

  @override
  void initState() {
    super.initState();
    _inputField.unfocus();
    _todoService = TodoService(user: widget.user, list: widget.list);

    localNotificationService.setOnNotificationClick((payload) async {
      List<Todo> todos = _docs!.map((doc) {
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
    int index = _docs!.length;
    _todoService.addTodo(Todo(title, widget.list, index));
  }

  void delete(Todo todo) => _todoService.deleteTodo(todo);

  void toggleDone(Todo todo) {
    todo.value = !todo.value;
    _todoService.updateTodo(todo);
  }

  void _onChoiceSelected(Choice choice) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    if (choice.text == 'Sortieren nach') {
      showModalBottomSheet(
        context: context,
        builder: (context) => Container(
          color: Colors.transparent,
          height: screenHeight * 0.44,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    height: 6,
                    width: 30,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(16, 25, 0, 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Sortieren nach',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                for (SortingCriteria criteria in sortingCriterias)
                  Container(
                    width: screenWidth,
                    height: screenHeight * 0.0825,
                    child: TextButton.icon(
                      style: ButtonStyle(
                        alignment: Alignment.centerLeft,
                        overlayColor:
                            MaterialStateProperty.all(Colors.grey[300]),
                      ),
                      onPressed: () {
                        setState(() {
                          currentSortingCriteria = criteria;
                        });
                        Navigator.of(context).pop();
                      },
                      label: Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Text(
                          criteria.name,
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                      icon: Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: criteria.icon,
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
          actions: [
            PopupMenuButton(
                onSelected: _onChoiceSelected,
                itemBuilder: (BuildContext context) => choices
                    .map((Choice choice) => PopupMenuItem<Choice>(
                          child: Row(
                            children: [
                              choice.icon,
                              SizedBox(width: 15),
                              Text(choice.text),
                            ],
                          ),
                          value: choice,
                        ))
                    .toList())
          ],
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
            child: Column(
              children: [
                if (currentSortingCriteria != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(7, 0, 7, 0),
                        width: screenWidth * 0.83,
                        height: screenHeight * 0.06,
                        child: TextButton(
                          style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all(Colors.lightBlue),
                            overlayColor:
                                MaterialStateProperty.all(Colors.grey[100]),
                          ),
                          onPressed: () {
                            setState(() {
                              currentSortingCriteria!.ascending =
                                  !currentSortingCriteria!.ascending;
                            });
                          },
                          child: Row(
                            children: [
                              Text(currentSortingCriteria!.displayText),
                              SizedBox(width: 3),
                              Icon(currentSortingCriteria!.ascending
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: screenHeight * 0.06,
                        width: screenWidth * 0.1,
                        child: TextButton(
                          style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all(Colors.lightBlue),
                            overlayColor:
                                MaterialStateProperty.all(Colors.grey[100]),
                          ),
                          onPressed: () {
                            setState(() {
                              currentSortingCriteria = null;
                            });
                          },
                          child: Icon(
                            Icons.clear_rounded,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                Container(
                  height: currentSortingCriteria == null
                      ? screenHeight * 0.9
                      : screenHeight * 0.84,
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

                      _docs = (snapshot.data! as QuerySnapshot).docs;

                      List<Todo> todos = _docs!.map((doc) {
                        return Todo.fromDocument(doc);
                      }).toList();

                      if (currentSortingCriteria != null) {
                        if (currentSortingCriteria!.property == 'dueDate') {

                          var temp = todos
                              .where((element) => element.dueDate != null)
                              .toList();
                          
                          temp.sort((a, b) {
                            if (a
                                    .get(currentSortingCriteria!.property)
                                    .compareTo(b.get(
                                        currentSortingCriteria!.property)) ==
                                0)
                              return 0;
                            else if (a
                                    .get(currentSortingCriteria!.property)
                                    .compareTo(b.get(
                                        currentSortingCriteria!.property)) ==
                                1)
                              return currentSortingCriteria!.ascending ? 1 : -1;
                            else
                              return currentSortingCriteria!.ascending ? -1 : 1;
                          });

                          for(var todo in temp) {
                            todos.remove(todo);
                          }

                          todos.insertAll(0, temp);
                          
                        } else {
                          todos.sort((a, b) {
                            if (a
                                    .get(currentSortingCriteria!.property)
                                    .compareTo(b.get(
                                        currentSortingCriteria!.property)) ==
                                0)
                              return 0;
                            else if (a
                                    .get(currentSortingCriteria!.property)
                                    .compareTo(b.get(
                                        currentSortingCriteria!.property)) ==
                                1)
                              return currentSortingCriteria!.ascending ? 1 : -1;
                            else
                              return currentSortingCriteria!.ascending ? -1 : 1;
                          });
                        }
                      }

                      todos.sort((a, b) {
                        if (a.get('value').compareTo(b.get('value')) == 0)
                          return 0;
                        else if (a.get('value').compareTo(b.get('value')) == 1)
                          return 1;
                        else
                          return -1;
                      });

                      for (Todo todo in todos) {
                        todo.index = todos.indexOf(todo);
                        _todoService.updateTodo(todo);
                      }

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
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              canvasColor: Colors.transparent,
                              shadowColor: Colors.grey.withOpacity(0.36),
                            ),
                            child: ReorderableListView(
                              onReorder: (oldIndex, newIndex) {
                                if (oldIndex < newIndex) newIndex -= 1;
                                todoItems.insert(
                                    newIndex, todoItems.removeAt(oldIndex));
                                _docs!.insert(
                                    newIndex, _docs!.removeAt(oldIndex));
                                final batch =
                                    FirebaseFirestore.instance.batch();
                                for (int i = 0; i < _docs!.length; i++) {
                                  batch.update(
                                      _docs![i].reference, {'index': i});
                                }
                                batch.commit();
                              },
                              children: todoItems,
                            ),
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
                          cursorColor: Colors.grey[800],
                          cursorWidth: 1.25,
                          autofocus: false,
                          controller: _controller,
                          onFieldSubmitted: (String? value) {
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
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 17,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Aufgabe hinzufügen...',
                            hintStyle: TextStyle(
                              color: Colors.black54,
                              fontSize: 17,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 16),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: Colors.grey,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
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
                                if (value != '') {
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}