import 'package:flutter/material.dart';
import 'package:notepad/Providers/user_provider.dart';
import 'package:notepad/Screens/ChatApp/TabBarScreens/FloatingButtons/chat_add.dart';
import 'package:notepad/Services/user_services.dart';
import 'package:notepad/Styles/app_style.dart';
import 'package:notepad/Widgets/custom_card.dart';
import 'package:provider/provider.dart';
import '../../../Models/message_model.dart';
import '../../../Models/user_model.dart';
import '../../../Services/message_services.dart';
import '../../../Widgets/no_last_custom_card.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../../main.dart';

class ChatsScreen extends StatefulWidget {
  // final User user;
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  MessageServices messageServices = MessageServices();
  List<Message> messages = [];
  List<Message> filteredMessages = [];
  List<User> users = [];
  List<User> filteredUsers = [];
  bool sorted = false;
  final UserService userService = UserService();
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    connect();
    fetchAllUsers();
    getMessages();
  }

  void connect(){
    socket = IO.io(uri, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false
    });
    socket.on('signIn', (id) {
      setState(() {
        fetchAllUsers();
      });
    });
    socket.on('profileUpdated', (params) {
      setState(() {
        fetchAllUsers();
      });
    });
    socket.on('proPicUpdated', (params) {
      setState(() {
        fetchAllUsers();
      });
    });
    socket.on('MessageRead', (time) {
      setState(() {
        fetchAllUsers();
        getMessages();
      });
    });
    socket.on('userDisconnected', (id) {
      setState(() {
        fetchAllUsers();
      });
    });
    socket.on("message", (msg) {
      // Update the UI with the received message
      setState(() {
        messages.add(Message(
            sender: msg['senderId'].toString(),
            receiver: msg['receiverId'].toString(),
            text: msg['text'].toString(),
            type: msg['type'].toString(),
            readAt: msg['readAt'].toString(),
            sentAt: msg['sentAt'].toString()));
      });
    });
    socket.on('deleteMessage', (message) {
      setState(() {
        messages.remove(message);
      });
    });
    socket.connect();
  }



  sortChatsByModifiedTime(List<User> users) {
    if (sorted) {
      users.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else {
      users.sort((b, a) => a.createdAt.compareTo(b.createdAt));
    }
    sorted = !sorted;
    return users;
  }

  getMessages() async {
    messages = await messageServices.getAllMessages(context);
    setState(() {});
  }

  Future<void> _handleRefresh() async {
    getMessages();
    fetchAllUsers();
    setState(() {});
  }

  fetchAllUsers() async {
    users = await userService.fetchAllUsers(context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    filteredUsers = users
        .where((user) => user.id != Provider.of<UserProvider>(context).user.id)
        .toList();

    sortUsers(){
      filteredUsers.sort((b,a) => a.last_active.compareTo(b.last_active));
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: isLightTheme(context) ? LightMode.accentColor : DarkMode.accentColor,
        child: ListView.builder(
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              sortUsers();
              filteredMessages = messages
                  .where((message) =>
                      message.sender ==
                              Provider.of<UserProvider>(context).user.id &&
                          message.receiver == filteredUsers[index].id ||
                      message.receiver ==
                              Provider.of<UserProvider>(context).user.id &&
                          message.sender == filteredUsers[index].id)
                  .toList();
              if (filteredMessages.isNotEmpty)
                return CustomCard(
                  user: filteredUsers[index],
                  lastMessage: filteredMessages[filteredMessages.length - 1],
                );
              else
                return Container();
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => ChatAdd(users: users)));
        },
        child: Icon(Icons.chat),
      ),
    );
  }
}
