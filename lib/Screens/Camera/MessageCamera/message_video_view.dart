import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';
import '../../../main.dart';


class MessageVideoView extends StatefulWidget {
  final String path;

  const MessageVideoView({
    super.key,
    required this.path,
  });

  @override
  State<MessageVideoView> createState() => _MessageVideoViewState();
}

class _MessageVideoViewState extends State<MessageVideoView> {
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.file(File(widget.path))
      ..initialize().then((_) => setState(() {}));
    _videoPlayerController.setLooping(true);
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
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.crop_rotate),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.emoji_emotions_outlined),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.title),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.edit),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
              child: AspectRatio(
                aspectRatio: _videoPlayerController.value.aspectRatio,
                child: VideoPlayer(_videoPlayerController),
              )
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: mq.width,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              child: TextFormField(
                textCapitalization: TextCapitalization.sentences,
                minLines: 1,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                style: TextStyle(color: Colors.white, fontSize: 17),
                decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.add_photo_alternate,
                        color: Colors.white,
                      ),
                    ),
                    hintText: "Add caption...",
                    hintStyle: TextStyle(color: Colors.white, fontSize: 17),
                    suffixIcon: IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.done,
                        color: Colors.white,
                      ),
                    )),
              ),
            ),
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
