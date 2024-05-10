import 'package:flutter/material.dart';

import '../main.dart';

class ImageViewer extends StatelessWidget {
  final String text;
  final String image;
  const ImageViewer({super.key, required this.text, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(text, style: TextStyle(color: Colors.white),),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        child: InteractiveViewer(
          clipBehavior: Clip.none,
          maxScale: 10,
          child: Image.network(image),
        ),
      ),
    );
  }
}
