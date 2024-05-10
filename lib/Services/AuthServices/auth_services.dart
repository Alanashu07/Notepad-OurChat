import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notepad/Constants/error_handling.dart';
import 'package:notepad/Constants/utils.dart';
import 'package:notepad/Models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:notepad/Providers/user_provider.dart';
import 'package:notepad/Screens/ChatApp/chat_home.dart';
import 'package:notepad/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Screens/Authentication/chat_login.dart';

class AuthService {
  void signUpUser(
      {
        required BuildContext context,
        required String name,
      required String email,
      required String password,
      required String about,
      required String createdAt,
      required String image,
      required String wallpaper,
      required bool is_online,
      required String last_active}) async {
    try {
      User user = User(
          password: password,
          name: name,
          id: '',
          about: about,
          createdAt: createdAt,
          email: email,
          image: image,
          wallpaper: wallpaper,
          is_online: is_online,
          last_active: last_active,
          status: [],
          token: '', pushToken: '');
      http.Response res = await http.post(
        Uri.parse('$uri/api/signup'),
        body: user.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        }
      );
      
      httpErrorHandle(response: res, context: context, onSuccess: (){
        showSnackBar(context, 'Account Created Successfully, Login with same credentials');
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> const LoginScreen()));
      });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void signInUser(
      {
        required BuildContext context,
        required String email,
        required String password}) async {
    try {
      http.Response res = await http.post(
          Uri.parse('$uri/api/signin'),
          body: jsonEncode({
            'email': email,
            'password': password
          }),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          }
      );

      httpErrorHandle(response: res, context: context, onSuccess: () async{
        SharedPreferences prefs = await SharedPreferences.getInstance();
        Provider.of<UserProvider>(context, listen: false).setUser(res.body);
        await prefs.setString('x-auth-token', jsonDecode(res.body)['token']);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> ChatHomeScreen()));
        getFirebaseMessagingToken(context: context);
      });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  static Future<void> getFirebaseMessagingToken({required BuildContext context}) async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    await fMessaging.requestPermission();
    await fMessaging.getToken().then((t) async {
      if(t != null) {
      try{
        http.Response res = await http.post(Uri.parse('$uri/api/update-pushToken'), headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': user.token
        }, body: jsonEncode({'id': user.id, 'pushToken': t}));
        httpErrorHandle(response: res, context: context, onSuccess: () {
          print('Push Token updated');
        });
      } catch(e) {
        showSnackBar(context, e.toString());
      }}
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }

  void getUserData(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');

      if(token == null) {
        prefs.setString('x-auth-token', '');
      }
      var tokenRes = await http.post(Uri.parse('$uri/tokenIsValid'),
      headers: <String, String> {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': token!
      }
      );

      var response = jsonDecode(tokenRes.body);
      if(response == true) {
        http.Response userRes = await http.get(Uri.parse('$uri/'),
            headers: <String, String> {
              'Content-Type': 'application/json; charset=UTF-8',
              'x-auth-token': token
            }
        );

        var userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUser(userRes.body);
        getFirebaseMessagingToken(context: context);
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }
}
