import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notepad/Providers/user_provider.dart';
import 'package:notepad/Screens/ChatApp/chatting_screen.dart';
import 'package:notepad/Services/message_services.dart';
import 'package:notepad/Services/user_services.dart';
import 'package:notepad/Styles/app_style.dart';
import 'package:provider/provider.dart';
import 'package:story_view/story_view.dart';

import '../../../Models/user_model.dart';

class MyStatusViewScreen extends StatefulWidget {
  final String url;
  final User user;

  const MyStatusViewScreen({super.key, required this.url, required this.user});

  @override
  State<MyStatusViewScreen> createState() => _MyStatusViewScreenState();
}

class _MyStatusViewScreenState extends State<MyStatusViewScreen> {
  late List<User> users = [];
  late List<User> viewedUsers = [];
  UserService userService = UserService();

  fetchUsers() async {
    users = await userService.fetchAllUsers(context);
    Set<String> uniqueIds = Set<String>();
    for(int i = 0; i<widget.user.status.length; i++) {
      for(int j = 0; j<widget.user.status[i]['users'].length; j++){
        var userId = widget.user.status[i]['users'][j];
        uniqueIds.add(userId);
      }
    }
    viewedUsers = users.where((user) => uniqueIds.contains(user.id)).toList();
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
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
                  color: isLightTheme(context) ? Colors.white : Colors.black,
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context)
                          .viewInsets
                          .bottom),
                  width: double.infinity,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                child: const Text(
                                  "Viewed by ",
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight:
                                      FontWeight.bold),
                                ),
                              ),
                              Text(
                                viewedUsers.length.toString(),
                                style: TextStyle(
                                    fontSize: 20,
                                    color: isLightTheme(context) ? Colors.black54 : Colors.white70),
                              )
                            ],
                          ),
                          IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(
                                  CupertinoIcons.xmark, color: isLightTheme(context) ? Colors.black : Colors.white,))
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Divider(
                        color: isLightTheme(context) ? Colors.black : Colors.white,
                        thickness: 1,
                      ),
                      Expanded(child: ListView.builder(
                          keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior
                              .onDrag,
                          physics:
                          const BouncingScrollPhysics(),
                          itemCount: viewedUsers.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding:
                              const EdgeInsets.all(8.0),
                              child: Flexible(
                                child: Container(
                                  decoration:
                                  const BoxDecoration(
                                      shape: BoxShape
                                          .rectangle),
                                  child: ListTile(
                                    leading: CircleAvatar(backgroundImage: NetworkImage(viewedUsers[index].image),),
                                    title: Text(viewedUsers[index].name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isLightTheme(context) ? Colors.black : Colors.white),),
                                    subtitle: Text(viewedUsers[index].email, style: TextStyle(color: isLightTheme(context) ? Colors.black54 : Colors.white70),),
                                    trailing: IconButton(onPressed: (){
                                      Navigator.push(context, MaterialPageRoute(builder: (_)=> ChattingScreen(chatUser: viewedUsers[index], user: Provider.of<UserProvider>(context).user)));
                                    }, icon: Icon(CupertinoIcons.chat_bubble),),
                                  ),
                                ),
                              ),
                            );
                          })),
                    ],
                  ),
                ),
              );
            });
      },
    );
  }
}
