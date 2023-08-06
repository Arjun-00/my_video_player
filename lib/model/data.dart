import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  late String? id;
  final String? name;
  final String? dateofbirth;
  final String? email;
  final String? phonenumber;
  final String? password;
  final String? imageUrl;

  User({required this.name,required this.dateofbirth , required this.email,required this.phonenumber,required this.password,this.imageUrl});

  factory User.fromSnapshot(QueryDocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return User(
      name: data['name'] as String,
      dateofbirth: data['dateofbirth'] as String,
      email: data['email'] as String,
      phonenumber: data['phonenumber'] as String,
      password: data['password'] as String,
      imageUrl: data['imageUrl'] as String
    );
  }
}