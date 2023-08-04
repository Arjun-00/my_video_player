import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_video_player/screens/signupscreen.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';


class OtpScreen extends StatefulWidget {
  const OtpScreen({Key? key}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with TickerProviderStateMixin{
  final FirebaseAuth auth = FirebaseAuth.instance;
  final CollectionReference donor = FirebaseFirestore.instance.collection('userdata');

  OtpFieldController otpController = OtpFieldController();
  bool _isResendAgain = false;
  late AnimationController _controller;
  int levelClock = 120;
  late Timer _timer;
  String? errorMessage;
  int _start = 120;
  var code = "";
  String? name;
  String? lastname;
  String? email;
  String? phoneNumber;
  String? password;



  @override
  void initState() {
    // TODO: implement initState
    otpTimer();
    super.initState();
  }

  void otpTimer() {
    setState(() {
      _isResendAgain = true;
    });
    _controller = AnimationController(vsync: this,
        duration: Duration(seconds: levelClock));
    _controller.forward();
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (timer) {
      setState(() {
        if (_start == 0) {
          otpController.clear();
          errorMessage = "OTP Expired !";
          _start = 120;
          _isResendAgain = false;
          timer.cancel();
        } else {
          _start--;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> data =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    name = data['name'] as String;
    lastname = data['lastname'] as String;
    email = data['email'] as String;
    phoneNumber = data['phoneNumber'] as String;
    password = data['password'] as String;
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        margin: EdgeInsets.only(left: 25, right: 25),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icons.png',
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 25,),
              const Text("Phone Verification",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10,),
              const Text("We need to register your phone without getting started!",
                style: TextStyle(fontSize: 16,),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30,),
              OTPTextField(
                  controller: otpController,
                  length: 6,
                  width: MediaQuery.of(context).size.width,
                  textFieldAlignment: MainAxisAlignment.spaceAround,
                  fieldWidth: 50,
                  fieldStyle: FieldStyle.box,
                  outlineBorderRadius: 15,
                  style: const TextStyle(fontFamily: "SourceSanProBold",fontSize: 20,color: Color(0xff383838)),
                  onChanged: (value){},
                  onCompleted: (pin)  {
                      code = pin.toString();
                  }
              ),
              SizedBox(height: 20,),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.green.shade600,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: () async{
                      try{
                        PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: SignUpScreen.verify, smsCode:code);
                        await auth.signInWithCredential(credential);
                        try {
                          final newUser = await auth.createUserWithEmailAndPassword(
                              email: email!, password: password!);
                          if (newUser != null) {
                            Navigator.pushNamed(context, 'homescreen');
                            final data = {'name' : name, 'lastname' : lastname, 'email' : email, 'phonenumber' : phoneNumber, 'password' : password};
                            donor.add(data);
                          }
                        } catch (e) {
                          print(e);
                        }
                      }catch(e){
                        print("wrong otp");
                      }
                    },
                    child: Text("Verify Phone Number")),
              ),
              Row(
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(context, 'signupscreen', (route) => false,);
                      },
                      child: Text(
                        "Edit Phone Number ?",
                        style: TextStyle(color: Colors.black),
                      ))
                ],
              ),

              SizedBox(height: 15,),
              _isResendAgain ? Countdown(animation: StepTween(
                begin: levelClock,
                end: 0,
              ).animate(_controller),) : const SizedBox(),
              SizedBox(height: 20,),
              GestureDetector(
                  onTap: () {
                    otpTimer();
                  },
                  child: Text("RESEND NEW CODE",textAlign: TextAlign.center,style: TextStyle(fontFamily: "SourceSanProBold",fontSize:15,fontWeight: FontWeight.bold,color:Colors.red))),
            ],
          ),
        ),
      ),
    );
  }
}

/// mm:ss Format Decrement timer set.
class Countdown extends AnimatedWidget {
  Countdown({Key? key, required this.animation}) : super(key: key, listenable: animation);
  Animation<int> animation;
  @override
  build(BuildContext context) {
    Duration clockTimer = Duration(seconds: animation.value);
    String timerText = '${clockTimer.inMinutes.remainder(60).toString()}:${clockTimer.inSeconds.remainder(60).toString().padLeft(2, '0')}';
    return Text("OTP Expires in $timerText", style: const TextStyle(fontSize: 14, color: Colors.green,fontWeight: FontWeight.bold),);
  }
}