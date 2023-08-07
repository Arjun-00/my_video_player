import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:my_video_player/provider/homescreenprovider.dart';
import 'package:my_video_player/provider/loginprovider.dart';
import 'package:my_video_player/provider/otpprovider.dart';
import 'package:my_video_player/provider/signinprovider.dart';
import 'package:my_video_player/provider/splashprovider.dart';
import 'package:my_video_player/screens/homescreen.dart';
import 'package:my_video_player/screens/loginscreen.dart';
import 'package:my_video_player/screens/otpscreen.dart';
import 'package:my_video_player/screens/signupscreen.dart';
import 'package:my_video_player/screens/splashscreen.dart';
import 'package:my_video_player/screens/vedioscreen.dart';
import 'package:my_video_player/themeclass/themestate.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();
  runApp(
    MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeState()),
          ChangeNotifierProvider(create: (_) => SplashProvider()),
          ChangeNotifierProvider(create: (_) => LoginProvider()),
          ChangeNotifierProvider(create: (_) => SignInProvider()),
          ChangeNotifierProvider(create: (_) => OtpProvider()),
          ChangeNotifierProvider(create: (_) => HomeScreenProvider()),
        ],
       // providers: providers)<ThemeState>(
    //  create: (context) => ThemeState(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
      return MaterialApp(
        theme: Provider.of<ThemeState>(context).theme == ThemeType.DARK ? ThemeData.dark(): ThemeData.light(),
        debugShowCheckedModeBanner: false,
        title: 'M Player',
        routes: {
          'splashscreen': (context) => SplashScreen(),
          'loginscreen': (context) => LoginScreen(),
          'signupscreen': (context) => SignUpScreen(),
          'otpscreen': (context) => OtpScreen(),
          'homescreen': (context) => HomeScreen(),
          // 'verify': (context) => MyVerify(),
          // 'homescreen' : (context) => HomeScreen()
        },
        initialRoute: 'splashscreen',
      );
  }
}