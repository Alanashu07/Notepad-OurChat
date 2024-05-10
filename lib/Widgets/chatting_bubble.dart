import 'package:flutter/material.dart';
import 'package:notepad/Constants/date_util.dart';
import 'package:notepad/Models/message_model.dart';
import 'package:notepad/Providers/user_provider.dart';
import 'package:notepad/Screens/image_viewer.dart';
import 'package:notepad/Screens/video_message_viewer.dart';
import 'package:notepad/Services/message_services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../Styles/app_style.dart';
import '../main.dart';

class ChatBubble extends StatefulWidget {
  final Message message;
  final VoidCallback onSuccess;
  final String progress;

  const ChatBubble({super.key, required this.message, required this.onSuccess, required this.progress});

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  late VideoPlayerController _videoPlayerController;
  MessageServices messageServices = MessageServices();

  @override
  void initState() {
    _videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.message.text))
          ..initialize().then((_) => setState(() {}));
    _videoPlayerController.setLooping(false);
    _videoPlayerController.setVolume(1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    return user.id == widget.message.sender ? sendBubble(widget.progress) : receiveBubble(widget.onSuccess, widget.progress);
  }

  Widget sendBubble(String progress) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              widget.message.readAt!.isNotEmpty
                  ? Icon(
                      Icons.done_all,
                      color: isLightTheme(context)
                          ? LightMode.accentColor
                          : Colors.white,
                    )
                  : widget.message.sentAt.isNotEmpty
                      ? Icon(
                          Icons.done,
                          color: isLightTheme(context)
                              ? LightMode.accentColor
                              : Colors.white,
                        )
                      : SizedBox(),
              SizedBox(
                width: 10,
              ),
              Text(DateUtil.getFormattedTime(
                  context: context, time: widget.message.sentAt)),
            ],
          ),
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
                color: isLightTheme(context)
                    ? Colors.greenAccent[400]
                    : Colors.black,
                border: Border.all(
                    color: isLightTheme(context)
                        ? Colors.tealAccent
                        : Colors.white70),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                )),
            child:
                widget.message.type == 'image' || widget.message.type == 'gif'
                    ? GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => ImageViewer(
                                      text: 'Image',
                                      image: widget.message.text)));
                        },
                        child: Image.network(
                          widget.message.text,
                          height: mq.height * .3,
                          fit: BoxFit.cover,
                        ))
                    : widget.message.type == 'video'
                        ? GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => VideoMessageViewer(
                                          message: widget.message)));
                            },
                            child: Stack(
                              children: [
                                AspectRatio(
                                  aspectRatio:
                                      _videoPlayerController.value.aspectRatio,
                                  child: VideoPlayer(_videoPlayerController),
                                ),
                                Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: CircleAvatar(
                                        radius: 15,
                                        backgroundColor: Colors.black38,
                                        child: Icon(
                                          Icons.play_arrow,
                                          color: Colors.white,
                                        )))
                              ],
                            ),
                          )
                        : Text(
                            widget.message.text,
                            style: TextStyle(
                                color: isLightTheme(context)
                                    ? Colors.black
                                    : Colors.white,
                                fontSize: 15),
                          ),
          ),
        )
      ],
    );
  }

  Widget receiveBubble(VoidCallback onSuccess, String progress) {
    if (widget.message.readAt!.isEmpty) {
      messageServices.updateReadStatus(
          context: context,
          message: widget.message,
          readAt: DateTime.now().millisecondsSinceEpoch.toString(),
          onSuccess: onSuccess);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
                color:
                    isLightTheme(context) ? Colors.blue.shade300 : Colors.white,
                border: Border.all(
                    color: isLightTheme(context)
                        ? Colors.lightBlue
                        : Colors.black54),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                )),
            child:
                widget.message.type == 'image' || widget.message.type == 'gif'
                    ? GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => ImageViewer(
                                      text: 'Image',
                                      image: widget.message.text)));
                        },
                        child: Image.network(
                          widget.message.text,
                          height: mq.height * .3,
                          fit: BoxFit.cover,
                        ))
                    : widget.message.type == 'video'
                        ? GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => VideoMessageViewer(
                                          message: widget.message)));
                            },
                            child: Stack(
                              children: [
                                AspectRatio(
                                  aspectRatio:
                                      _videoPlayerController.value.aspectRatio,
                                  child: VideoPlayer(_videoPlayerController),
                                ),
                                Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: CircleAvatar(
                                        radius: 15,
                                        backgroundColor: Colors.black38,
                                        child: progress.isEmpty ? Icon(
                                          Icons.play_arrow,
                                          color: Colors.white,
                                        ): Text(progress, style: TextStyle(color: Colors.white),)))
                              ],
                            ),
                          )
                        : Text(
                            widget.message.text,
                            style: TextStyle(color: Colors.black, fontSize: 15),
                          ),
          ),
        ),
        Text(DateUtil.getFormattedTime(
            context: context, time: widget.message.sentAt))
      ],
    );
  }
}
