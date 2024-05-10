import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:notepad/Services/message_services.dart';
import 'package:notepad/Services/user_services.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../Models/message_model.dart';
import '../../Models/user_model.dart';
import '../../main.dart';

class CameraViewScreen extends StatefulWidget {
  final User user;
  final User chatUser;
  final XFile image;
  final List<Message> messages;

  const CameraViewScreen(
      {super.key,
      required this.image,
      required this.user,
      required this.chatUser,
      required this.messages});

  @override
  State<CameraViewScreen> createState() => _CameraViewScreenState();
}

class _CameraViewScreenState extends State<CameraViewScreen> {
  late IO.Socket socket;
  MessageServices messageServices = MessageServices();
  UserService userService = UserService();
  late String? pushToken = '';

  @override
  void initState() {
    connect();
    super.initState();
  }

  getUserPushToken() async {
    pushToken = await userService.getPushToken(
        context: context, id: widget.chatUser.id);
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

  void sendMediaMessage(String type, XFile image) {
    socket.emit('message', {
      'senderId': widget.user.id,
      'receiverId': widget.chatUser.id,
      'text': mediaUrl,
      'type': type,
      'readAt': '',
      'sentAt': DateTime.now().millisecondsSinceEpoch.toString()
    });
    messageServices.sendMediaMessage(
        context: context,
        senderId: widget.user.id,
        receiverId: widget.chatUser.id,
        type: type,
        readAt: '',
        sentAt: DateTime.now().millisecondsSinceEpoch.toString(),
        image: image,
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              child: InteractiveViewer(
                  clipBehavior: Clip.none,
                  child: Image.file(File(widget.image.path))),
            ),
            Container(
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
                      onPressed: () => sendMediaMessage('image', widget.image),
                      icon: Icon(
                        Icons.done,
                        color: Colors.white,
                      ),
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
