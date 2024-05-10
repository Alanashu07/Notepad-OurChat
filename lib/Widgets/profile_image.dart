import 'package:flutter/material.dart';

import 'online_indicator.dart';

class ProfileImage extends StatelessWidget {
  final bool online;
  final String imageUrl;
  const ProfileImage({super.key, this.online = true, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Image.network(imageUrl, fit: BoxFit.fill,),
          ),
          Align(
            alignment: Alignment.topRight,
            child: online? OnlineIndicator() : Container(),
          )
        ],
      ),
    );
  }
}
