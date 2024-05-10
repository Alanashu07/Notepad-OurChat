import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notepad/Constants/server_name.dart';
import 'package:notepad/Screens/ChatApp/splash_screen.dart';
import 'package:notepad/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Providers/user_provider.dart';
import '../../Styles/app_style.dart';

class ChatLockScreen extends StatefulWidget {
  const ChatLockScreen({super.key});

  @override
  State<ChatLockScreen> createState() => _ChatLockScreenState();
}

class _ChatLockScreenState extends State<ChatLockScreen> {
  bool isSecurePassword = true;
  String localhost = 'http://192.168.53.163:3000';
  String render = 'https://ourchatserver.onrender.com';
  String cyclic = '<Cyclic Link>';
  String system = '<System Link>';

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    return Scaffold(
      backgroundColor:
          isLightTheme(context) ? LightMode.mainColor : DarkMode.bgColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        title: const Text(
          "Enter Pin",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          Text(
            ServerName.getServerName() == localhost
                ? 'Local Host'
                : ServerName.getServerName() == render
                    ? 'Render'
                    : ServerName.getServerName() == cyclic
                        ? 'Cyclic'
                        : 'System',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          PopupMenuButton<String>(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'images/database-storage.png',
                  color: Colors.white,
                ),
              ),
              onSelected: (value) async {
                await ServerName.setServerName(value);
                setState(() {});
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    child: Text("Local Host"),
                    value: localhost,
                  ),
                  PopupMenuItem(
                    child: Text("Render"),
                    value: render,
                  ),
                  PopupMenuItem(
                    child: Text("Cyclic"),
                    value: cyclic,
                  ),
                  PopupMenuItem(
                    child: Text("System"),
                    value: system,
                  ),
                ];
              })
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Center(
          child: TextField(
            onSubmitted: (val) {
              if (val.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Enter Password!")));
              } else {
                val == '5370'
                    ? Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => SplashScreen()))
                    : ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Wrong Password!")));
              }
            },
            obscureText: isSecurePassword,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.white),
            decoration: InputDecoration(
                suffixIcon: togglePassword(),
                contentPadding: const EdgeInsets.all(12),
                hintText: "Enter Pin to continue",
                hintStyle: const TextStyle(color: Colors.white70),
                fillColor: isLightTheme(context)
                    ? const Color(0xFF000750)
                    : Colors.white10,
                filled: true,
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.transparent)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.transparent))),
          ),
        ),
      ),
    );
  }

  Widget togglePassword() {
    return IconButton(
        onPressed: () {
          setState(() {
            isSecurePassword = !isSecurePassword;
          });
        },
        icon: isSecurePassword
            ? const Icon(
                CupertinoIcons.eye,
                color: Colors.white,
              )
            : const Icon(
                CupertinoIcons.eye_slash,
                color: Colors.white,
              ));
  }
}
