import 'package:flutter/material.dart';
import 'package:notepad/Styles/app_style.dart';


void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), backgroundColor: isLightTheme(context) ? LightMode.accentColor : DarkMode.accentColor,));
}