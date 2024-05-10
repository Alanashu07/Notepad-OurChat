import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notepad/Services/message_services.dart';
import 'package:video_player/video_player.dart';
import '../../Models/message_model.dart';
import '../../main.dart';

class VideoMessageViewer extends StatefulWidget {

  final Message message;

  const VideoMessageViewer({
    super.key, required this.message,
  });

  @override
  State<VideoMessageViewer> createState() => _VideoMessageViewerState();
}

class _VideoMessageViewerState extends State<VideoMessageViewer> {
  late VideoPlayerController _videoPlayerController;
  MessageServices messageServices = MessageServices();

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.message.text))
      ..initialize().then((_) => setState(() {}));
    _videoPlayerController.setLooping(true);
    _videoPlayerController.setVolume(1);
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          Container(
              child: AspectRatio(
                aspectRatio: _videoPlayerController.value.aspectRatio,
                child: VideoPlayer(_videoPlayerController),
              )
          ),
          Align(
              alignment: Alignment.center,
              child: CircleAvatar(
                  radius: 33,
                  backgroundColor: Colors.black38,
                  child: IconButton(onPressed: (){
                    setState(() {
                      _videoPlayerController.value.isPlaying? _videoPlayerController.pause() : _videoPlayerController.play();
                    });
                  }, icon: Icon(_videoPlayerController.value.isPlaying ? Icons.pause : Icons.play_arrow, size: 50, color: Colors.white,))))
        ],
      ),
    );
  }
}
