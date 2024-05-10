import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notepad/Constants/utils.dart';
import 'package:notepad/Models/user_model.dart';
import 'package:notepad/Providers/user_provider.dart';
import 'package:notepad/Screens/image_viewer.dart';
import 'package:notepad/Services/user_services.dart';
import 'package:notepad/Styles/app_style.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:provider/provider.dart';

import '../../main.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService userService = UserService();
  final _formKey = GlobalKey<FormState>();
  String? _image;
  late IO.Socket socket;

  @override
  void initState() {
    connect();
    super.initState();
  }

  void connect() {
    socket = IO.io(uri, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false
    });
    socket.on('profileUpdated', (params) {
        setState(() {});
    });
    socket.connect();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    String username = user.name;
    String userabout = user.about;
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(
          "Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  _image != null ?
                  ClipRRect(
                    borderRadius: BorderRadius.circular(180),
                    child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => ImageViewer(
                                      text: widget.user.name,
                                      image: widget.user.image)));
                        },
                        child: Image.file(
                          File(_image!),
                          width: 180,
                          height: 180,
                          fit: BoxFit.cover,
                        )),
                  )
                      :
                  ClipRRect(
                    borderRadius: BorderRadius.circular(180),
                    child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => ImageViewer(
                                      text: widget.user.name,
                                      image: widget.user.image)));
                        },
                        child: CachedNetworkImage(
                          width: 180,
                          height: 180,
                          imageUrl: widget.user.image,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) =>
                              Image.asset('images/office-man.png'),
                        )),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: MaterialButton(
                      elevation: 1,
                      onPressed: _profileBottom,
                      shape: CircleBorder(),
                      color: isLightTheme(context)
                          ? Colors.white.withOpacity(.5)
                          : Colors.black.withOpacity(.5),
                      child: Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: mq.height * .03,
              ),
              Text(
                widget.user.email,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: mq.height * .05,
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: username,
                      onSaved: (name) => username = name ?? '',
                      validator: (name) =>
                          name != null && name.isNotEmpty ? null : "Enter Name",
                      decoration: InputDecoration(
                          hintText: "Enter your Name",
                          label: Text('Name'),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          prefixIcon: Icon(
                            Icons.person,
                            color: isLightTheme(context)
                                ? LightMode.mainColor
                                : DarkMode.mainColor,
                          )),
                    ),
                    SizedBox(
                      height: mq.height * .03,
                    ),
                    TextFormField(
                      initialValue: userabout,
                      onSaved: (about) => userabout = about ?? '',
                      validator: (about) => about != null && about.isNotEmpty
                          ? null
                          : "Enter About",
                      decoration: InputDecoration(
                          hintText: "Enter your About",
                          label: Text('About'),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          prefixIcon: Icon(
                            Icons.info_outline,
                            color: isLightTheme(context)
                                ? LightMode.mainColor
                                : DarkMode.mainColor,
                          )),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: mq.height * .05,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 5, fixedSize: Size(150, 40)),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      userService.updateUserInfo(
                          context: context,
                          user: widget.user,
                          name: username,
                          about: userabout,
                          onSuccess: () {
                            showSnackBar(
                                context, 'Details updated Successfully');
                          });
                      socket.emit('profileUpdated', {'id': widget.user.id, 'name': username, 'about': userabout});
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(
                        Icons.edit,
                        color: isLightTheme(context)
                            ? LightMode.accentColor
                            : DarkMode.accentColor,
                      ),
                      Text(
                        "Update",
                        style: TextStyle(
                            color: isLightTheme(context)
                                ? LightMode.accentColor
                                : DarkMode.accentColor),
                      )
                    ],
                  ))
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          backgroundColor:
              isLightTheme(context) ? LightMode.mainColor : DarkMode.mainColor,
          icon: Icon(
            Icons.exit_to_app,
            color: Colors.white,
          ),
          onPressed: () {
            userService.logOut(context);
            socket.disconnect();
          },
          label: Text(
            "Log out",
            style: TextStyle(color: Colors.white),
          )),
    );
  }

  Future _profileBottom(){
    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context, builder: (builder)=> Container(
      width: mq.width,
      height: mq.height*.3,
      margin: EdgeInsets.all(16),
      child: Card(color: isLightTheme(context) ? LightMode.mainColor : DarkMode.mainColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text("Pick Profile Picture", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () async{
                  final ImagePicker _picker = ImagePicker();
                  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                  if(image != null){
                    Navigator.pop(context);
                    userService.updateProfilePicture(context: context, image: image, onSuccess: (){
                      showSnackBar(context, "Profile Picture updated successfully");
                      socket.emit('proPicUpdated', {'id': widget.user.id, 'image': profileUrl});
                    }, user: widget.user);
                    setState(() {
                      _image = image.path;
                    });
                  }
                },
                child: CircleAvatar(
                    radius: 48,
                    child: Icon(Icons.insert_photo, color: isLightTheme(context) ? LightMode.mainColor : DarkMode.mainColor, size: 48,)),
              ),
              InkWell(
                onTap: () async {
                  final ImagePicker _picker = ImagePicker();
                  final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                  if(image != null){
                    Navigator.pop(context);
                    userService.updateProfilePicture(context: context, image: image, onSuccess: (){
                      showSnackBar(context, "Profile Picture updated successfully");
                      socket.emit('proPicUpdated', {'id': widget.user.id, 'image': profileUrl});
                    }, user: widget.user);
                    setState(() {
                      _image = image.path;
                    });
                  }
                },
                child: CircleAvatar(
                    radius: 48,
                    child: Icon(Icons.camera_alt, color: isLightTheme(context) ? LightMode.mainColor : DarkMode.mainColor, size: 48,)),
              ),
            ],
          ),
        ],
      ),
      ),
    ));
  }
}
