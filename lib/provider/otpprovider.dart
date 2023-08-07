import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:my_video_player/screens/signupscreen.dart';

class OtpProvider extends ChangeNotifier{
  final FirebaseAuth auth = FirebaseAuth.instance;
  final CollectionReference donor = FirebaseFirestore.instance.collection('userdata');
  final storage = GetStorage();

  void otpVerification(BuildContext context,String otpCode,String email,String password,String name,String dateofbirth,String phoneNumber) async{

    PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: SignUpScreen.verify, smsCode:otpCode);
    await auth.signInWithCredential(credential);
    try {
      final newUser = await auth.createUserWithEmailAndPassword(
          email: email!, password: password!);
      if (newUser != null) {
        final data = {
          'name': name,
          'lastname': dateofbirth,
          'email': email,
          'phonenumber': phoneNumber,
          'password': password
        };
        donor.add(data);
        storage.write('username', email);
        storage.write('password', password);
        Navigator.pushNamed(context, 'homescreen');
      }
    }
    catch(e){
      throw e;
    }
  }


}