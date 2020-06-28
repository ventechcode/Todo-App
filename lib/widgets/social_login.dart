import 'package:flutter/material.dart';
import 'package:todoapp/models/user.dart';
import 'package:todoapp/services/auth_service.dart';

class SocialLoginSection extends StatefulWidget {
  final Function _toggleView;
  final String _description;
  final String _text;

  SocialLoginSection(this._toggleView, this._description, this._text);

  @override
  _SocialLoginSectionState createState() => _SocialLoginSectionState();
}

class _SocialLoginSectionState extends State<SocialLoginSection> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.fromLTRB(
              0, screenHeight * 0.05, 0, screenHeight * 0.05),
          child: Row(
            children: <Widget>[
              Container(
                width: screenWidth * 0.42,
                height: 1,
                color: Colors.white,
              ),
              Container(
                margin: EdgeInsets.fromLTRB(
                    screenWidth * 0.04, 0, screenWidth * 0.04, 0),
                child: Text(
                  'Oder',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                width: screenWidth * 0.42,
                height: 1,
                color: Colors.white,
              ),
            ],
          ),
        ),
        Container(
          height: screenHeight * 0.0625,
          width: screenWidth * 0.75,
          child: FlatButton(
            onPressed: () async {
              User user = await _authService.googleSignIn();
              if (user == null) {
                print('Login failed!');
              }
            },
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 20,
                  width: 20,
                  child: Image(
                    image: AssetImage('assets/images/google_logo.png'),
                  ),
                ),
                SizedBox(width: screenWidth * 0.031),
                Text(
                  'Mit Google anmelden',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: screenHeight * 0.03),
          height: screenHeight * 0.0625,
          width: screenWidth * 0.75,
          child: FlatButton(
            onPressed: () async {
              User user = await _authService.twitterSignIn();
              if (user == null) {
                print('Login failed!');
              }
            },
            color: Color(0xFF00acee),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 20,
                  width: 20,
                  child: Image(
                    image: AssetImage('assets/images/twitter_logo.png'),
                  ),
                ),
                SizedBox(width: screenWidth * 0.024),
                Text(
                  'Mit Twitter anmelden',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(
              0, screenHeight * 0.04, 0, screenHeight * 0.02),
          width: screenWidth * 0.75,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                widget._description,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              SizedBox(width: screenWidth * 0.036),
              GestureDetector(
                onTap: widget._toggleView,
                child: Text(
                  widget._text.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
