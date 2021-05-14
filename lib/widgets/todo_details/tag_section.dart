import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:todoapp/models/todo.dart';
import 'package:todoapp/services/todo_service.dart';
import 'package:todoapp/widgets/scroll_behavior.dart';
import 'package:todoapp/widgets/todo_details/tag.dart';

class TagSection extends StatefulWidget {
  final Todo? todo;
  final TodoService? todoService;

  TagSection({this.todo, this.todoService});

  @override
  _TagSectionState createState() => _TagSectionState();
}

class _TagSectionState extends State<TagSection> {
  @override
  void initState() {
    super.initState();
    KeyboardVisibilityController().onChange.listen((bool visible) {
      if (!visible) {
        setState(() {
          for (var tag in widget.todo!.tags) {
            tag.editing = false;
            tag.focusNode!.unfocus();
          }
        });
      }
    });
  }

  void _showTagsDialog(BuildContext ctx) {
    showModalBottomSheet(
      isScrollControlled: false,
      context: ctx,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, update) {
            return Container(
              padding:
                  EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                  ),
                ),
                child: ScrollConfiguration(
                  behavior: CustomScrollBehavior(),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
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
                        SizedBox(height: 10),
                        for (var tag in widget.todo!.tags)
                          Container(
                            color: Color(int.parse(tag.colorString)),
                            child: ListTile(
                              leading: Theme(
                                data: ThemeData(
                                    unselectedWidgetColor: Colors.white),
                                child: Checkbox(
                                  checkColor: Color(int.parse(tag.colorString)),
                                  activeColor: Colors.white,
                                  focusColor: Colors.white,
                                  hoverColor: Colors.white,
                                  onChanged: (val) async {
                                    setState(() {
                                      update(() {
                                        tag.active = val!;
                                      });
                                    });
                                    await widget.todoService!
                                        .updateTodo(widget.todo!);
                                  },
                                  value: tag.active,
                                ),
                              ),
                              title: GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    update(() {
                                      tag.active = !tag.active;
                                    });
                                  });
                                  await widget.todoService!
                                      .updateTodo(widget.todo!);
                                },
                                child: TextFormField(
                                  focusNode: tag.focusNode,
                                  enabled: tag.editing,
                                  cursorColor: Colors.white,
                                  initialValue: tag.name,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  onFieldSubmitted: (value) async {
                                    setState(() {
                                      update(() {
                                        tag.name = value;
                                        tag.editing = false;
                                        tag.focusNode!.unfocus();
                                      });
                                    });
                                    await widget.todoService!
                                        .updateTodo(widget.todo!);
                                  },
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  size: 26,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    update(() {
                                      tag.editing = true;
                                      tag.focusNode!.requestFocus();
                                    });
                                  });
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void removeTag(String name) async {
    setState(() {
      widget.todo!.tags.where((tag) => tag.name == name).single.active = false;
    });
    await widget.todoService!.updateTodo(widget.todo!);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tags',
            style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontFamily: 'Nexa'),
          ),
          Container(
            margin: EdgeInsets.only(top: 12),
            child: Wrap(
              children: [
                for (var tag in widget.todo!.tags)
                  if (tag.active)
                    Tag(tag.name, Color(int.parse(tag.colorString)),
                        () => removeTag(tag.name)),
                widget.todo!.tags.every((tag) => tag.active == true)
                    ? Container()
                    : Container(
                        margin: EdgeInsets.fromLTRB(0, 1.25, 0, 9),
                        child: GestureDetector(
                          onTap: () => _showTagsDialog(context),
                          child: DottedBorder(
                            radius: Radius.circular(20),
                            dashPattern: [4, 3],
                            strokeCap: StrokeCap.round,
                            strokeWidth: 0.88,
                            borderType: BorderType.RRect,
                            color: Colors.grey,
                            child: Container(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(6, 2.5, 6, 2.75),
                                child: Text(
                                  'Tag hinzufügen',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
