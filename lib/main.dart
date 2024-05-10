import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:flutter_notification_channel/notification_visibility.dart';
import 'package:notepad/Constants/server_name.dart';
import 'package:notepad/Models/user_model.dart';
import 'package:notepad/Providers/user_provider.dart';
import 'package:notepad/Screens/note_home.dart';
import 'package:notepad/Services/AuthServices/auth_services.dart';
import 'package:notepad/Styles/app_style.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'Screens/Camera/camera_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

late Size mq;
String profileUrl = '';
String mediaUrl = '';
String wallpaperUrl = '';
String uri = ServerName.getServerName();
// String uri = 'https://ourchatserver.onrender.com';
bool haveToken = false;
String messageId = '';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ServerName.init();
  _initializeFirebase();
  cameras = await availableCameras();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => UserProvider())
  ],child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {
  final AuthService authService = AuthService();
  @override
  void initState() {
    authService.getUserData(context);
    ServerName.getServerName();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<UserProvider>(context).user.token.isNotEmpty ? haveToken = true : haveToken = false;
    return OverlaySupport(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Notepad',
        theme: lightTheme(context),
        darkTheme: darkTheme(context),
        home: const HomeScreen(),
      ),
    );
  }
}

@pragma('vm:entry-point')
_initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  var result = await FlutterNotificationChannel().registerNotificationChannel(
    description: 'For showing Pop up Notification',
    id: 'chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Chats',
  );
}