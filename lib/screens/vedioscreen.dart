import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:dio/dio.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:file_cryptor/file_cryptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import '../model/videoclass.dart';

class VedioScreen extends StatefulWidget {
  const VedioScreen({Key? key}) : super(key: key);

  @override
  State<VedioScreen> createState() => _VedioScreenState();
}

class _VedioScreenState extends State<VedioScreen> {

  var scaffoldKey = GlobalKey<ScaffoldState>();
  bool _ontab = false;
  late List<VideoClass> videos;
  String? streamVideo;
  int selectedIndex =0;
  late VideoClass currentVideoInfo;
  Directory directory= Directory('/storage/emulated/0/Download');
  late File file;
  FileCryptor fileCryptor = FileCryptor(
    key: "0IfSLn8F33SIiWlYTyT4j7n6jnNP74xN",
    iv: 16,
    dir: "/storage/emulated/0/Download",
  );
  final storage = GetStorage();
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  double _currentVolume = 1.0;
  bool _showSettings = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    videoData();
    _videoPlayerController = VideoPlayerController.network("http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4");
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: false,
      looping: true,
      aspectRatio: 16 / 9,
      showControls: false,
    );
    disableCapture();
    currentVideoInfo = videos[0];
    file = File(directory.path+"/${currentVideoInfo.videoname}.mp4");
   // streamInitialize();
  }

  @override
  void dispose() {
    _chewieController.dispose();
    _videoPlayerController.dispose();
    videos.clear();
    file.delete();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  child: Chewie(
                    controller: _chewieController,
                  ),
                ),
                SizedBox(height: 25.0,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: Material(
                        color: Colors.black12, // Button color
                        child: InkWell(
                          splashColor: Colors.grey, // Splash color
                          onTap: () {
                            if(selectedIndex <= videos.length - 1 && selectedIndex > 0)
                            {
                              setState(() {
                                File(directory.path+"/${currentVideoInfo.videoname}.mp4").delete();
                                selectedIndex = selectedIndex -1;
                                currentVideoInfo = videos[selectedIndex];
                                streamVideo = videos[selectedIndex].videoUrl;
                              });
                              compareOnlineStreamOrStorageStream();
                            }
                          },
                          child: const SizedBox(width: 40, height: 40, child: Icon(Icons.arrow_back_ios,size: 17,)),
                        ),
                      ),
                    ),

                    RaisedButton(
                      color: Colors.white,
                      padding: const EdgeInsets.only(left: 15,right: 15,top: 8,bottom: 8),
                      onPressed: () async{
                        if(_ontab == false){
                          setState(() {_ontab = true;});
                        }else{
                          setState(() {_ontab = false;});
                        }

                        Map<Permission, PermissionStatus> statuses = await [Permission.storage, Permission.videos].request();

                        if(await File(directory.path+"/${currentVideoInfo.videoname}.mp4").exists() == true)
                        {
                          dialogBox(context,"Warning", "Already Downloaded File... !");
                        }else{
                          if(statuses[Permission.storage]!.isGranted){
                            var dir = await DownloadsPathProvider.downloadsDirectory;
                            if(dir != null){
                              String savename = "${currentVideoInfo.videoname}.mp4";
                              String savePath = dir.path + "/$savename";
                              //output:  /storage/emulated/0/Download/banner.png
                              try {
                                await Dio().download(currentVideoInfo.videoUrl, savePath,
                                    onReceiveProgress: (received, total) {
                                      if (total != -1) {
                                        print((received / total * 100).toStringAsFixed(0) + "%");
                                      }
                                    });
                                dialogBox(context,"Sucessfull","File Downloaded..!");
                                File encryptedFile = await fileCryptor.encrypt(inputFile: "${currentVideoInfo.videoname}.mp4", outputFile: "${currentVideoInfo.videoname}.aes");
                                File(directory.path+"/${currentVideoInfo.videoname}.mp4").delete();
                              } on DioError catch (e) {
                                dialogBox(context,"Warning", e.message);
                              }
                            }
                          }else{
                            dialogBox(context,"Permission", "No permission to read and write !");
                          }
                        }
                      },
                      child:  Row(
                        children: const <Widget>[
                          Icon(Icons.download,size: 19,color: Colors.green,),
                          SizedBox(width: 10,),
                          Text("Download"),
                        ],
                      ),
                    ),

                    ClipOval(
                      child: Material(
                        color: Colors.black12,
                        child: InkWell(
                          splashColor: Colors.grey,
                          onTap: () {
                            if(selectedIndex < videos.length - 1 && selectedIndex >= 0)
                            {
                              setState(() {
                                File(directory.path+"/${currentVideoInfo.videoname}.mp4").delete();
                                selectedIndex = selectedIndex +1;
                                currentVideoInfo = videos[selectedIndex];
                                streamVideo = videos[selectedIndex].videoUrl;
                              });
                              compareOnlineStreamOrStorageStream();
                            }
                          },
                          child: const SizedBox(width: 40, height: 40, child: Icon(Icons.arrow_forward_ios,size: 17,)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0,),
                Container(
                  height: MediaQuery.of(context).size.height * .65,
                  width: MediaQuery.of(context).size.width * 1,
                  child: ListView.separated(
                      separatorBuilder: (context, index) => const SizedBox(height: 10,),
                      shrinkWrap: true,
                      itemCount: videos.length,
                      itemBuilder: (context,index){
                        return Padding(
                          padding: const EdgeInsets.only(left: 20,right: 20),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color:index == selectedIndex ? Colors.blue : Colors.black26,
                            ),
                            padding: const EdgeInsets.only(top: 5,bottom: 5),
                            width: MediaQuery.of(context).size.width * 1,
                            //color: Colors.green,
                            child: ListTile(
                              leading: InkWell(
                                onTap: () async{
                                  setState(() {
                                    selectedIndex = index;
                                   File(directory.path+"/${currentVideoInfo.videoname}.mp4").delete();
                                    currentVideoInfo = videos[index];
                                    streamVideo = videos[index].videoUrl;
                                    acessingFilefromInternalStoraqge(videos[index].videoUrl);
                                  });
                                  //compareOnlineStreamOrStorageStream(streamVideo!);
                                },
                                child: ConstrainedBox(
                                    constraints: const BoxConstraints(minWidth: 50, minHeight: 50),
                                    child: Image.asset(videos[index].image, width: 50, height: 50,)),
                              ),
                              title: Text(videos[index].videoname, style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold,color: Colors.white),),
                              subtitle: Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Text(videos[index].videoid.toString(), style: const TextStyle(fontWeight: FontWeight.bold),),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                  ),
                ),
              ],
            ),

            // _ontab == true ? const SizedBox(): Positioned(
            //   top: 55,
            //   right: 20,
            //   child: GestureDetector(
            //     onTap: () => scaffoldKey.currentState!.openDrawer(),
            //     child: Container(
            //       height: 50,
            //       width: 50,
            //       decoration: BoxDecoration(
            //         borderRadius: BorderRadius.circular(7),
            //       ),
            //       child: ClipRRect(
            //           borderRadius: BorderRadius.circular(7),
            //           child: Image.asset("assets/icons.png", fit: BoxFit.cover,)
            //       ),
            //     ),
            //   ),
            // ),

            // Container(
            //     color: Colors.transparent,
            //     padding: EdgeInsets.only(top: 130,left: 16,right: 16),
            //     child: Column(
            //       children: [
            //         Row(
            //           children: [
            //             GestureDetector(
            //               child : Icon(
            //                 _videoPlayerController.value.isPlaying
            //                     ? Icons.pause
            //                     : Icons.play_arrow,size: 35,
            //               ),
            //               onTap: () {
            //                 setState(() {
            //                   if (_videoPlayerController.value.isPlaying) {
            //                     _videoPlayerController.pause();
            //                   } else {
            //                     _videoPlayerController.play();
            //                   }
            //                 });
            //               },
            //             ),
            //             Expanded(
            //               child: VideoProgressIndicator(
            //                 _videoPlayerController,
            //                 allowScrubbing: true, // Enable seeking
            //               ),
            //             ),
            //           ],
            //         ),
            //
            //         // SizedBox(height: 8,),
            //         //
            //         // Padding(padding: EdgeInsets.only(left: 60),
            //         //   child: Row(
            //         //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         //     children: [
            //         //       Row(
            //         //         children: [
            //         //           GestureDetector(
            //         //               child: Icon(Icons.skip_previous_outlined,),
            //         //               onTap: () {
            //         //
            //         //               }),
            //         //           SizedBox(width: 5,),
            //         //           GestureDetector(
            //         //               child: Icon(Icons.skip_next_outlined,),
            //         //               onTap: () {
            //         //
            //         //               }),
            //         //           SizedBox(width: 5,),
            //         //           GestureDetector(
            //         //               child: Icon(_currentVolume > 0.0
            //         //                   ? Icons.volume_up
            //         //                   : Icons.volume_off,),
            //         //               onTap: () {
            //         //                 setState(() {
            //         //                   _currentVolume = _currentVolume > 0.0 ? 0.0 : 1.0;
            //         //                   _videoPlayerController.setVolume(_currentVolume);
            //         //                 });
            //         //               }),
            //         //         ],
            //         //       ),
            //         //
            //         //       Row(
            //         //         children: [
            //         //           GestureDetector(
            //         //               child: Icon(Icons.settings,),
            //         //               onTap: () {
            //         //                 setState(() {
            //         //                   _showSettings = !_showSettings;
            //         //                 });
            //         //               }),
            //         //           SizedBox(width: 5,),
            //         //           GestureDetector(
            //         //               child: Icon( _chewieController.isFullScreen
            //         //                   ? Icons.fullscreen_exit
            //         //                   : Icons.fullscreen,),
            //         //               onTap: () {
            //         //                 setState(() {
            //         //                   _chewieController.toggleFullScreen();
            //         //                 });
            //         //               }),
            //         //         ],
            //         //       )
            //         //     ],
            //         //   ),
            //         // ),
            //       ],
            //     )
            // ),

          ],
        ),
      ),
    );
  }

  void acessingFilefromInternalStoraqge(String urls) async{
    if(await File(directory.path+"/${currentVideoInfo.videoname}.aes").exists() == true){
      File decryptedFile = await fileCryptor.decrypt(inputFile: "${currentVideoInfo.videoname}.aes", outputFile: "${currentVideoInfo.videoname}.mp4");
      file = File(directory.path+"/${currentVideoInfo.videoname}.mp4");
    }
    if(await File(directory.path+"/${currentVideoInfo.videoname}.mp4").exists() == true) {
      _videoPlayerController = VideoPlayerController.file(file);
      // flickManager.handleChangeVideo(VideoPlayerController.file(file));
    }else{

      //  flickManager.handleChangeVideo(VideoPlayerController.network(streamVideo));
    }

    setState(() {
      _videoPlayerController = VideoPlayerController.network(urls);
      // _chewieController = ChewieController(
      //   videoPlayerController: _videoPlayerController,
      //   autoPlay: true,
      //   looping: true,
      //   // Other customization options can be set here
      // );
    });


  }

   void compareOnlineStreamOrStorageStream() async{

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

  // Future<void> streamInitialize(String urls) async {
  //   if( File(directory.path+"/${currentVideoInfo.videoname}.mp4").exists() == true){
  //     _videoPlayerController = VideoPlayerController.file(file);
  //     //flickManager = FlickManager(videoPlayerController:VideoPlayerController.file(file));
  //   }else{
  //     _videoPlayerController = VideoPlayerController.network(urls);
  //    // flickManager = FlickManager(videoPlayerController: VideoPlayerController.network(streamVideo),);
  //   }
  //   await _videoPlayerController.initialize();
  //
  //   _chewieController = ChewieController(
  //     videoPlayerController: _videoPlayerController,
  //     autoPlay: true,
  //     looping: true,
  //     // Other customization options can be set here
  //   );
  //
  //   setState(() {});
  // }

  void dialogBox(BuildContext context,String heading,String content){
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(heading),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Container(
              // color: Colors.blueAccent,
              padding: const EdgeInsets.only(left: 5,right: 5,top: 2,bottom: 2),
              child: const Text("OK"),
            ),
          ),
        ],
      ),
    );
  }

  ///method for prevent screenshot
  Future<void> disableCapture() async {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }
}