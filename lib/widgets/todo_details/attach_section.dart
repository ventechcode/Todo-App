import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;

import 'package:open_file/open_file.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:todoapp/services/todo_service.dart';
import 'package:todoapp/widgets/scroll_behavior.dart';
import 'package:todoapp/models/todo.dart';
import '../../services/todo_service.dart';

class AttachSection extends StatefulWidget {
  final Todo? todo;
  final TodoService? todoService;

  AttachSection({this.todo, this.todoService});

  @override
  _AttachSectionState createState() => _AttachSectionState();
}

class _AttachSectionState extends State<AttachSection> {
  final ImagePicker _imagePicker = ImagePicker();
  bool loading = false;

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null) {
      if (result.isSinglePick) {
        File file = File(result.files.single.path!);
        if (file.lengthSync() > 5000000) {
          createFileToBigError();
        } else {
          await widget.todoService!
              .storeFile(widget.todo!, file)
              .whenComplete(() {
            setState(() {
              getFiles();
            });
          });
        }
      }
    }
  }

  void _pickImage() async {
    PickedFile? picked = await _imagePicker.getImage(
        source: ImageSource.camera, imageQuality: 88);
    File pickedImage = File(picked!.path);
    if (pickedImage.lengthSync() > 5000000) {
      createFileToBigError();
    } else {
      await widget.todoService!
          .storeFile(widget.todo!, pickedImage)
          .whenComplete(() {
        setState(() {
          getFiles();
        });
      });
    }
  }

  void _pickVideo() async {
    PickedFile? picked =
        await _imagePicker.getVideo(source: ImageSource.camera);
    File pickedVideo = File(picked!.path);
    if (pickedVideo.lengthSync() > 5000000) {
      createFileToBigError();
    } else {
      await widget.todoService!
          .storeFile(widget.todo!, pickedVideo)
          .whenComplete(() {
        setState(() {
          getFiles();
        });
      });
    }
  }

  static String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1000)).floor();
    return ((bytes / pow(1000, i)).toStringAsFixed(decimals)) +
        ' ' +
        suffixes[i];
  }

  createFileToBigError() {
    var screenWidth = MediaQuery.of(context).size.height;
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.white,
      content: Container(
        height: screenWidth * 0.05,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 24,
              color: Colors.lightBlue,
            ),
            SizedBox(
              width: 8,
            ),
            Text(
              'Die Dateigröße überschreitet 5 Megabyte',
              style: TextStyle(
                color: Colors.lightBlue,
              ),
            ),
          ],
        ),
      ),
      duration: Duration(milliseconds: 3500),
    ));
  }

  void _showAttachDialog(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (context) {
        return Container(
          color: Colors.transparent,
          height: 184,
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
                ListTile(
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickFile();
                  },
                  leading: Container(
                    margin: const EdgeInsets.fromLTRB(9, 15, 0, 0),
                    child: Icon(
                      Icons.folder_open,
                      color: Colors.grey[700],
                      size: 26,
                    ),
                  ),
                  title: Container(
                    margin: const EdgeInsets.fromLTRB(0, 16, 8, 0),
                    child: Text('Gerätedateien'),
                  ),
                ),
                ListTile(
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage();
                  },
                  leading: Container(
                    margin: const EdgeInsets.fromLTRB(9, 3, 0, 0),
                    child: Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.grey[700],
                      size: 26,
                    ),
                  ),
                  title: Container(
                    margin: const EdgeInsets.fromLTRB(0, 3, 8, 0),
                    child: Text('Foto aufnehmen'),
                  ),
                ),
                ListTile(
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickVideo();
                  },
                  leading: Container(
                    margin: const EdgeInsets.fromLTRB(8, 0, 0, 11),
                    child: Icon(
                      Icons.video_call_outlined,
                      size: 31,
                      color: Colors.grey[700],
                    ),
                  ),
                  title: Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 8, 10.5),
                    child: Text('Video aufnehmen'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getFiles();
  }

  Future getFiles() async {
    this.widget.todo!.files = await widget.todoService!.getFiles(widget.todo!);
    setState(() {});
    if (this.widget.todo!.hasFiles) {
      this.widget.todo!.gotFiles = true;
      this.widget.todoService!.updateTodo(this.widget.todo!);
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 16, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                child: Text(
                  'Dateien',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Nexa'),
                ),
              ),
              if (widget.todo!.hasFiles)
                SizedBox(
                  width: screenWidth * 0.5025,
                ),
              if (widget.todo!.hasFiles)
                GestureDetector(
                  onTap: () => _showAttachDialog(context),
                  child: DottedBorder(
                    radius: Radius.circular(20),
                    dashPattern: [4, 3],
                    strokeCap: StrokeCap.round,
                    strokeWidth: 0.88,
                    borderType: BorderType.RRect,
                    color: Colors.grey,
                    child: Container(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(6, 1, 6, 1),
                        child: Text(
                          'Hochladen',
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
            ],
          ),
          !widget.todo!.hasFiles
              ? Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: screenWidth * 0.88,
                  child: GestureDetector(
                    onTap: () => _showAttachDialog(context),
                    child: DottedBorder(
                      dashPattern: [4, 3],
                      strokeCap: StrokeCap.round,
                      strokeWidth: 0.88,
                      borderType: BorderType.RRect,
                      radius: Radius.circular(8),
                      color: Colors.grey,
                      child: Container(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(8, 10, 8, 10),
                          child: Text(
                            'Tippe, um eine Datei hinzuzufügen',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : Container(
                  margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                  //height: 200,
                  width: screenWidth * 0.88,
                  child: StreamBuilder(
                    stream: widget.todoService!.files(widget.todo!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting ||
                          !snapshot.hasData) {
                        return Container();
                      }
                      return ScrollConfiguration(
                        behavior: CustomScrollBehavior(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: 50,
                            maxHeight: 160,
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: widget.todo!.files.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  OpenFile.open(widget.todo!.files[index].path);
                                },
                                splashColor: Colors.grey[200],
                                highlightColor: Colors.grey[200],
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(10, 8, 0, 0),
                                      child: Row(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 6),
                                            height: 36,
                                            width: 36,
                                            decoration: BoxDecoration(
                                              color: Colors.lightBlue,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              image: DecorationImage(
                                                image: NetworkImage((snapshot
                                                        .data! as QuerySnapshot)
                                                    .docs[index]['url']),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            child: (snapshot.data!
                                                            as QuerySnapshot)
                                                        .docs[index]['type'] ==
                                                    'mp4'
                                                ? Center(
                                                    child: Text(
                                                      'MP4',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  )
                                                : null,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: Text(
                                                  path
                                                              .basename(widget
                                                                  .todo!
                                                                  .files[index]
                                                                  .path)
                                                              .substring(3)
                                                              .length >
                                                          24
                                                      ? path
                                                          .basename(widget
                                                              .todo!
                                                              .files[index]
                                                              .path)
                                                          .substring(3)
                                                          .replaceRange(
                                                              21,
                                                              path
                                                                  .basename(widget
                                                                      .todo!
                                                                      .files[
                                                                          index]
                                                                      .path)
                                                                  .substring(3)
                                                                  .length,
                                                              ".." +
                                                                  (snapshot.data!
                                                                              as QuerySnapshot)
                                                                          .docs[index]
                                                                      ['type'])
                                                      : path
                                                          .basename(widget
                                                              .todo!
                                                              .files[index]
                                                              .path)
                                                          .substring(3),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                width: screenWidth * 0.53,
                                              ),
                                              SizedBox(
                                                height: 3,
                                              ),
                                              Container(
                                                child: Text(
                                                  formatBytes(
                                                          (snapshot.data!
                                                                  as QuerySnapshot)
                                                              .docs[index]['bytes'],
                                                          2)
                                                      .replaceAll(".", ","),
                                                  style: TextStyle(
                                                    color: Colors.grey[700],
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                margin:
                                                    EdgeInsets.only(bottom: 6),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.clear,
                                                color: Colors.grey[700],
                                                size: 23,
                                              ),
                                              onPressed: () async {
                                                setState(() {
                                                  widget.todoService!
                                                      .deleteFile(
                                                          widget.todo!,
                                                          path
                                                              .basename(widget
                                                                  .todo!
                                                                  .files[index]
                                                                  .path)
                                                              .substring(3));
                                                  widget.todo!.files
                                                      .removeWhere((file) =>
                                                          file.path ==
                                                          widget
                                                              .todo!
                                                              .files[index]
                                                              .path);
                                                  if (!this
                                                      .widget
                                                      .todo!
                                                      .hasFiles) {
                                                    this.widget.todo!.gotFiles =
                                                        false;
                                                    this
                                                        .widget
                                                        .todoService!
                                                        .updateTodo(
                                                            this.widget.todo!);
                                                  }
                                                });
                                              },
                                            ),
                                            padding: EdgeInsets.fromLTRB(
                                                screenWidth * 0.06, 0, 0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      child: Divider(
                                        height: 1,
                                        color: Colors.grey[700],
                                        thickness: 1,
                                      ),
                                      width: screenWidth * 0.89,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
