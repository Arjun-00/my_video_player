import 'package:flutter/material.dart';
import 'package:my_video_player/provider/splashprovider.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({Key? key}) : super(key: key);
  late double screenwidth;
  late double screenheight;

  @override
  Widget build(BuildContext context) {
    final splashProvider = Provider.of<SplashProvider>(context);
    screenwidth = MediaQuery.of(context).size.width;
    screenheight = MediaQuery.of(context).size.height;

    Future.delayed(Duration(seconds: 2),() => splashProvider.splashController(context));
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Image.asset("assets/icons.png",width: screenwidth * 0.33,),
        ),
      ),
    );
  }
}


