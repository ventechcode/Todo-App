import 'dart:io';
import 'package:flutter/material.dart';
import 'package:todoapp/models/user.dart';
import 'package:todoapp/services/database_service.dart';
import 'package:image_picker/image_picker.dart';

class ProfileSection extends StatefulWidget {
  final User user;

  ProfileSection(this.user);

  @override
  _ProfileSectionState createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  final ImagePicker picker = ImagePicker();
  File _pickedImageFile;
  String imgUrl;

  void _pickImage() async {
    final pickedImage = await picker.getImage(
        source: ImageSource.camera, imageQuality: 88, maxWidth: 150);
    setState(() {
      _pickedImageFile = File(pickedImage.path);
    });
    print('Image has been picked.');
    imgUrl = await DatabaseService(widget.user.uid).storeImage(_pickedImageFile);
    print('Image has been stored in Database.');
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    return StreamBuilder(
      stream: DatabaseService(widget.user.uid).userDataStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.data == null) {
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
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: snapshot.data['photoUrl'] == ''
                  ? Colors.black54
                  : Colors.transparent,
              child: snapshot.data['photoUrl'] == ''
                  ? IconButton(
                      icon: Icon(Icons.add_a_photo),
                      color: Colors.white,
                      onPressed: _pickImage,
                    )
                  : null,
              backgroundImage: widget.user.getPhotoUrl() != null
                  ? NetworkImage(snapshot.data['photoUrl'])
                  : null,
            ),
            title: Text(snapshot.data['username']),
            subtitle: Text(
              snapshot.data['email'],
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
                      'authMethod': snapshot.data['authMethod'],
                      'email': snapshot.data['email'],
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
