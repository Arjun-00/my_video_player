import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_video_player/screens/homescreen.dart';
import 'package:my_video_player/screens/loginscreen.dart';
import 'package:my_video_player/screens/otpscreen.dart';
import 'package:my_video_player/screens/signupscreen.dart';
import 'package:my_video_player/screens/splashscreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'M Player',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      routes: {
        'splashscreen' : (context) => SplashScreen(),
        'loginscreen' : (context) => LoginScreen(),
        'signupscreen' : (context) => SignUpScreen(),
        'otpscreen' : (context) => OtpScreen(),
        'homescreen' : (context) => HomeScreen()
        // 'phone': (context) => MyPhone(),
        // 'verify': (context) => MyVerify(),
        // 'homescreen' : (context) => HomeScreen()
      },
      initialRoute: 'splashscreen',
    );
  }
}