import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/database_service.dart';
import '../../models/user.dart';

class ProfileSection extends StatefulWidget {
  final User user;

  ProfileSection(this.user);

  @override
  _ProfileSectionState createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  final ImagePicker picker = ImagePicker();
  late File _pickedImageFile;
  String? imgUrl;

  // Creates the Dialog where you can choose between Camera and Gallery
  _createPhotoDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Bild auswählen'),
            content: Container(
              height: 96,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 15),
                    child: TextButton.icon(
                      icon: Icon(
                        Icons.photo_camera,
                        size: 36,
                        color: Colors.grey[300],
                      ),
                      label: Text('Kamera'),
                      onPressed: () {
                        _pickImage(ImageSource.camera);
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(right: 24),
                    child: TextButton.icon(
                      icon: Icon(
                        Icons.photo_library,
                        size: 36,
                        color: Colors.grey[300],
                      ),
                      label: Text('Gallerie'),
                      onPressed: () {
                        _pickImage(ImageSource.gallery);
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
            contentTextStyle: TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          );
        });
  }

  void _pickImage(ImageSource source) async {
    final pickedImage = await picker.getImage(source: source, imageQuality: 88, maxWidth: 150);
    setState(() {
      _pickedImageFile = File(pickedImage!.path);
    });
    imgUrl = await DatabaseService(widget.user.uid).storeImage(_pickedImageFile);
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    return StreamBuilder(
      stream: DatabaseService(widget.user.uid).userDataStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
          return Container(
            margin: EdgeInsets.only(top: screenHeight * 0.013),
            child: ListTile(
              leading: CircleAvatar(
                radius: 24,
                backgroundImage: null,
              ),
              title: Text(
                'Lädt..',
              ),
              subtitle: Text(
                '',
              ),
            ),
          );
        }
        return Container(
          margin: EdgeInsets.only(top: screenHeight * 0.013),
          child: ListTile(
            leading: GestureDetector(
              onTap: _createPhotoDialog,
              child: CircleAvatar(
                radius: 28,
                backgroundColor: (snapshot.data as DocumentSnapshot)['photoUrl'] == ''
                    ? Colors.black54
                    : Colors.transparent,
                child: (snapshot.data as DocumentSnapshot)['photoUrl'] == ''
                    ? IconButton(
                        icon: Icon(Icons.add_a_photo),
                        color: Colors.white,
                        onPressed: _createPhotoDialog,
                      )
                    : null,
                backgroundImage: NetworkImage((snapshot.data as DocumentSnapshot)['photoUrl']),
              ),
            ),
            title: Text((snapshot.data as DocumentSnapshot)['username']),
            subtitle: Text(
              (snapshot.data as DocumentSnapshot)['email'],
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Container(
              child: IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    '/settings',
                    arguments: {
                      'uid': widget.user.uid,
                      'authMethod': (snapshot.data as DocumentSnapshot)['authMethod'],
                      'email': (snapshot.data as DocumentSnapshot)['email'],
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
