import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notepad/Models/user_model.dart';
import 'package:notepad/Providers/user_provider.dart';
import 'package:notepad/Screens/ChatApp/TabBarScreens/StatusWidgets/my_status.dart';
import 'package:notepad/Screens/ChatApp/TabBarScreens/StatusWidgets/recent_status.dart';
import 'package:notepad/Services/AuthServices/auth_services.dart';
import 'package:notepad/Services/message_services.dart';
import 'package:notepad/Services/user_services.dart';
import 'package:provider/provider.dart';
import '../../../Styles/app_style.dart';
import '../../../main.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  MessageServices messageServices = MessageServices();
  UserService userService = UserService();
  AuthService authService = AuthService();
  late List<User> users = [];
  late List<User> filteredUsers = [];
  late User user;

  Future<void> _handleRefresh() async {
    fetchAllUsers();
    setState(() {
      authService.getUserData(context);
    });
  }

  fetchAllUsers() async {
    users = await userService.fetchAllUsers(context);
    setState(() {});
  }

  @override
  void initState() {
    authService.getUserData(context);
    fetchAllUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    filteredUsers = users
        .where((user) =>
            user.status.length != 0 &&
            user.id != Provider.of<UserProvider>(context).user.id)
        .toList();
    user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: Column(
          children: [
            SizedBox(
              height: 15,
            ),
            MyStatus(user: user, onTap: () => uploadImageCamera(user),),
            Container(
              alignment: Alignment.centerLeft,
              height: 30,
              width: mq.width,
              color: isLightTheme(context) ? Colors.grey[300] : Colors.grey[900],
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                "Recent Updates",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            // if(filteredUsers.isNotEmpty)
            Expanded(
              child: ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                      int max = filteredUsers[index].status.length - 1;
                      filteredUsers
                          .sort((b,a) => a.status[max]['time'].compareTo(b.status[max]['time']));
                    return RecentStatus(
                      user: filteredUsers[index],
                    );
                  }),
            )
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Icon(Icons.add),
        activeIcon: Icons.close,
        children: [
          SpeedDialChild(
            onTap: () async {
              uploadImageGallery(user);
            },
            labelWidget: Text("Upload Image from Gallery   ", style: TextStyle(color: Colors.black54),),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            backgroundColor: isLightTheme(context)
                ? LightMode.mainColor
                : DarkMode.mainColor,
            child: Icon(
              Icons.insert_photo,
              color: Colors.white,
            ),
          ),
          SpeedDialChild(
            onTap: () async {
              uploadImageCamera(user);
            },
            labelWidget: Text("Upload Image from Camera   ", style: TextStyle(color: Colors.black54)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            backgroundColor: isLightTheme(context)
                ? LightMode.mainColor
                : DarkMode.mainColor,
            child: Icon(
              Icons.camera_alt,
              color: Colors.white,
            ),
          ),
          SpeedDialChild(
            onTap: () async {
              uploadVideoGallery(user);
            },
            labelWidget: Text("Upload Video from Gallery   ", style: TextStyle(color: Colors.black54)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            backgroundColor: isLightTheme(context)
                ? LightMode.mainColor
                : DarkMode.mainColor,
            child: Icon(
              Icons.video_camera_back,
              color: Colors.white,
            ),
          ),
          SpeedDialChild(
            onTap: () async {
              uploadVideoCamera(user);
            },
            labelWidget: Text("Upload Video from Camera   ", style: TextStyle(color: Colors.black54)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            backgroundColor: isLightTheme(context)
                ? LightMode.mainColor
                : DarkMode.mainColor,
            child: Icon(
              Icons.video_call,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  uploadVideoGallery(User user) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      messageServices.uploadStatus(
          context: context,
          time: DateTime.now().millisecondsSinceEpoch.toString(),
          user: user,
          image: video, type: 'video', onSuccess: () { authService.getUserData(context); });
    }
  }

  uploadVideoCamera(User user) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
    if (video != null) {
      messageServices.uploadStatus(
          context: context,
          time: DateTime.now().millisecondsSinceEpoch.toString(),
          user: user,
          image: video, type: 'video', onSuccess: () { authService.getUserData(context); });
    }
  }

  uploadImageGallery(User user) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      messageServices.uploadStatus(
          context: context,
          time: DateTime.now().millisecondsSinceEpoch.toString(),
          user: user,
          image: image, type: 'image', onSuccess: () { authService.getUserData(context); });
    }
  }

  uploadImageCamera(User user) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      messageServices.uploadStatus(
          context: context,
          time: DateTime.now().millisecondsSinceEpoch.toString(),
          user: user,
          image: image, type: 'image', onSuccess: () { authService.getUserData(context); });
    }
  }
}
