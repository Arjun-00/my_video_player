import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class LoginProvider extends ChangeNotifier{
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('userdata');
  final storage = GetStorage();

  Future<bool> checkUserCredentials(String username,String password) async {
    try{
      QuerySnapshot querySnapshot = await usersCollection.where('email', isEqualTo: username)
          .where('password', isEqualTo: password).get();
      if(querySnapshot.docs.isNotEmpty){
        return true;
      }else{
        return false;
      }
    }catch(e){
     throw e;
    }
  }

  void saveUserNameAndPassword(BuildContext context,String username,String password){
    storage.write('username', username);
    storage.write('password', password);
    Navigator.pushNamed(context, 'homescreen');
  }

}