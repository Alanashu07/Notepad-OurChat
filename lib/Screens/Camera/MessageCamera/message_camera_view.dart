import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../../main.dart';

class MessageCameraViewScreen extends StatelessWidget {
  final XFile image;
  const MessageCameraViewScreen({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        actions: [
          IconButton(onPressed: (){}, icon: Icon(Icons.crop_rotate),),
          IconButton(onPressed: (){}, icon: Icon(Icons.emoji_emotions_outlined),),
          IconButton(onPressed: (){}, icon: Icon(Icons.title),),
          IconButton(onPressed: (){}, icon: Icon(Icons.edit),),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              child: InteractiveViewer(
                  clipBehavior: Clip.none,
                  child: Image.file(File(image.path))),
            ),
            Container(
              width: mq.width,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              child: TextFormField(
                textCapitalization: TextCapitalization.sentences,
                minLines: 1,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                style: TextStyle(color: Colors.white, fontSize: 17),
                decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: IconButton(onPressed: (){}, icon: Icon(Icons.add_photo_alternate, color: Colors.white,),),
                    hintText: "Add caption...",
                    hintStyle: TextStyle(color: Colors.white, fontSize: 17),
                    suffixIcon: IconButton(onPressed: (){}, icon: Icon(Icons.done, color: Colors.white,),)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
