import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../screens/loading_screen.dart';
import '../services/auth_service.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/social_login.dart';

class LoginScreen extends StatefulWidget {
  final Function toggleView;
  LoginScreen({this.toggleView});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _resetEmailController = TextEditingController();
  final AuthService _authService = AuthService();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _enableBtn = false;
  String _btnText = 'JETZT EINLOGGEN';
  Color _btnColor = Colors.white;

  String email = '';
  String password = '';

  bool loading = false;

  createForgotPasswordDialog(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Ihre E-Mail-Adresse'),
          content: Container(
            margin: EdgeInsets.only(top: 5),
            height: 77,
            width: 70,
            alignment: Alignment.center,
            child: Column(
              children: [
                Container(
                  height: 44,
                  child: TextField(
                    autofocus: true,
                    controller: _resetEmailController,
                    keyboardType: TextInputType.emailAddress,
                    cursorColor: Colors.black,
                    cursorWidth: 1,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(7, 0, 0, 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(
                          width: 1,
                          color: Colors.black,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(
                          width: 1,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5,),
                Container(
                  margin: EdgeInsets.only(left: 1),
                  child: Text('Ihnen wird ein Link zum Zurücksetzen ihres Passwortes zugeschickt.', style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Container(
              margin: EdgeInsets.only(right: screenWidth * 0.028),
              child: FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(_resetEmailController.text.trim());
                },
                child: Text(
                  'Senden',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
              ),
            )
          ],
        );
      },
    ).then((value) async {
      if(value != null && value != '') {
        bool result = await _authService.sendPasswordReset(value);
        if(result == false) {
          _scaffoldKey.currentState.showSnackBar(
            SnackBar(
              duration: Duration(milliseconds: 3610),
              content: Container(
                height: 44,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 24,
                      color: Colors.red,
                    ),
                    SizedBox(width: 8,),
                    Text(
                      'Es existiert kein Nutzer mit dieser E-Mail',
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          _scaffoldKey.currentState.showSnackBar(
            SnackBar(
              duration: Duration(milliseconds: 3610),
              content: Container(
                height: 44,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_box,
                      size: 24,
                      color: Colors.green,
                    ),
                    SizedBox(width: 8,),
                    Text(
                      'Wiederherstellungs-Link wurde gesendet',
                      style: TextStyle(
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        _resetEmailController.text = '';
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    CustomTextField _emailField = CustomTextField(
      lblText: 'E-Mail-Adresse',
      fieldType: 2,
      keyboardType: TextInputType.emailAddress,
      controller: _emailController,
      suffixIcon: Icon(
        Icons.mail_outline,
        color: Colors.white,
      ),
    );
    CustomTextField _passwordField = CustomTextField(
      lblText: 'Passwort',
      fieldType: 3,
      keyboardType: TextInputType.text,
      controller: _passwordController,
      suffixIcon: Icon(
        Icons.lock_outline,
        color: Colors.white,
      ),
    );
    SocialLoginSection _socialLoginSection = SocialLoginSection(
        widget.toggleView, 'Noch keinen Account?', 'Registrieren');
    return loading
        ? LoadingScreen()
        : SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Color.fromRGBO(35, 35, 35, 1),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: screenHeight * 0.069),
                  child: Text(
                    'ToDo-App',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontFamily: 'Nexa',
                    ),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.fromLTRB(
                        screenWidth * 0.135,
                        screenHeight * 0.085,
                        0,
                        0,
                      ),
                      child: Text(
                        'ANMELDEN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Form(
                  onChanged: () {
                    setState(() {
                      if (_emailField.content.length != 0 &&
                          _passwordField.content.length != 0) {
                        _enableBtn = true;
                        _btnColor = Colors.white;
                        _btnText = 'JETZT EINLOGGEN';
                        email = _emailController.text;
                        password = _passwordController.text;
                      } else {
                        _enableBtn = false;
                      }
                    });
                  },
                  child: Column(
                    children: <Widget>[
                      _emailField,
                      _passwordField,
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        createForgotPasswordDialog(context);
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(
                          0,
                          screenHeight * 0.02,
                          screenWidth * 0.125,
                          0,
                        ),
                        child: Text(
                          'Passwort vergessen?',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: screenHeight * 0.031),
                  width: screenWidth * 0.75,
                  height: screenHeight * 0.078,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: _enableBtn
                        ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.fromRGBO(0, 71, 214, 1),
                        Color.fromRGBO(0, 166, 239, 1)
                      ],
                    )
                        : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: FlatButton(
                      onPressed: _enableBtn
                          ? () async {
                        setState(() => loading = true);
                        dynamic user = await _authService.signIn(
                            email, password);
                        if (user == null) {
                          setState(() {
                            _btnColor = Colors.red;
                            _btnText = 'FALSCHE DATEN';
                            _enableBtn = false;
                            loading = false;
                          });
                        }
                      }
                          : null,
                      disabledColor: Color.fromRGBO(33, 33, 33, 1),
                      color: Colors.transparent,
                      child: Text(
                        _btnText,
                        style: TextStyle(
                          fontSize: 12,
                          color: _btnColor,
                        ),
                      ),
                    ),
                  ),
                ),
                _socialLoginSection,
              ],
            ),
          ),
        ),
      ),
    );
  }
}