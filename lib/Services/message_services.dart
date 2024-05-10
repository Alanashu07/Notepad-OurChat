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
import 'package:notepad/Models/message_model.dart';
import 'package:notepad/Providers/user_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../Models/user_model.dart';
import '../main.dart';

class MessageServices {
  Future<void> sendMessage(
      {required BuildContext context,
      required User chatUser,
      required User user,
      required String pushToken,
      required String senderId,
      required String receiverId,
      required String text,
      VoidCallback? onSuccess,
      required String type,
      required String readAt,
      required String sentAt}) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      Message message = Message(
          sender: senderId,
          receiver: receiverId,
          text: text,
          type: type,
          sentAt: sentAt,
          readAt: readAt);

      http.Response res = await http.post(Uri.parse('$uri/api/sendMessage'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': userProvider.user.token
          },
          body: message.toJson());

      httpErrorHandle(
          response: res,
          context: context,
          onSuccess: () {
            final responseData = jsonDecode(res.body);
            messageId = responseData['msgId'];
            sendPushNotification(
                context: context,
                pushToken: pushToken,
                message: message,
                user: user);
            onSuccess!();
          });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<void> sendPushNotification(
      {required BuildContext context,
      required String pushToken,
      required Message message,
      required User user}) async {
    try {
      final body = {
        "to": pushToken,
        "notification": {
          "title": user.name,
          "body": message.type == 'image'
              ? 'Sent an Image 📸'
              : message.type == 'video'
                  ? 'Sent a Video 🎥'
                  : message.type == 'gif'
                      ? 'Send a gif 💕'
                      : message.text,
          "android_channel_id": "chats"
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

  Future<void> sendMediaMessage(
      {required BuildContext context,
      required String senderId,
      required String receiverId,
      required User user,
      required VoidCallback onSuccess,
      required String pushToken,
      required User chatUser,
      required XFile image,
      required String type,
      required String readAt,
      required String sentAt}) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      final cloudinary = CloudinaryPublic('diund1rdq', 'yfzrwfpl');
      String imageUrl = '';
      CloudinaryResponse res = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(image.path, folder: '$senderId-$receiverId'),
      );
      imageUrl = res.secureUrl;
      mediaUrl = imageUrl;
      Message message = Message(
          sender: senderId,
          receiver: receiverId,
          text: imageUrl,
          type: type,
          sentAt: sentAt,
          readAt: readAt);
      http.Response response =
          await http.post(Uri.parse('$uri/api/sendMessage'),
              headers: {
                'Content-Type': 'application/json; charset=UTF-8',
                'x-auth-token': userProvider.user.token
              },
              body: message.toJson());
      httpErrorHandle(
          response: response,
          context: context,
          onSuccess: () {
            final responseData = jsonDecode(response.body);
            messageId = responseData['msgId'];
            onSuccess();
          });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<void> sendGif(
      {required BuildContext context,
      required String senderId,
      required String receiverId,
      required XFile image,
      required User user,
      required VoidCallback onSuccess,
      required String pushToken,
      required User chatUser,
      required String type,
      required String readAt,
      required String sentAt}) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      final cloudinary = CloudinaryPublic('diund1rdq', 'yfzrwfpl');
      String imageUrl = '';
      CloudinaryResponse res = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(image.path, folder: '$senderId-$receiverId'),
      );
      imageUrl = res.secureUrl;
      mediaUrl = imageUrl;
      Message message = Message(
          sender: senderId,
          receiver: receiverId,
          text: imageUrl,
          type: type,
          sentAt: sentAt,
          readAt: readAt);
      http.Response response =
          await http.post(Uri.parse('$uri/api/sendMessage'),
              headers: {
                'Content-Type': 'application/json; charset=UTF-8',
                'x-auth-token': userProvider.user.token
              },
              body: message.toJson());
      httpErrorHandle(
          response: response,
          context: context,
          onSuccess: () {
            final responseData = jsonDecode(response.body);
            messageId = responseData['msgId'];
            onSuccess();
            sendPushNotification(
                context: context,
                pushToken: pushToken,
                message: message,
                user: user);
          });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<void> sendVideo(
      {required BuildContext context,
      required String senderId,
      required String receiverId,
      required String path,
      required VoidCallback onSuccess,
      required String pushToken,
      required User user,
      required User chatUser,
      required String type,
      required String readAt,
      required String sentAt}) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      final cloudinary = CloudinaryPublic('diund1rdq', 'yfzrwfpl');
      String imageUrl = '';
      CloudinaryResponse res = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(path, folder: '$senderId-$receiverId'),
      );
      imageUrl = res.secureUrl;
      mediaUrl = imageUrl;
      Message message = Message(
          sender: senderId,
          receiver: receiverId,
          text: imageUrl,
          type: type,
          sentAt: sentAt,
          readAt: readAt);
      http.Response response =
          await http.post(Uri.parse('$uri/api/sendMessage'),
              headers: {
                'Content-Type': 'application/json; charset=UTF-8',
                'x-auth-token': userProvider.user.token
              },
              body: message.toJson());
      httpErrorHandle(
          response: response,
          context: context,
          onSuccess: () {
            final responseData = jsonDecode(response.body);
            messageId = responseData['msgId'];
            onSuccess();
          });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<void> updateMessage(
      {required BuildContext context,
      required Message message,
      required User user,
      required String text,
      required VoidCallback onSuccess}) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (user.id == message.sender) {
      try {
        http.Response res = await http.post(Uri.parse('$uri/api/updateMessage'),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'x-auth-token': userProvider.user.token
            },
            body: jsonEncode({'id': message.id, 'text': text}));
        httpErrorHandle(response: res, context: context, onSuccess: onSuccess);
      } catch (e) {
        showSnackBar(context, e.toString());
      }
    }
  }

  Future<void> updateReadStatus({
    required BuildContext context,
    required Message message,
    required String readAt,
    required VoidCallback onSuccess,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      http.Response res =
          await http.post(Uri.parse('$uri/api/updateReadStatus'),
              headers: {
                'Content-Type': 'application/json; charset=UTF-8',
                'x-auth-token': userProvider.user.token
              },
              body: jsonEncode({'id': message.id, 'readAt': readAt}));
      httpErrorHandle(response: res, context: context, onSuccess: onSuccess);
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void deleteMessage(
      {required BuildContext context,
      required Message message,
      required User user,
      required VoidCallback onSuccess}) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (user.id == message.sender) {
      try {
        http.Response res = await http.post(Uri.parse('$uri/api/deleteMessage'),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'x-auth-token': userProvider.user.token
            },
            body: jsonEncode({'id': message.id}));
        httpErrorHandle(response: res, context: context, onSuccess: onSuccess);
      } catch (e) {
        showSnackBar(context, e.toString());
      }
    }
  }

  void uploadStatus(
      {required BuildContext context,
      required String time,
        required String type,
      required User user,
      required XFile image}) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      final cloudinary = CloudinaryPublic('diund1rdq', 'yfzrwfpl');
      String imageUrl = '';
      CloudinaryResponse res = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(image.path, folder: user.id),
      );
      imageUrl = res.secureUrl;
      http.Response response = await http.post(
          Uri.parse('$uri/api/uploadStatus'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': userProvider.user.token
          },
          body: jsonEncode({'id': user.id, 'status': imageUrl, 'time': time, 'type': type}));

      httpErrorHandle(
          response: response,
          context: context,
          onSuccess: () {
            User user = userProvider.user
                .copyWith(status: jsonDecode(response.body)['status']);
            userProvider.setUserFromModel(user);
            showSnackBar(context, "Status Uploaded Successfully");
          });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void viewStatus(
      {required BuildContext context,
      required User user,
      required User statusUser,
      required int num}) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      http.Response res = await http.post(Uri.parse('$uri/api/viewStatus'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': userProvider.user.token
          },
          body: jsonEncode({
            'id': statusUser.id,
            'clickedUserId': user.id,
            'statusIndex': num
          }));
      httpErrorHandle(response: res, context: context, onSuccess: () {});
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<List<Message>> getMessages(
      {required BuildContext context,
      required String userId,
      required String chatUserId}) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Message> messageList = [];
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/api/getMessage?userId=$userId&chatUserId=$chatUserId'),
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
              messageList
                  .add(Message.fromJson(jsonEncode(jsonDecode(res.body)[i])));
            }
          });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return messageList;
  }

  Future<List<Message>> getAllMessages(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Message> messageList = [];
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/api/getAllMessages'),
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
              messageList
                  .add(Message.fromJson(jsonEncode(jsonDecode(res.body)[i])));
            }
          });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return messageList;
  }
}
