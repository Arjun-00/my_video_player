import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({Key? key}) : super(key: key);
  late double screenwidth;
  late double screenheight;

  @override
  Widget build(BuildContext context) {
    screenwidth = MediaQuery.of(context).size.width;
    screenheight = MediaQuery.of(context).size.height;
    Future.delayed(Duration(seconds: 2),() => goToLogin(context));
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Image.asset("assets/icons.png",width: screenwidth * 0.33,),
        ),
      ),
    );
  }
  void goToLogin(BuildContext context) {
    Navigator.popAndPushNamed(context, "loginscreen");
  }
}


