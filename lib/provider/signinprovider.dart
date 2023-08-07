import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/signupscreen.dart';

class SignInProvider extends ChangeNotifier{
  void signUpDatas(BuildContext context,String phoneNumber,String name,String dateofbirth,String email,String phonenumber,String password) async{
    try{
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {},
        codeSent: (String verificationId, int? resendToken) {
          SignUpScreen.verify = verificationId;
          Navigator.of(context).pushNamedAndRemoveUntil('otpscreen',(route) => false,arguments: {
            "name": name,
            "dateofbirth": dateofbirth,
            "email": email,
            "phoneNumber": phoneNumber,
            "password": password
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    }catch(e){
      throw e;
    }

  }
}