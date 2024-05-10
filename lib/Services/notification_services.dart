import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServices {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void initLocalNotification(
      BuildContext context, RemoteMessage message) async {
    var androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: androidInitializationSettings);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (payload) {});
  }

  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      if (Platform.isAndroid) {
        initLocalNotification(context, message);
          showNotification(message);
      }
    });
  }

  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'frontChat',
      'Foreground Chat',
      channelDescription:
          'For Receiving messages when app is in the foreground',
          importance: Importance.high, priority: Priority.high, ticker: 'ticker'
    );
    NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
    Future.delayed(Duration.zero, (){
      _flutterLocalNotificationsPlugin.show(0, message.notification!.title.toString(), message.notification!.body.toString(), notificationDetails);
    });
  }
}
