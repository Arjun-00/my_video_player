import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:file_cryptor/file_cryptor.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';


class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  dynamic localVideoPath;
  final String vedioName;
  dynamic decodedImage;

  VideoPlayerScreen({required this.videoUrl, required this.localVideoPath,this.decodedImage,required this.vedioName});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  double _currentVolume = 1.0;
  late File file;
  bool _ontab = false;
  FileCryptor fileCryptor = FileCryptor(
    key: "0IfSLn8F33SIiWlYTyT4j7n6jnNP74xN",
    iv: 16,
    dir: "/storage/emulated/0/Download",
  );
  Directory directory= Directory('/storage/emulated/0/Download');

  @override
  void initState() {
    super.initState();
    file = File(directory.path+"/${widget.vedioName}.mp4");
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        // Ensure the first frame is shown
        setState(() {
          _controller.play();
        });
      });

    // Uncomment this if you want to play a local video file
    // _controller = VideoPlayerController.asset(widget.localVideoPath)
    //   ..initialize().then((_) {
    //     // Ensure the first frame is shown
    //     setState(() {});
    //   });
  }

  @override
  void dispose() {
    super.dispose();
    file.delete();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(


        child:Stack(
          children: [
            Column(
              children: [
                _controller.value.isInitialized
                    ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
                    : Center(child: CircularProgressIndicator()),
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
                        if(await File(directory.path+"/${widget.vedioName}.mp4").exists() == true)
                        {
                          dialogBox(context,"Warning", "Already Downloaded File... !");
                        }else{
                          if(statuses[Permission.storage]!.isGranted){
                            var dir = await DownloadsPathProvider.downloadsDirectory;
                            if(dir != null){
                              String savename = "${widget.vedioName}.mp4";
                              String savePath = dir.path + "/$savename";
                              //output:  /storage/emulated/0/Download/banner.png
                              try {
                                await Dio().download(widget.videoUrl, savePath,
                                    onReceiveProgress: (received, total) {
                                      if (total != -1) {
                                        print((received / total * 100).toStringAsFixed(0) + "%");
                                      }
                                    });
                                dialogBox(context,"Sucessfull","File Downloaded..!");
                                File encryptedFile = await fileCryptor.encrypt(inputFile: "${widget.vedioName}.mp4", outputFile: "${widget.vedioName}.aes");
                                File(directory.path+"/${widget.vedioName}.mp4").delete();
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

                          },
                          child: const SizedBox(width: 40, height: 40, child: Icon(Icons.arrow_forward_ios,size: 17,)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0,),
              ],
            ),

            Positioned(
              top: 20,
              right: 20,
              child: GestureDetector(
                onTap: () => {},
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child:  widget.decodedImage != null ?
                  Image.memory(Uint8List.fromList(img.encodePng(widget.decodedImage))
                  ):Image.asset('assets/profile.png')
                ),
              ),
            ),

            Container(
                color: Colors.transparent,
                padding: EdgeInsets.only(top: 145,left: 16,right: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          child : Icon(
                            _controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,size: 35,
                          ),
                          onTap: () {
                            setState(() {
                              if (_controller.value.isPlaying) {
                                _controller.pause();
                              } else {
                                _controller.play();
                              }
                            });
                          },
                        ),
                        Expanded(
                          child: VideoProgressIndicator(
                            _controller,
                            allowScrubbing: true, // Enable seeking
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 8,),

                    Padding(padding: EdgeInsets.only(left: 60),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                  child: const Icon(Icons.skip_previous_outlined,),
                                  onTap: () {

                                  }),
                              const SizedBox(width: 5,),
                              GestureDetector(
                                  child: const Icon(Icons.skip_next_outlined,),
                                  onTap: () {

                                  }),
                              const SizedBox(width: 5,),
                              GestureDetector(
                                  child: Icon(
                                    _currentVolume > 0.0 ? Icons.volume_up :
                                    Icons.volume_off,),
                                  onTap: () {
                                    setState(() {
                                      _currentVolume = _currentVolume > 0.0 ? 0.0 : 1.0;
                                  _controller.setVolume(_currentVolume);
                                    });
                                  }),
                            ],
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                  child: const Icon(Icons.settings,),
                                  onTap: () {
                                    setState(() {

                                    });
                                  }),
                              const SizedBox(width: 5,),
                              GestureDetector(
                                  child: const Icon(Icons.fullscreen,),
                                  onTap: () {
                                    setState(() {

                                    });
                                  }),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                )
            ),
          ],
        )
      ),
    );
  }


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
}
