import 'package:flutter/material.dart';
import 'package:todoapp/screens/loading_screen.dart';
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

  bool _enableBtn = false;
  String btnText = 'ACCOUNT ERSTELLEN';
  Color btnColor = Colors.white;

  String username = '';
  String email = '';
  String password = '';

  bool loading = false;

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
      fieldType: 1,
      keyboardType: TextInputType.text,
      controller: _usernameController,
      suffixIcon: Icon(
        Icons.person_outline,
        color: Colors.white,
      ),
    );
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
        widget.toggleView, 'Bereits einen Account?', 'Anmelden');
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
                        margin: EdgeInsets.only(top: screenHeight * 0.043),
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
                              screenHeight * 0.06,
                              0,
                              0,
                            ),
                            child: Text(
                              'REGISTRIEREN',
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
                              }
                            } else {
                              _enableBtn = false;
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
                            onPressed: _enableBtn ? () async {
                                    setState(() {
                                      loading = true;
                                    });
                                    dynamic user = await _authService.signUp(username, email, password);
                                    if (user == null) {
                                      setState(() {
                                        btnText = 'E-Mail wird bereits verwendet'.toUpperCase();
                                        btnColor = Colors.red;
                                        _enableBtn = false;
                                        loading = false;
                                      });
                                    }
                                  }
                                : null,
                            disabledColor: Color.fromRGBO(33, 33, 33, 1),
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
          );
  }
}
