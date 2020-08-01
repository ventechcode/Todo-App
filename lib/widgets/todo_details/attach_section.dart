import 'dart:io';
import 'dart:math';
import 'package:path/path.dart' as path;

import 'package:open_file/open_file.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../../services/database_service.dart';

class AttachSection extends StatefulWidget {
  final DatabaseService databaseService;
  final String todoId;

  AttachSection(this.databaseService, this.todoId);

  @override
  _AttachSectionState createState() => _AttachSectionState();
}

class _AttachSectionState extends State<AttachSection> {
  final ImagePicker _imagePicker = ImagePicker();
  List<File> files = [];
  bool gotFiles = false;

  void _pickFile() async {
    File pickedFile = await FilePicker.getFile();
    if (pickedFile.lengthSync() > 3000000) {
      print('File is too big');
    } else {
      await widget.databaseService
          .storeFile(pickedFile, widget.todoId)
          .whenComplete(() {
        setState(() {
          getFiles();
        });
      });
    }
  }

  void _pickImage() async {
    var picked = await _imagePicker.getImage(
        source: ImageSource.camera, imageQuality: 88);
    File pickedImage = File(picked.path);
    if (pickedImage.lengthSync() > 3000000) {
      print('Bild ist zu groß');
    } else {
      await widget.databaseService.storeFile(pickedImage, widget.todoId);
    }
  }

  void _pickVideo() async {
    var picked = await _imagePicker.getVideo(source: ImageSource.camera);
    File pickedVideo = File(picked.path);
    if (pickedVideo.lengthSync() > 3000000) {
      print('Video ist zu groß');
    } else {
      await widget.databaseService
          .storeFile(pickedVideo, widget.todoId)
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
    await widget.databaseService.getFiles(widget.todoId).then((files) {
      setState(() {
        this.files = files;
        if (this.files.isNotEmpty) gotFiles = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 16, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          !gotFiles
              ? Container(
                  margin: const EdgeInsets.fromLTRB(1, 12, 0, 0),
                  width: screenWidth * 0.87,
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
                  margin: const EdgeInsets.fromLTRB(1, 12, 0, 0),
                  height: 200,
                  width: screenWidth * 0.87,
                  child: StreamBuilder(
                    stream: widget.databaseService.files(widget.todoId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting &&
                          !snapshot.hasData) {
                        return Container();
                      } else {
                        return ListView.builder(
                          itemCount: files.length,
                          itemBuilder: (context, index) {
                            return Container(
                              child: Row(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 6),
                                    height: 36,
                                    width: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.lightBlue,
                                      borderRadius: BorderRadius.circular(5),
                                      image: DecorationImage(
                                        image: NetworkImage(snapshot.data.documents[index]['url']),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: snapshot.data.documents[index]
                                                ['type'] == 'mp4'
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
                                    width: 16,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding:
                                            const EdgeInsets.only(right: 5),
                                        child: Text(
                                          path
                                              .basename(files[index].path)
                                              .substring(3),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Container(
                                        child: Text(
                                          formatBytes(
                                                  snapshot.data.documents[index]
                                                      ['bytes'],
                                                  2)
                                              .replaceAll(".", ","),
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        child: Divider(
                                          height: 1,
                                          color: Colors.grey[700],
                                          thickness: 1,
                                        ),
                                        width: screenWidth * 0.73 - 1.6,
                                        padding: const EdgeInsets.only(top: 6),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
