import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:notepad/Providers/user_provider.dart';
import 'package:notepad/Services/message_services.dart';
import 'package:provider/provider.dart';
import 'package:story_view/story_view.dart';

import '../../../Models/user_model.dart';
import '../../../Services/user_services.dart';
import '../../../Styles/app_style.dart';
import '../../../main.dart';

class StatusViewScreen extends StatefulWidget {
  final String url;
  final User user;

  const StatusViewScreen({super.key, required this.url, required this.user});

  @override
  State<StatusViewScreen> createState() => _StatusViewScreenState();
}

class _StatusViewScreenState extends State<StatusViewScreen> {
  bool _showEmoji = false;
  TextEditingController _messageController = TextEditingController();
  MessageServices messageServices = MessageServices();
  UserService userService = UserService();
  String pushToken = '';

  getUserPushToken() async {
    pushToken =
        await userService.getPushToken(context: context, id: widget.user.id);
  }

  @override
  void initState() {
    getUserPushToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MessageServices messageServices = MessageServices();
    final _controller = StoryController();
    final List<StoryItem> storyItems = [];
    for (int i = 0; i < widget.user.status.length; i++) {
      if (widget.user.status[i]['type'] == 'image') {
        storyItems.add(StoryItem.inlineImage(
            url: widget.user.status[i]['url'].toString(),
            controller: _controller));
      } else {
        storyItems.add(StoryItem.pageVideo(
            widget.user.status[i]['url'].toString(),
            controller: _controller));
      }
      messageServices.viewStatus(
          context: context,
          user: Provider.of<UserProvider>(context).user,
          statusUser: widget.user,
          num: i);
    }
    return StoryView(
      storyItems: storyItems,
      controller: _controller,
      inline: false,
      repeat: false,
      onComplete: () => Navigator.pop(context),
      onVerticalSwipeComplete: (verticalSwipeDirection) {
        _controller.pause();
        showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return GestureDetector(
                onTap: () {
                  FocusScopeNode currentFocus =
                  FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                },
                child: Container(
                  height: mq.height,
                  color: isLightTheme(context) ? Colors.white : Colors.black,
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context)
                          .viewInsets
                          .bottom),
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Card(
                            color:
                                isLightTheme(context) ? Colors.white : Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      FocusScope.of(context).unfocus();
                                      setState(() {
                                        _showEmoji = !_showEmoji;
                                      });
                                    },
                                    icon: Icon(
                                      size: 26,
                                      Icons.emoji_emotions,
                                      color: isLightTheme(context)
                                          ? LightMode.accentColor
                                          : DarkMode.accentColor,
                                    )),
                                Expanded(
                                    child: TextFormField(
                                  onTap: () {
                                    if (_showEmoji)
                                      setState(() {
                                        _showEmoji = !_showEmoji;
                                      });
                                  },
                                  textCapitalization: TextCapitalization.sentences,
                                  keyboardType: TextInputType.multiline,
                                  minLines: 1,
                                  maxLines: 5,
                                  controller: _messageController,
                                  decoration: InputDecoration(
                                      hintText: "Type here...",
                                      hintStyle: TextStyle(
                                          color: isLightTheme(context)
                                              ? LightMode.accentColor
                                              : DarkMode.accentColor),
                                      border: InputBorder.none),
                                )),
                                SizedBox(
                                  width: mq.width * .02,
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3.0),
                          child: MaterialButton(
                            onPressed: () {
                              if (_messageController.text.trim().isNotEmpty) {
                                messageServices.sendMessage(
                                    context: context,
                                    chatUser: widget.user,
                                    user: Provider.of<UserProvider>(context).user,
                                    pushToken: pushToken,
                                    senderId:
                                        Provider.of<UserProvider>(context).user.id,
                                    receiverId: widget.user.id,
                                    text: _messageController.text.trim(),
                                    type: 'text',
                                    readAt: '',
                                    sentAt: DateTime.now()
                                        .millisecondsSinceEpoch
                                        .toString());
                                _messageController.clear();}
                            },
                            child: Icon(
                              Icons.send,
                              color: Colors.white,
                            ),
                            shape: CircleBorder(),
                            minWidth: 25,
                            color: isLightTheme(context)
                                ? LightMode.mainColor
                                : DarkMode.mainColor,
                            height: 40,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            });
      },
    );
  }
}
