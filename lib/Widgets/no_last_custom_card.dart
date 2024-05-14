import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notepad/Constants/date_util.dart';
import 'package:notepad/Models/chat_model.dart';
import 'package:notepad/Models/user_model.dart';
import 'package:notepad/Screens/ChatApp/chatting_screen.dart';
import 'package:notepad/Screens/image_viewer.dart';
import 'package:notepad/Styles/app_style.dart';
import 'package:notepad/Widgets/online_indicator.dart';
import 'package:provider/provider.dart';

import '../Models/message_model.dart';
import '../Providers/user_provider.dart';
import '../main.dart';

class NoLastCustomCard extends StatelessWidget {
  final User user;
  final VoidCallback onTap;
  const NoLastCustomCard({super.key, required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final appUser = Provider.of<UserProvider>(context).user;
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          ListTile(
            leading: GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (_)=> ImageViewer(text: user.name, image: user.image)));
              },
              child: CircleAvatar(
                backgroundImage: NetworkImage(user.image),
                backgroundColor: Colors.white30,
                // child: CachedNetworkImage(
                //   imageUrl: '',
                //   fit: BoxFit.cover,
                //   errorWidget: (context, url, error) =>
                //       Image.asset('images/office-man.png'),
                // ),
                radius: 25,
              ),
            ),
            title: Text(user.id == Provider.of<UserProvider>(context).user.id ?'${user.name} (YOU)' :user.name, overflow: TextOverflow.ellipsis,style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isLightTheme(context) ? Colors.black : Colors.white
            ),),
            subtitle: Row(
              children: [
                SizedBox(width: 5,),
                Container(
                  width: mq.width / 3,
                  child: Text(
                    user.about,overflow: TextOverflow.ellipsis, style: TextStyle(color: isLightTheme(context) ? Colors.black54 : Colors.white30, fontSize: 13),
                  ),
                ),
              ],
            ),
            trailing: user.is_online ? Text("Online", style: TextStyle(color: CupertinoColors.activeGreen),) :Text(DateUtil.getLastMessageTime(context: context, time: user.last_active)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Divider(thickness: .5,),
          )
        ],
      ),
    );
  }
}
