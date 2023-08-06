import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({Key? key}) : super(key: key);
  late double screenwidth;
  late double screenheight;
  final storage = GetStorage();

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
    String username = storage.read('username') ?? "";
    String password = storage.read('password') ?? "";
    try{
      if(username != null && username != "" && password != null && password != "" ){
        Navigator.popAndPushNamed(context, "homescreen");
      }else{
        Navigator.popAndPushNamed(context, "loginscreen");
      }
    }catch (e){
      Navigator.popAndPushNamed(context, "loginscreen");
    }
  }
}


