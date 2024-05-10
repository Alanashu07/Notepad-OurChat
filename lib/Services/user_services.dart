import 'dart:convert';
import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:notepad/Constants/error_handling.dart';
import 'package:notepad/Constants/utils.dart';
import 'package:notepad/Models/user_model.dart';
import 'package:notepad/Providers/user_provider.dart';
import 'package:notepad/Screens/Authentication/authentication_land.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class UserService {
  Future<List<User>> fetchAllUsers(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<User> userList = [];
    try {
      http.Response res =
          await http.get(Uri.parse('$uri/api/get-users'), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': userProvider.user.token
      });
      
      httpErrorHandle(response: res, context: context, onSuccess: (){
        for(int i=0; i<jsonDecode(res.body).length; i++){
          userList.add(User.fromJson(jsonEncode(jsonDecode(res.body)[i])));
        }
      });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return userList;
  }

  Future<String> getPushToken({required BuildContext context, required String id}) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    String pushToken = '';
    try{
      http.Response res = await http.get(Uri.parse('$uri/api/get-pushToken?id=$id'), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': userProvider.user.token
      });
      httpErrorHandle(response: res, context: context, onSuccess: (){
        pushToken = jsonDecode(res.body);
      });
    } catch(e) {
      showSnackBar(context, e.toString());
    }
    return pushToken;
  }

  void updateOnlineStatus({required BuildContext context, required bool isOnline, required String last_active}) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try{
      http.Response res = await http.post(Uri.parse('$uri/api/update-online'), headers: {
        'Content-Type':'application/json; charset=UTF-8',
        'x-auth-token': userProvider.user.token
      },
      body: jsonEncode({'is_online': isOnline, 'last_active': last_active})
      );

      httpErrorHandle(response: res, context: context, onSuccess: (){
        User user = userProvider.user.copyWith(is_online: jsonDecode(res.body)['is_online'], last_active: jsonDecode(res.body)['last_active']);
        userProvider.setUserFromModel(user);
      });
    } catch(e) {
      showSnackBar(context, e.toString());
    }
  }

  void updateProfilePicture({required BuildContext context, required User user, required XFile image, required VoidCallback onSuccess}) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try{
      final cloudinary = CloudinaryPublic('diund1rdq', 'yfzrwfpl');
      String imageUrl = '';
      CloudinaryResponse res = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(image.path, folder: user.id)
      );
      imageUrl = res.secureUrl;
      profileUrl = imageUrl;
      http.Response response = await http.post(Uri.parse('$uri/api/update-profilepicture'), headers: {
        'Content-Type':'application/json; charset=UTF-8',
        'x-auth-token': userProvider.user.token
      },
      body: jsonEncode({'id': user.id, 'image': imageUrl})
      );
      httpErrorHandle(response: response, context: context, onSuccess: onSuccess);
    } catch(e) {
      showSnackBar(context, e.toString());
    }
  }
  
  void updateWallpaper({required BuildContext context, required User user, required XFile image, required VoidCallback onSuccess}) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try{
      final cloudinary = CloudinaryPublic('diund1rdq', 'yfzrwfpl');
      String imageUrl = '';
      CloudinaryResponse res = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(image.path, folder: user.id)
      );
      imageUrl = res.secureUrl;
      wallpaperUrl = imageUrl;
      http.Response response = await http.post(Uri.parse('$uri/api/updateWallpaper'), headers: {
        'Content-Type':'application/json; charset=UTF-8',
        'x-auth-token': userProvider.user.token
      }, body: jsonEncode({'id': user.id, 'image': imageUrl}));

      httpErrorHandle(response: response, context: context, onSuccess: onSuccess);
    } catch(e) {
      showSnackBar(context, e.toString());
    }
  }

  void updateUserInfo({required BuildContext context, required User user, required VoidCallback onSuccess, required String name, required String about}) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      http.Response res = await http.post(
          Uri.parse('$uri/api/update-user'), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': userProvider.user.token
      },
          body: jsonEncode(
              {'id': user.id, 'name': name, 'about': about})
      );
      httpErrorHandle(response: res, context: context, onSuccess: onSuccess);
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    }
  void logOut(BuildContext context)async{
    try{
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences.setString('x-auth-token', '');
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=>LandingScreen()), (route) => false);
    } catch(e) {
      showSnackBar(context, e.toString());
    }
  }
}
