import 'package:flutter/material.dart';
import 'package:notepad/Models/message_model.dart';
import 'package:notepad/Screens/image_viewer.dart';
import 'package:video_player/video_player.dart';

import '../Screens/video_message_viewer.dart';
import '../main.dart';

class MediaCard extends StatefulWidget {
  final Message message;
  const MediaCard({super.key, required this.message});

  @override
  State<MediaCard> createState() => _MediaCardState();
}

class _MediaCardState extends State<MediaCard> {

  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.message.text))
      ..initialize().then((_) => setState(() {}));
    _videoPlayerController.setLooping(false);
    _videoPlayerController.setVolume(1);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Container(
          height: mq.height * .3,
          width: mq.width * .3,
          child: widget.message.type == 'video' ? GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (_)=> VideoMessageViewer(message: widget.message)));
            },
            child: Stack(
              children: [
                AspectRatio(aspectRatio: 1, child: VideoPlayer(_videoPlayerController),),
                Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.black38,
                        child: Icon(Icons.play_arrow, color: Colors.white,)))
              ],
            ),
          ) :GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (_)=> ImageViewer(text: 'Image', image: widget.message.text)));
            },
            child: Image.network(
              widget.message.text,
              fit: BoxFit.cover,
            ),
          ),
        ));
  }
}
