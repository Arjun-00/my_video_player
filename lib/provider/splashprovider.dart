import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class SplashProvider extends ChangeNotifier{
  final storage = GetStorage();

  void splashController(BuildContext context){
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