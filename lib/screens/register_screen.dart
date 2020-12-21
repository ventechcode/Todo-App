import 'package:flutter/material.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:todoapp/fieldtype.dart';
import 'package:todoapp/widgets/scroll_behavior.dart';

import '../screens/loading_screen.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/social_login.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  final Function toggleView;
  RegisterScreen({this.toggleView});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final AuthService _authService = AuthService();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final FocusNode _usernameNode = FocusNode();
  final FocusNode _emailNode = FocusNode();
  final FocusNode _passwordNode = FocusNode();

  bool _enableBtn = false;
  String btnText = 'ACCOUNT ERSTELLEN';
  Color btnColor = Colors.black38;

  String username = '';
  String email = '';
  String password = '';

  bool loading = false;

  @override
  void initState() {
    super.initState();
    KeyboardVisibilityNotification().addNewListener(onChange: (visible) {
      if(!visible) {
        _usernameNode.unfocus();
        _emailNode.unfocus();
        _passwordNode.unfocus();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    CustomTextField _usernameField = CustomTextField(
      lblText: 'Benutzername',
      fieldType: FieldType.USERNAME,
      keyboardType: TextInputType.text,
      controller: _usernameController,
      suffixIcon: Icon(
        Icons.person_outline,
        color: Colors.black,
      ),
      focusNode: _usernameNode,
    );
    CustomTextField _emailField = CustomTextField(
      lblText: 'E-Mail-Adresse',
      fieldType: FieldType.EMAIL,
      keyboardType: TextInputType.emailAddress,
      controller: _emailController,
      suffixIcon: Icon(
        Icons.mail_outline,
        color: Colors.black,
      ),
      focusNode: _emailNode,
    );
    CustomTextField _passwordField = CustomTextField(
      lblText: 'Passwort',
      fieldType: FieldType.PASSWORD,
      keyboardType: TextInputType.text,
      controller: _passwordController,
      suffixIcon: Icon(
        Icons.lock_outline,
        color: Colors.black,
      ),
      focusNode: _passwordNode,
    );
    SocialLoginSection _socialLoginSection = SocialLoginSection(
      widget.toggleView,
      'Bereits einen Account?',
      'Hier Anmelden.',
    );
    return loading
        ? LoadingScreen()
        : SafeArea(
            child: Scaffold(
              key: _scaffoldKey,
              backgroundColor: Colors.white,
              body: ScrollConfiguration(
                behavior: CustomScrollBehavior(),
                child: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(top: screenHeight * 0.04),
                          child: Text(
                            'ToDo-App',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 42,
                              fontFamily: 'Nexa',
                            ),
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.fromLTRB(
                                screenWidth * 0.1 + 1,
                                screenHeight * 0.04,
                                0,
                                screenHeight * 0.01,
                              ),
                              child: Text(
                                'REGISTRIEREN',
                                style: TextStyle(
                                  color: Colors.black,
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
                                  _usernameField.content.length != 0 &&
                                  _passwordField.content.length != 0) {
                                email = _emailController.text;
                                password = _passwordController.text;
                                username = _usernameController.text;
                                if (email.contains('@') &&
                                    email.contains('.') &&
                                    password.length >= 6 &&
                                    !email.contains('@.')) {
                                  _enableBtn = true;
                                  btnText = 'ACCOUNT ERSTELLEN';
                                  btnColor = Colors.white;
                                  _enableBtn = true;
                                } else {
                                  _enableBtn = false;
                                  btnColor = Colors.black38;
                                }
                              } else {
                                _enableBtn = false;
                                btnColor = Colors.black38;
                              }
                            });
                          },
                          child: Column(
                            children: <Widget>[
                              _usernameField,
                              _emailField,
                              _passwordField,
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: screenHeight * 0.031),
                          width: screenWidth * 0.8,
                          height: screenHeight * 0.078,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
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
                                      setState(() {
                                        loading = true;
                                      });
                                      dynamic user = await _authService.signUp(
                                          username, email, password);
                                      if (user == null) {
                                        setState(() {
                                          btnText =
                                              'E-Mail wird bereits verwendet'
                                                  .toUpperCase();
                                          btnColor = Colors.red;
                                          _enableBtn = false;
                                          loading = false;
                                        });
                                      }
                                    }
                                  : null,
                              disabledColor: Colors.grey[100],
                              color: Colors.transparent,
                              child: Text(
                                btnText,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: btnColor,
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
            ),
          );
  }
}
