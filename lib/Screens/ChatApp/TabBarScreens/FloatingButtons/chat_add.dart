import 'package:flutter/material.dart';
import 'package:notepad/Providers/user_provider.dart';
import 'package:notepad/Screens/ChatApp/chatting_screen.dart';
import 'package:notepad/Services/user_services.dart';
import 'package:provider/provider.dart';
import '../../../../Models/user_model.dart';
import '../../../../Widgets/no_last_custom_card.dart';

class ChatAdd extends StatefulWidget {

  const ChatAdd({super.key});

  @override
  State<ChatAdd> createState() => _ChatAddState();
}

class _ChatAddState extends State<ChatAdd> {

  UserService userService = UserService();
  late List<User> users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  fetchUsers() async {
    users = await userService.fetchAllUsers(context);
    setState(() {

    });
  }

  void sortUsers() {
    users.sort((b,a) => a.last_active.compareTo(b.last_active));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "ADD CHAT",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
        ],
      ),
      body: Expanded(
        child: ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              sortUsers();
              return NoLastCustomCard(user: users[index], onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_)=>ChattingScreen(user: Provider.of<UserProvider>(context).user, chatUser: users[index],)));
              },);
            }),
      ),
    );
  }
}
