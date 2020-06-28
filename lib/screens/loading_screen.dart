import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white ,
        body: Container(
          child: Center(
            child: SpinKitChasingDots(
              color: Color.fromRGBO(35, 35, 35, 1),
              size: 50,
            ),
          ),
        ),
      ),
    );
  }
}
