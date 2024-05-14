import 'package:flutter/material.dart';
import 'package:notepad/Providers/user_provider.dart';
import 'package:notepad/Screens/ChatApp/Calling/video_call.dart';
import 'package:notepad/Screens/ChatApp/Calling/voice_call.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:developer';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../Models/user_model.dart';
import '../../../Services/user_services.dart';
import '../../../Widgets/no_last_custom_card.dart';
import '../../../utils/settings.dart';

class CallsAdd extends StatefulWidget {
  const CallsAdd({super.key});

  @override
  State<CallsAdd> createState() => _CallsAddState();
}

class _CallsAddState extends State<CallsAdd> {

  UserService userService = UserService();
  late List<User> users = [];
  late List<User> filteredUsers = [];


  fetchUsers() async {
    users = await userService.fetchAllUsers(context);
    setState(() {

    });
  }

  void sortUsers() {
    users.sort((b,a) => a.last_active.compareTo(b.last_active));
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }


  @override
  Widget build(BuildContext context) {
    filteredUsers = users.where((element) => element.id != Provider.of<UserProvider>(context).user.id).toList();
    final user = Provider.of<UserProvider>(context).user;
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "ADD CALL",
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
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              sortUsers();
              return NoLastCustomCard(user: filteredUsers[index], onTap: (){
                showCallsDialog(user, filteredUsers[index]);
              },);
            }),
      ),
    );
  }

  Future showCallsDialog(User user, User chatUser) {
    return showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Select Call Type"),
        content: Text("Which one do you want? see or hear?"),
        actions: [
          TextButton(onPressed: (){
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_)=> VideoCall(chatUser: chatUser,)));
          }, child: Text("See")),
          TextButton(onPressed: (){
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_)=> VoiceCall(user: user, chatUser: chatUser,)));
          }, child: Text("Hear")),
          TextButton(onPressed: (){
            Navigator.pop(context);
          }, child: Text("Cancel")),
        ],
      );
    });
  }
}
