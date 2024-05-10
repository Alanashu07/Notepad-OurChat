import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notepad/Screens/Authentication/chat_login.dart';
import 'package:notepad/Screens/Authentication/chat_signup.dart';
import 'package:notepad/Styles/app_style.dart';
import 'package:notepad/Widgets/button.dart';

import '../../main.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isLightTheme(context) ? LightMode.mainColor : DarkMode.bgColor,
      appBar: AppBar(
        title: const Text("OUR CHAT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('images/chat.png', scale: 1,),
            const SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
              CustomButton(onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (_)=> const LoginScreen()));
              }, text: 'Log In', textColor: isLightTheme(context) ? LightMode.mainColor : DarkMode.mainColor,),
              CustomButton(onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (_)=> const SignUpScreen()));
              }, text: 'Sign Up', textColor: isLightTheme(context) ? LightMode.mainColor : DarkMode.mainColor,),
            ],),
            const SizedBox(height: 80,),
            const Text("Welcome to OUR CHAT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 22),)
          ],
        ),
      ),
    );
  }
}
