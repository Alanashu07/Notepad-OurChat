import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:notepad/Constants/date_util.dart';
import 'package:notepad/Screens/image_viewer.dart';
import 'package:notepad/Services/user_services.dart';
import 'package:notepad/Styles/app_style.dart';
import 'package:notepad/Widgets/media_card.dart';
import '../../Models/message_model.dart';
import '../../Models/user_model.dart';
import '../../main.dart';

class ChatUserProfileScreen extends StatefulWidget {
  final User chatUser;
  final List<Message> messages;

  const ChatUserProfileScreen(
      {super.key, required this.chatUser, required this.messages});

  @override
  State<ChatUserProfileScreen> createState() => _ChatUserProfileScreenState();
}

class _ChatUserProfileScreenState extends State<ChatUserProfileScreen> {
  late List<Message> mediaFiles;
  late String pushToken = '';

  UserService userService = UserService();

  getUserPushToken() async {
    pushToken = await userService.getPushToken(
        context: context, id: widget.chatUser.id);
  }

  @override
  void initState() {
    super.initState();
    getUserPushToken();
  }

  @override
  Widget build(BuildContext context) {
    mediaFiles = widget.messages.where((msg) => msg.type != 'text').toList();
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(
          widget.chatUser.name,
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: mq.height * .05,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(180),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ImageViewer(
                              text: widget.chatUser.name,
                              image: widget.chatUser.image)));
                },
                child: CachedNetworkImage(
                  width: 180,
                  height: 180,
                  imageUrl: widget.chatUser.image,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) =>
                      Image.asset('images/office-man.png'),
                ),
              ),
            ),
            SizedBox(
              height: mq.height * .025,
            ),
            Text(
              widget.chatUser.email,
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: mq.height * .025,
            ),
            RichText(
                text: TextSpan(children: [
              TextSpan(
                  text: 'About: ',
                  style: TextStyle(
                      color:
                          isLightTheme(context) ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
              TextSpan(
                  text: widget.chatUser.about,
                  style: TextStyle(
                      color: isLightTheme(context)
                          ? Colors.black54
                          : Colors.white70,
                      fontSize: 18)),
            ])),
            SizedBox(
              height: mq.height * .025,
            ),
            Text(
                overflow: TextOverflow.fade,
                DateUtil.getLastActiveTime(
                    context: context, lastActive: widget.chatUser.last_active),
                style: TextStyle(fontSize: 15)),
            Expanded(
                child: SizedBox(
              child: GridView.builder(
                      itemCount: mediaFiles.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.all(5),
                          child: MediaCard(
                            message: mediaFiles[index],
                          ),
                        );
                      }),
            )),
            Padding(
                padding: EdgeInsets.all(20),
                child: RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text: 'Joined On: ',
                      style: TextStyle(
                          color: isLightTheme(context)
                              ? Colors.black
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                  TextSpan(
                      text: DateUtil.getLastMessageTime(
                          context: context,
                          time: widget.chatUser.createdAt,
                          showYear: true),
                      style: TextStyle(
                          color: isLightTheme(context)
                              ? Colors.black54
                              : Colors.white70,
                          fontSize: 18)),
                ]))),
          ],
        ),
      ),
    );
  }
}
