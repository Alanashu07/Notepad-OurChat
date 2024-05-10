import 'package:flutter/material.dart';
import 'package:notepad/Constants/server_name.dart';
import 'package:notepad/Models/user_model.dart';
import 'package:notepad/Screens/Authentication/authentication_land.dart';
import 'package:notepad/Screens/Authentication/chat_login.dart';
import 'package:notepad/Screens/ChatApp/chat_home.dart';
import 'package:provider/provider.dart';
import '../../Providers/user_provider.dart';
import '../../Services/AuthServices/auth_services.dart';
import '../../Styles/app_style.dart';
import '../../main.dart';

class SplashScreen extends StatefulWidget {

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    authService.getUserData(context);
    ServerName.getServerName();

    Future.delayed(Duration(milliseconds: 1000), () {
      if (haveToken) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => ChatHomeScreen()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => LandingScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0.0,
          centerTitle: true,
          backgroundColor: isLightTheme(context) ? LightMode.mainColor : DarkMode.mainColor,
          title: Text(
            "Welcome to OUR CHAT",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          )),
      body: Stack(
        children: [
          Positioned(
              top: mq.height * .15,
              right: mq.width * .25,
              width: mq.width * .5,
              child: Column(
                children: [
                  Image.asset('images/chat.png'),
                  SizedBox(height: 25,),
                  Text("OUR CHAT", style: TextStyle(color: isLightTheme(context) ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 35),)
                ],
              )),
          // Positioned(
          //   top: mq.height*.5,
          //     right: mq.width*.35,
          //     child: Text("OUR CHAT", style: TextStyle(color: isLightTheme(context) ? Colors.black : Colors.white, fontWeight: FontWeight.bold),)),
          Positioned(
              bottom: mq.height * .15,
              width: mq.width,
              child: Text(
                "A Gift to Mumthaz🤍❤",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: isLightTheme(context) ? Colors.black : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: .5),
              )),
        ],
      ),
    );
  }
}
