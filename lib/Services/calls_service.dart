import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notepad/Constants/error_handling.dart';
import 'package:notepad/Constants/utils.dart';
import 'package:notepad/Models/call_model.dart';
import 'package:notepad/Models/message_model.dart';
import 'package:notepad/Providers/user_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../Models/user_model.dart';
import '../main.dart';


class CallsServices{
  Future<void> addCall({
    required BuildContext context,
    required User user,
    required User chatUser,
    required String pushToken,
    required String time,
    required String duration
}) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    Calls calls = Calls(callerId: user.id, receiverId: chatUser.id, time: time, duration: duration);

    try{
      http.Response res = await http.post(Uri.parse('$uri/api/addCall'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': userProvider.user.token
          }, body: calls.toJson()
      );

      httpErrorHandle(response: res, context: context, onSuccess: (){
        sendCallsNotification(context: context, pushToken: pushToken, user: user);
      });
    } catch(e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<User> findUser({required BuildContext context, required String userId})async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    late User user;
    try{
      http.Response res = await http.get(Uri.parse('$uri/api/getUser?id=$userId'), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': userProvider.user.token
      });

      httpErrorHandle(response: res, context: context, onSuccess: (){
        user = User.fromJson(jsonEncode(jsonDecode(res.body)));
      });
      return user;
    } catch(e) {
      showSnackBar(context, e.toString());
    }
    return user;
  }

  Future<void> sendCallsNotification(
      {required BuildContext context,
        required String pushToken,
        required User user}) async {
    try {
      final body = {
        "to": pushToken,
        "notification": {
          "title": user.name,
          "body": 'Receiving a Call from ${user.name} 📞',
          "android_channel_id": "calls"
        },
        "data": {
          "some_data": user.id,
        }
      };
      var response =
      await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
            'key=AAAA0hNM8e0:APA91bG0u34TNFkNSycpP--iex4HBQ-YKp23Bqc3e4zcevJ3JDqbETo3VberCGhGijp4fXD_Ar2MKd5i8zE-Re_DX6SX1NLUtD7H3X6FHq4YVDu5B_PNJJEsnhF6n5sTehUkvpRwjkuQ'
          },
          body: jsonEncode(body));
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<List<Calls>> getCalls(
      {required BuildContext context,
        required String userId}) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Calls> callsList = [];
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/api/getCalls?userId=$userId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token
        },
      );

      httpErrorHandle(
          response: res,
          context: context,
          onSuccess: () {
            for (int i = 0; i < jsonDecode(res.body).length; i++) {
              callsList
                  .add(Calls.fromJson(jsonEncode(jsonDecode(res.body)[i])));
            }
          });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return callsList;
  }
}