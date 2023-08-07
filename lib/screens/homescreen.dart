import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_cryptor/file_cryptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_video_player/provider/homescreenprovider.dart';
import 'package:my_video_player/screens/vedioplayer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../model/data.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import '../model/videoclass.dart';
import '../themeclass/themestate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? userList1;
  String? names;
  String? emails;
  String? phoneNO;
  String? id;
  String? dateofbirth;
  String? passwordes;
  String? imageUrl;
  String? username;
  img.Image? decodedImage;
  late Future<User?> _userFuture;
  late List<VideoClass> videos;
  final storage = GetStorage();
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('userdata');
  File? _imageFile;
  final picker = ImagePicker();
  late File file;
  Directory directory= Directory('/storage/emulated/0/Download');
  FileCryptor fileCryptor = FileCryptor(
    key: "0IfSLn8F33SIiWlYTyT4j7n6jnNP74xN",
    iv: 16,
    dir: "/storage/emulated/0/Download",
  );

  Future<void> secureScreen() async {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }
  @override
  Future<void> dispose() async {
    super.dispose();
    await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
  }
  void readLoginUser(){
    username = storage.read('username');
  }

  Future<void> _pickImage() async {
    var status = await Permission.photos.status;
    if (status.isDenied) {
    Map<Permission, PermissionStatus> statuses = await [Permission.photos,].request();
     }else{
      final pickedFile = await picker.getImage(source: ImageSource.gallery);
      setState(() {
        if (pickedFile != null) {
          _imageFile = File(pickedFile.path);
          if (_imageFile != null) {
            try {
              updateDonor(id);
              setState(() {
                _userFuture = checkIfEmailExists(username!);
                if (imageUrl != null) {
                  fetchAndDecodeImage(imageUrl!);
                }
                decodedImage;
              });
            }catch(e){
              print("Erroe happening....!");
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Image uploaded successfully!')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please select an image first.')),
            );
          }
        }
      });
    }
  }

  Future<User?> checkIfEmailExists(String email) async {
    User? userList;
    try {
      QuerySnapshot querySnapshot = await usersCollection.where('email', isEqualTo: email).get();
      if (querySnapshot.docs.isNotEmpty) {
        querySnapshot.docs.forEach((QueryDocumentSnapshot documentSnapshot) {
          Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
          String name = data['name'] ?? ''; // Handle null values
          String? dob = data['dateofbirth'] ?? '';
          String phonenumber = data['phonenumber'] ?? '';
          String? password = data['password'] ?? '';
          String? imageUrl = data['imageUrl'] ?? '';
          User user = User(
            name: name,
            dateofbirth: dob,
            email: data['email'] ?? '', // Handle email null value
            phonenumber: phonenumber,
            password: password,
            imageUrl: imageUrl ?? '',
          );
          user.id = documentSnapshot.id;
          userList = user;
          names = user.name;
          phoneNO = user.phonenumber;
          dateofbirth = user.dateofbirth;
          emails = user.email;
          id = user.id;
          passwordes = user.password;
          if(user.imageUrl!= null){
            imageUrl = user.imageUrl;
          }
        });
      } else {
        print('No users found.');
      }
    } catch (e) {
      print('Error checking email existence: $e');
    }
    return userList;
  }

  Future<void> fetchAndDecodeImage(String imageUrl) async {
    final response = await FirebaseStorage.instance.refFromURL(imageUrl).getData();
    setState(() {
      decodedImage = img.decodeImage(Uint8List.fromList(response!));
    });
  }

  void _logout(){
    storage.write('username',"");
    storage.write('password', '');
    Navigator.of(context).pushNamedAndRemoveUntil('loginscreen', (route) => false);
  }

  Future<void> updateDonor(docId) async {
    Reference storageReference = FirebaseStorage.instance.ref().child('images/${DateTime.now().toString()}');
    UploadTask uploadTask = storageReference.putFile(_imageFile!);
    TaskSnapshot storageSnapshot = await uploadTask.whenComplete(() => null);
    String imageUrl = await storageSnapshot.ref.getDownloadURL();
    final data = {
      'name' : names,
      'dateofbirth' : dateofbirth,
      'email' : emails,
      'phonenumber' : phoneNO,
      'password' : passwordes,
      'imageUrl' : imageUrl
    };
    usersCollection.doc(docId).update(data)
        .then((value) => setState(() {}) );
  }

  void videoData(){
    videos = [
      VideoClass(videoid: 1,videoUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",videoname: "Cartone CN",isDownload: false,image: "assets/icons.png"),
      VideoClass(videoid: 2,videoUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",videoname: "News -Live",isDownload: false,image: "assets/icons.png"),
      VideoClass(videoid: 3,videoUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",videoname: "Turisam",isDownload: false,image: "assets/icons.png"),
      VideoClass(videoid: 4,videoUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",videoname: "Films New",isDownload: false,image: "assets/icons.png"),
      VideoClass(videoid: 5,videoUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",videoname: "Technology",isDownload: false,image: "assets/icons.png"),
    ];
  }

  @override
  void initState() {
    videoData();
    secureScreen();
    readLoginUser();
    if(username!=null) {
      _userFuture = checkIfEmailExists(username!);
    }
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final homescreenprovider = Provider.of<HomeScreenProvider>(context);
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.green, Colors.black87],
                    ),
                  ),
                  child: FutureBuilder<User?>(
                    future:_userFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(color: Colors.green,))); // Show loading indicator while fetching data
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData) {
                        return Text('No user found with the specified email.');
                      } else {
                        User user = snapshot.data!;
                        if(user.imageUrl != null && decodedImage == null) {
                          fetchAndDecodeImage(user.imageUrl!);
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap:  _pickImage,
                              child: Container(
                                padding: EdgeInsets.all(10),
                                width: 80,
                                height: 80,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child:  _imageFile == null ?  decodedImage!= null ?
                                Image.memory(Uint8List.fromList(img.encodePng(decodedImage!))
                                ):Image.asset('assets/profile.png'): Image.file(_imageFile!),
                              ),
                            ),
                            SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Name : $names", style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white),),
                                SizedBox(height: 5,),
                                Text("Phone : $phoneNO", style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white)
                                ),
                                SizedBox(height: 5,),
                                Text("Date of birth : $dateofbirth", style: TextStyle(fontSize: 13,color: Colors.white)
                                ),
                                SizedBox(height: 5,),
                                Text("E-mail : $emails", style: TextStyle(fontSize: 13,color: Colors.white),),
                              ],
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ),

          Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Logout  : ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.red),),
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: SizedBox(
                          width: 50.0,
                          height: 50.0,
                          child: FloatingActionButton(
                            onPressed: () {
                              _logout();
                            },
                            child: Icon(Icons.logout),
                            backgroundColor: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Switch to Dark Mode : ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.black),),
                      Switch(value:Provider.of<ThemeState>(context).theme == ThemeType.DARK, onChanged: (value){
                        Provider.of<ThemeState>(context,listen: false).theme = value ? ThemeType.DARK : ThemeType.LIGHT;
                        setState(() {
                        });
                      }),
                    ],
                  ),

                  TextButton.icon(
                    onPressed: () {
                     Navigator.pushNamed(context, 'vedioscreen');
                    },
                    icon: Icon(Icons.video_call),
                    label: Text('Go to Video Player'),
                    style: TextButton.styleFrom(
                      primary: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0), // Adjust the corner radius here
                      ),
                    ),
                  ),
                ],
              )
            ),
          ),
              Container(
                padding: EdgeInsets.only(top: 20),
               // height: 200,
                width: double.infinity,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    VideoClass video = videos[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical:6,horizontal: 4 ),
                      child: ListTile(
                        onTap: () async{
                          var status = await Permission.storage.request();
                          Map<Permission, PermissionStatus> statuses = await [Permission.storage, Permission.videos].request();
                          if (statuses[Permission.storage]!.isGranted) {
                            if (await File(directory.path + "/${video.videoname}.aes").exists()) {
                              File decryptedFile = await fileCryptor.decrypt(
                                inputFile: "${video.videoname}.aes",
                                outputFile: "${video.videoname}.mp4",
                              );

                              file = File(directory.path + "/${video.videoname}.mp4");
                            }

                            if (await File(directory.path + "/${video.videoname}.mp4").exists()) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VideoPlayerScreen(
                                    videoUrl: "",
                                    localVideoPath: file,
                                    decodedImage: decodedImage,
                                    vedioName: video.videoname,
                                  ),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VideoPlayerScreen(
                                    videoUrl: video.videoUrl,
                                    localVideoPath: "",
                                    decodedImage: decodedImage,
                                    vedioName: video.videoname,
                                  ),
                                ),
                              );
                            }
                          } else {
                            Map<Permission, PermissionStatus> status = await [Permission.storage, Permission.videos].request();
                          }

                        },
                        leading: Image.asset(video.image),
                        title: Text(video.videoname),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
