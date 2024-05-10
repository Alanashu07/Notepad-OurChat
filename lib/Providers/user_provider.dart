import 'package:flutter/material.dart';
import 'package:notepad/Models/user_model.dart';

class UserProvider extends ChangeNotifier {
  User _user = User(
      password: '',
      name: '',
      id: '',
      about: '',
      createdAt: '',
      email: '',
      image: '',
      is_online: false,
      last_active: '',
      status: [],
      token: '',
      wallpaper: '', pushToken: '');

  User get user => _user;

  void setUser(String user) {
    _user = User.fromJson(user);
    notifyListeners();
  }

  void setUserFromModel(User user) {
    _user = user;
    notifyListeners();
  }
}
