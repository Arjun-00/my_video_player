import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:my_video_player/provider/otpprovider.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';


class OtpScreen extends StatefulWidget {
  const OtpScreen({Key? key}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with TickerProviderStateMixin{
  bool _isResendAgain = false;
  late AnimationController _controller;
  int levelClock = 120;
  late Timer _timer;
  String? errorMessage;
  String otpCode = "";
  int _start = 120;
  var code = "";
  String? name;
  String? dateofbirth;
  String? email;
  String? phoneNumber;
  String? password;

  Future<void> secureScreen() async {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }
  @override
  Future<void> dispose() async {
    await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
    SmsAutoFill().unregisterListener();
    super.dispose();
  }
  void _listenOtp() async {
    await SmsAutoFill().listenForCode();
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
          otpCode = "";
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
  void initState() {
    _listenOtp();
    secureScreen();
    otpTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final otpProvider = Provider.of<OtpProvider>(context);
    final Map<String, dynamic> data =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    name = data['name'] as String;
    dateofbirth = data['dateofbirth'] as String;
    email = data['email'] as String;
    phoneNumber = data['phoneNumber'] as String;
    password = data['password'] as String;
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        margin: const EdgeInsets.only(left: 25, right: 25),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/icons.png', width: 120, height: 120,),
              const SizedBox(height: 25,),
              const Text("Phone Verification",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10,),
              const Text("We need to register your phone without getting started!",
                style: TextStyle(fontSize: 16,),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30,),
              PinFieldAutoFill(
                currentCode: otpCode,
                decoration: const BoxLooseDecoration(
                    radius: Radius.circular(12),
                    strokeColorBuilder: FixedColorBuilder(
                        Color(0xFF8C4A52))),
                codeLength: 6,
                onCodeChanged: (code) {
                  print("OnCodeChanged : $code");
                  otpCode = code.toString();
                },
                onCodeSubmitted: (val) {
                  print("OnCodeSubmitted : $val");
                },
              ),
              const SizedBox(height: 20,),
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
                        otpProvider.otpVerification(context, otpCode, email!, password!, name!, dateofbirth!, phoneNumber!);
                      }catch(e){
                        setState(() {
                          errorMessage = e.toString();
                        });
                      }
                    },
                    child: const Text("Verify Phone Number")),
              ),
              Row(
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(context, 'signupscreen', (route) => false,);
                      },
                      child: const Text("Edit Phone Number ?", style: TextStyle(color: Colors.black),))
                ],
              ),
              const SizedBox(height: 15,),
              _isResendAgain ? Countdown(animation: StepTween(
                begin: levelClock,
                end: 0,
              ).animate(_controller),) : const SizedBox(),
              const SizedBox(height: 20,),
              GestureDetector(
                  onTap: () {
                    otpTimer();
                  },
                  child: const Text("RESEND NEW CODE",textAlign: TextAlign.center,style: TextStyle(fontFamily: "SourceSanProBold",fontSize:15,fontWeight: FontWeight.bold,color:Colors.red))),
              const SizedBox(height: 15),
              errorMessage!= null ? Text(errorMessage!,style: TextStyle(fontSize: 16,color: Colors.red,fontWeight: FontWeight.bold),) : SizedBox(),
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