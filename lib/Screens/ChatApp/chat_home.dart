import 'package:flutter/material.dart';
import 'package:notepad/Providers/user_provider.dart';
import 'package:notepad/Screens/ChatApp/TabBarScreens/calls_screen.dart';
import 'package:notepad/Screens/ChatApp/TabBarScreens/chats_screen.dart';
import 'package:notepad/Screens/ChatApp/TabBarScreens/status_screen.dart';
import 'package:notepad/Screens/ChatApp/profile_screen.dart';
import 'package:notepad/Services/user_services.dart';
import 'package:notepad/Widgets/profile_image.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../Models/user_model.dart';
import '../../main.dart';

class ChatHomeScreen extends StatefulWidget {
  const ChatHomeScreen({super.key});

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  late IO.Socket socket;
  UserService userService = UserService();
  User? user;
  String userImage = '';

  @override
  void initState() {
    super.initState();
  }

  void connect(User user) {
    socket = IO.io(uri, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false
    });
    socket.emit('signIn', user.id);
    socket.on('profileUpdated', (params) {
      final userId = params['id'];
      final userName = params['name'];
      final userAbout = params['about'];
      if (userId == user.id) {
        setState(() {
          user.name = userName;
          user.about = userAbout;
        });
      }
    });
    socket.on('proPicUpdated', (params) {
      final userId = params['id'];
      final image = params['image'];
      if(userId == user.id){
          setState(() {
              user.image = image;
              userImage = image;
            });}
    });
    socket.onConnect((data) {
      userService.updateOnlineStatus(
          context: context,
          isOnline: true,
          last_active: DateTime.now().millisecondsSinceEpoch.toString());
      print("Connected");
    });
    socket.connect();
    print(socket.connected);
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<UserProvider>(context).user;
    if (user != null) connect(user!);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          leading: Padding(
            padding: EdgeInsets.all(8.0),
            child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ProfileScreen(user: user!)));
                },
                child: ProfileImage(
                  online: true,
                  imageUrl: userImage.isEmpty ? user!.image : userImage,
                )),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user!.name,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              user!.is_online
                  ? Text("Online", style: Theme.of(context).textTheme.bodySmall)
                  : SizedBox(),
            ],
          ),
          actions: [
            IconButton(onPressed: () {}, icon: Icon(Icons.search)),
            IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
          ],
          bottom: TabBar(
            dividerColor: Colors.transparent,
            indicatorPadding: EdgeInsets.symmetric(vertical: 10),
            tabs: [
              Tab(
                child: Container(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(50)),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text("Chats"),
                  ),
                ),
              ),
              Tab(
                child: Container(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(50)),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text("Status"),
                  ),
                ),
              ),
              Tab(
                child: Container(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(50)),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text("Calls"),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ChatsScreen(),
            StatusScreen(),
            CallsScreen(),
          ],
        ),
      ),
    );
  }
}