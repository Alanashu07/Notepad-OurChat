import 'package:flutter/material.dart';
import 'package:notepad/Styles/app_style.dart';
import '../main.dart';

class CustomButton extends StatelessWidget {
  final onTap;
  final text;
  final Color? bgColor;
  final Color? textColor;

  const CustomButton({super.key, this.onTap, this.text, this.bgColor = Colors.white, this.textColor});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50)
      ),
      height: 50,
      elevation: 5,
      minWidth: mq.width / 2.5,
      color: bgColor,
      child: Text(
        text,
        style: TextStyle(color: textColor),
      ),
    );
  }
}
