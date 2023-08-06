import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get_storage/get_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);


  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('userdata');
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController =  TextEditingController();
  final TextEditingController passwordController =  TextEditingController();
  final storage = GetStorage();
  String? errorMessage;

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
      print(e);
      return false;
    }
  }

  Future<void> secureScreen() async {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
  }
  @override
  void initState() {
    secureScreen();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //email field
    final emailField = TextFormField(
        autofocus: false,
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value!.isEmpty) {
            return ("Please Enter Your Email");
          }
          if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
              .hasMatch(value)) {
            return ("Please Enter a valid email");
          }
          return null;
        },
        onSaved: (value) {
          emailController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.mail),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Email",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    //password field
    final passwordField = TextFormField(
        autofocus: false,
        controller: passwordController,
        obscureText: true,
        validator: (value) {
          RegExp regex = RegExp(r'^.{6,}$');
          if (value!.isEmpty) {
            return ("Password is required for login");
          }
          if (!regex.hasMatch(value)) {
            return ("Enter Valid Password(Min. 6 Character)");
          }
        },
        onSaved: (value) {
          passwordController.text = value!;
        },
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.vpn_key),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Password",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    final loginButton = SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              primary: Colors.green.shade600,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
          onPressed: () async {
            if (validateAndSave()) {
              bool isCredentialsValid = await checkUserCredentials(emailController.text,passwordController.text);
             if(isCredentialsValid){
               storage.write('username', emailController.text);
               storage.write('password', passwordController.text);
               Navigator.pushNamed(context, 'homescreen');
             }else{
               print("User not exist");
             }
              // try {
              //   final user = await _auth.signInWithEmailAndPassword(
              //       email: emailController.text, password: passwordController.text);
              //   if (user != null) {
              //     storage.write('username', emailController.text);
              //     storage.write('password', passwordController.text);
              //     Navigator.pushNamed(context, 'homescreen');
              //   }
              // } catch (e) {
              //   print(e);
              // }
            }
          },
          child: const Text("Login",style: TextStyle(fontSize: 16),)),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                        height: 100,
                        child: Image.asset(
                          "assets/icons.png",
                          fit: BoxFit.contain,
                        )),
                    const SizedBox(height: 45),
                    emailField,
                    const SizedBox(height: 25),
                    passwordField,
                    const SizedBox(height: 35),
                    loginButton,
                    const SizedBox(height: 20),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text("Don't have an account? "),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, 'signupscreen');
                            },
                            child: const Text("SignUp", style: TextStyle(
                                color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17),
                            ),
                          )
                        ])
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form!.validate()) {
      return true;
    }
    return false;
  }

// login function
// void signIn(String email, String password) async {
//   if (_formKey.currentState!.validate()) {
//     try {
//       await _auth
//           .signInWithEmailAndPassword(email: email, password: password)
//           .then((uid) => {
//         Fluttertoast.showToast(msg: "Login Successful"),
//         Navigator.of(context).pushReplacement(
//             MaterialPageRoute(builder: (context) => HomeScreen())),
//       });
//     } on FirebaseAuthException catch (error) {
//       switch (error.code) {
//         case "invalid-email":
//           errorMessage = "Your email address appears to be malformed.";
//
//           break;
//         case "wrong-password":
//           errorMessage = "Your password is wrong.";
//           break;
//         case "user-not-found":
//           errorMessage = "User with this email doesn't exist.";
//           break;
//         case "user-disabled":
//           errorMessage = "User with this email has been disabled.";
//           break;
//         case "too-many-requests":
//           errorMessage = "Too many requests";
//           break;
//         case "operation-not-allowed":
//           errorMessage = "Signing in with Email and Password is not enabled.";
//           break;
//         default:
//           errorMessage = "An undefined Error happened.";
//       }
//       Fluttertoast.showToast(msg: errorMessage!);
//       print(error.code);
//     }
//   }
// }
}