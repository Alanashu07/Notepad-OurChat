import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notepad/Services/message_services.dart';
import 'package:notepad/Services/user_services.dart';
import 'package:video_player/video_player.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../Models/message_model.dart';
import '../../Models/user_model.dart';
import '../../main.dart';

class VideoView extends StatefulWidget {
  final String path;
  final User user;
  final User chatUser;
  final List<Message> messages;

  const VideoView({
    super.key,
    required this.path,
    required this.user,
    required this.chatUser,
    required this.messages,
  });

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  late VideoPlayerController _videoPlayerController;
  late IO.Socket socket;
  MessageServices messageServices = MessageServices();
  UserService userService = UserService();
  late String? pushToken = '';

  getUserPushToken() async {
    pushToken = await userService.getPushToken(
        context: context, id: widget.chatUser.id);
  }

  @override
  void initState() {
    connect();
    super.initState();
    _videoPlayerController = VideoPlayerController.file(File(widget.path))
      ..initialize().then((_) => setState(() {}));
    _videoPlayerController.setLooping(true);
    _videoPlayerController.setVolume(1);
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController.dispose();
  }

  void connect() {
    // Initialize the Socket.io connection
    socket = IO.io(uri, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false
    });
    // Connect to the server
    socket.connect();
  }

  void sendVideo(String type, String video) {
    socket.emit('message', {
      'senderId': widget.user.id,
      'receiverId': widget.chatUser.id,
      'text': mediaUrl,
      'type': type,
      'readAt': '',
      'sentAt': DateTime.now().millisecondsSinceEpoch.toString()
    });
    messageServices.sendVideo(
        context: context,
        senderId: widget.user.id,
        receiverId: widget.chatUser.id,
        type: type,
        readAt: '',
        sentAt: DateTime.now().millisecondsSinceEpoch.toString(),
        path: video,
        user: widget.user,
        chatUser: widget.chatUser,
        pushToken: pushToken!,
        onSuccess: () {
          messageServices.sendPushNotification(
              context: context,
              pushToken: pushToken!,
              message: Message(
                  sender: widget.user.id,
                  receiver: widget.chatUser.id,
                  text: mediaUrl,
                  type: type,
                  readAt: '',
                  sentAt: DateTime.now().millisecondsSinceEpoch.toString()),
              user: widget.user);
          Navigator.pop(context);
          Navigator.pop(context);
        });
    setState(() {
      widget.messages.add(Message(
          sender: widget.user.id,
          receiver: widget.chatUser.id,
          text: mediaUrl,
          type: type,
          readAt: '',
          sentAt: DateTime.now().millisecondsSinceEpoch.toString()));
    });
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
          )),
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
                      onPressed: () => sendVideo('video', widget.path),
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
                  child: IconButton(
                      onPressed: () {
                        setState(() {
                          _videoPlayerController.value.isPlaying
                              ? _videoPlayerController.pause()
                              : _videoPlayerController.play();
                        });
                      },
                      icon: Icon(
                        _videoPlayerController.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        size: 50,
                        color: Colors.white,
                      ))))
        ],
      ),
    );
  }
}
