import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../model/data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<User>? userList1 = [];
  String? names;
  String? emails;
  String? phonenumbers;

  // final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('userdata');



  Future<List<User>> checkIfEmailExists(String email) async {
    List<User> userList = [];
    try {
      QuerySnapshot querySnapshot = await usersCollection.where('email', isEqualTo: email).get();
      print(querySnapshot.toString());
      print(querySnapshot.docs);
      if (querySnapshot.docs.isNotEmpty) {
        querySnapshot.docs.forEach((QueryDocumentSnapshot documentSnapshot) {
          User user = User.fromSnapshot(documentSnapshot);
          userList.add(user);
        });
      } else {
        print('No users found.');
      }

    } catch (e) {
      print('Error checking email existence: $e');
    }
    return userList;
  }

  Future<void> udateFireData() async {
    try {
      userList1 = await  checkIfEmailExists("arjunnarikkuni00@gmail.com");
    } catch (e) {
      print('An error occurred: $e');
    }
  }


  @override
  void initState() {
    udateFireData();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 15),
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: Column(
            children: [
              Card(
                elevation: 4.0,
                margin: EdgeInsets.all(16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        'https://farm2.staticflickr.com/1533/26541536141_41abe98db3_z_d.jpg',
                        width: double.infinity,
                        height: 200.0,
                        fit: BoxFit.cover,
                      ),
                      // const Padding(
                      //   padding: EdgeInsets.only(left: 16,top: 16,bottom: 7),
                      //   child: Text("Name :", style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold),),
                      // ),
                      // const Padding(
                      //   padding: EdgeInsets.only(left: 16,top: 8,bottom: 7),
                      //   child: Text("Username : ", style: TextStyle(fontSize: 16.0),),
                      // ),
                      // const Padding(
                      //   padding: EdgeInsets.only(left: 16,top: 8,bottom: 16),
                      //   child: Text("Phonenumber : ", style: TextStyle(fontSize: 16.0),),
                      // ),
                      FutureBuilder<List<User>>(
                        future: checkIfEmailExists("arjunnarikkuni00@gmail.com"), // Replace with the email you want to check
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                                child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator(color: Colors.green,))); // Show loading indicator while fetching data
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Text('No user found with the specified email.');
                          } else {
                            User user = snapshot.data![0]; // Assuming you only want to display the first user
                            return Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                "Name : ${user.name}\nPhone Number : ${user.phonenumber}\nEmail : ${user.email}",
                                style: TextStyle(fontSize: 16),
                              ),
                            );
                          }
                        },
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),

      ),
    );
  }
}
