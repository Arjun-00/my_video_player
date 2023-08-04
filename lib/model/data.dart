import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String name;
  final String lastname;
  final String email;
  final String phonenumber;
  final String password;

  User({required this.name,required this.lastname , required this.email,required this.phonenumber,required this.password});

  factory User.fromSnapshot(QueryDocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return User(
      name: data['name'] as String,
      lastname: data['lastname'] as String,
      email: data['email'] as String,
      phonenumber: data['phonenumber'] as String,
      password: data['password'] as String,
    );
  }
}