import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:todoapp/services/database_service.dart';
import 'package:todoapp/widgets/todo_details/tag.dart';

class TagSection extends StatefulWidget {
  final DatabaseService databaseService;
  final String todoId;

  TagSection(this.databaseService, this.todoId);

  @override
  _TagSectionState createState() => _TagSectionState();
}

class _TagSectionState extends State<TagSection> {
  Map<String, dynamic> tags = {};

  @override
  void initState() {
    super.initState();
    getTags();
  }

  Future getTags() async {
    Map temp = await widget.databaseService.getTags(widget.todoId);
    setState(() {
      tags = temp;
    });
  }

  void _showTagsDialog(BuildContext ctx) {
    var screenHeight = MediaQuery.of(ctx).size.height;
    showModalBottomSheet(
      isScrollControlled: true,
      context: ctx,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, update) {
            return Container(
              color: Colors.transparent,
              height: screenHeight * 0.6 + 3,
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
                    SizedBox(height: 10),
                    for (var tag in tags.entries)
                      Container(
                        color: Color(int.parse(tag.value['color'])),
                        child: ListTile(
                          onTap: () async {
                            setState(() {
                              update(() {
                                tag.value['active'] = !tag.value['active'];
                              });
                            });
                            await widget.databaseService
                                .updateTags(widget.todoId, tags);
                          },
                          leading: Theme(
                            data:
                                ThemeData(unselectedWidgetColor: Colors.white),
                            child: Checkbox(
                              checkColor: Color(int.parse(tag.value['color'])),
                              activeColor: Colors.white,
                              focusColor: Colors.white,
                              hoverColor: Colors.white,
                              onChanged: (val) async {
                                setState(() {
                                  update(() {
                                    tag.value['active'] = val;
                                  });
                                });
                                await widget.databaseService
                                    .updateTags(widget.todoId, tags);
                              },
                              value: tag.value['active'],
                            ),
                          ),
                          title: Text(
                            tag.value['name'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void removeTag(String key) async {
    setState(() {
      tags[key]['active'] = false;
    });
    await widget.databaseService.updateTags(widget.todoId, tags);
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
                for (var tag in tags.entries)
                  if (tag.value['active'])
                    Tag(tag.value['name'], Color(int.parse(tag.value['color'])),
                        () => removeTag(tag.key)),
                tags.values
                        .toList()
                        .every((element) => element['active'] == true)
                    ? Container()
                    : Container(
                        margin: EdgeInsets.fromLTRB(0, 1.25, 0, 8),
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
