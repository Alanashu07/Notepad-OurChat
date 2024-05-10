import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Styles/app_style.dart';

class OnlineIndicator extends StatelessWidget {
  const OnlineIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 15,
      width: 15,
      decoration: BoxDecoration(
        color: CupertinoColors.activeGreen,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          width: 3,
          color: isLightTheme(context) ? Colors.white : Colors.black
        )
      ),
    );
  }
}
