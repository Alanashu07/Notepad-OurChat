import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notepad/Screens/Camera/video_view.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../../Models/message_model.dart';
import '../../Models/user_model.dart';
import '../../main.dart';
import 'camera_view.dart';

late List<CameraDescription> cameras;

class CameraScreen extends StatefulWidget {
  final User user;
  final User chatUser;
  final List<Message> messages;
  const CameraScreen({super.key, required this.user, required this.chatUser, required this.messages});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {

  late CameraController _cameraController;
  late Future<void> cameraValue;
  bool isRecording = false;
  String? videoPath;
  bool flash = false;
  bool isCameraFront = true;

  @override
  void initState() {
    super.initState();
    _cameraController = CameraController(cameras[0], ResolutionPreset.high);
    cameraValue = _cameraController.initialize();
  }

  @override
  void dispose() {
    super.dispose();
    _cameraController.dispose();
  }

  void _startVideoRecording()async{
    if(!isRecording) {
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      try {
        await _cameraController.initialize();
        await _cameraController.startVideoRecording();
        setState(() {
          isRecording = true;
          videoPath = path;
        });
      }
      catch(e) {print(e); return;}
    }
  }

  void _stopVideoRecording(BuildContext context) async{
    if(isRecording) {
      final XFile videoFile = await _cameraController.stopVideoRecording();
      setState(() {
        isRecording = false;
      });

      if(videoPath!.isNotEmpty) {
        final File file = File(videoFile.path);
        await file.copy(videoPath!);
        Navigator.push(context, MaterialPageRoute(builder: (_)=> VideoView(path: videoPath!, user: widget.user, chatUser: widget.chatUser, messages: widget.messages,)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(future: cameraValue, builder: (context, snapshot){
              if(snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(_cameraController);
              } else {
                return Center(child: CircularProgressIndicator(),);
              }
            }),
          ),
          Container(
            color: Colors.black,
            width: mq.width,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(onPressed: (){
                      setState(() {
                        flash = !flash;
                      });
                      flash ? _cameraController.setFlashMode(FlashMode.torch) : _cameraController.setFlashMode(FlashMode.off);
                    }, icon: Icon(flash ? Icons.flash_on :Icons.flash_off, color: Colors.white, size: 28,)),
                    GestureDetector(
                      onLongPress: _startVideoRecording,
                        onLongPressUp: (){
                          _stopVideoRecording(context);
                        },
                        onLongPressCancel: (){
                          _stopVideoRecording(context);
                        },
                        onTap: ()async {
                        if(!isRecording) {
                          final path = join((await getTemporaryDirectory()).path, "${DateTime.now()}.png");
                          final image = await _cameraController.takePicture();
                          Navigator.push(context, MaterialPageRoute(builder: (_)=> CameraViewScreen(image: image, user: widget.user, chatUser: widget.chatUser, messages: widget.messages,)));}
                        },
                        child: isRecording ? Icon(Icons.radio_button_on, color: Colors.red, size: 80,) : Icon(Icons.panorama_fish_eye, size: 70,)),
                    IconButton(onPressed: () async {
                      setState(() {
                        isCameraFront = !isCameraFront;
                      });
                      int cameraPos = isCameraFront ? 0 : 1;
                      _cameraController = CameraController(cameras[cameraPos], ResolutionPreset.high);
                      cameraValue = _cameraController.initialize();
                    }, icon: Icon(CupertinoIcons.camera_rotate, size: 28,))
                  ],
                ),
                Text("Tap for Photo, Hold for Video", style: TextStyle(color: Colors.white),)
              ],
            ),
          )
        ],
      ),
    );
  }
}
