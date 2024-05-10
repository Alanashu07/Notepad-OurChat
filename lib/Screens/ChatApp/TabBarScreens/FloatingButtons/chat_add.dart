import 'package:flutter/material.dart';
import '../../../../Models/user_model.dart';
import '../../../../Widgets/no_last_custom_card.dart';

class ChatAdd extends StatefulWidget {
  final List<User> users;

  const ChatAdd({super.key, required this.users});

  @override
  State<ChatAdd> createState() => _ChatAddState();
}

class _ChatAddState extends State<ChatAdd> {
  void sortUsers() {
    widget.users.sort((b,a) => a.last_active.compareTo(b.last_active));
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
            itemCount: widget.users.length,
            itemBuilder: (context, index) {
              sortUsers();
              return NoLastCustomCard(user: widget.users[index]);
            }),
      ),
    );
  }
}
