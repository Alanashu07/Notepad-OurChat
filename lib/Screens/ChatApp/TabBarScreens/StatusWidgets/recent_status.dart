import 'package:flutter/material.dart';
import 'package:notepad/Constants/date_util.dart';
import 'package:notepad/Providers/user_provider.dart';
import 'package:notepad/Screens/ChatApp/TabBarScreens/status_view_screen.dart';
import 'package:notepad/Services/message_services.dart';
import 'package:notepad/Widgets/status_painter.dart';
import 'package:provider/provider.dart';
import '../../../../Models/user_model.dart';
import '../../../../Styles/app_style.dart';

class RecentStatus extends StatefulWidget {
  final User user;
  const RecentStatus({super.key, required this.user});

  @override
  State<RecentStatus> createState() => _RecentStatusState();
}

class _RecentStatusState extends State<RecentStatus> {

  MessageServices messageServices = MessageServices();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final int max = widget.user.status.length - 1;
    final status = widget.user.status[max];
    final url = status['url'];
    final time = status['time'];
    return InkWell(
      onTap: (){
        messageServices.viewStatus(context: context, user: user, statusUser: widget.user, num: 0);
        Navigator.push(context, MaterialPageRoute(builder: (context)=> StatusViewScreen(url: url.toString(), user: widget.user)));
      },
      child: ListTile(
        leading: CustomPaint(
          painter: StatusPainter(color: isLightTheme(context) ? LightMode.mainColor : DarkMode.mainColor,user: widget.user),
          child: CircleAvatar(
            radius: 27,
            backgroundImage: NetworkImage(url.toString()), backgroundColor: Colors.white,),
        ),
        title: Text(widget.user.name, style: TextStyle(fontWeight: FontWeight.bold),),
        subtitle: Text(DateUtil.getMessageTime(context: context, time: time), style: TextStyle(fontSize: 12),),
      ),
    );
  }
}
