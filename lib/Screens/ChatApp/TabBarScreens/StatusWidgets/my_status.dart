import 'package:flutter/material.dart';
import 'package:notepad/Screens/ChatApp/TabBarScreens/StatusWidgets/view_total_statuses.dart';
import 'package:notepad/Widgets/status_painter.dart';
import 'package:page_transition/page_transition.dart';
import '../../../../Models/user_model.dart';
import '../../../../Styles/app_style.dart';
import '../my status_view_screen.dart';

class MyStatus extends StatefulWidget {
  final User user;
  final VoidCallback onTap;
  const MyStatus({super.key, required this.user, required this.onTap});

  @override
  State<MyStatus> createState() => _MyStatusState();
}

class _MyStatusState extends State<MyStatus> {
  @override
  Widget build(BuildContext context) {
    if(widget.user.status.length == 0)
    return GestureDetector(
      onTap: widget.onTap,
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 27,
              backgroundImage: NetworkImage(widget.user.image), backgroundColor: Colors.white,),
            Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                    backgroundColor: isLightTheme(context) ? LightMode.mainColor : DarkMode.mainColor,
                    radius: 10,
                    child: Icon(Icons.add, size: 15, color: Colors.white,)))
          ],
        ),
        title: Text("My Status", style: TextStyle(fontWeight: FontWeight.bold, color: isLightTheme(context) ? Colors.black : Colors.white),),
        subtitle: Text("Click to add Status update", style: TextStyle(fontSize: 12, color: isLightTheme(context) ? Colors.black54 : Colors.white60),),
      ),
    ); else
      {
        int max = widget.user.status.length -1;
        final status = widget.user.status[max];
        final url = status['url'].toString();
        final time = status['time'];
    return GestureDetector(
      onTap: (){
        Navigator.push(context, PageTransition(child: MyStatusViewScreen(url: url, user: widget.user), type: PageTransitionType.fade));
      },
      child: ListTile(
        leading: CustomPaint(
          painter: StatusPainter(color: isLightTheme(context) ? LightMode.mainColor : DarkMode.mainColor, user: widget.user),
          child: CircleAvatar(
            radius: 27,
            backgroundImage: NetworkImage(url.toString()), backgroundColor: Colors.white,),
        ),
        title: Text("My Status", style: TextStyle(fontWeight: FontWeight.bold, color: isLightTheme(context) ? Colors.black : Colors.white),),
        subtitle: Text("Tap to see your status updates", style: TextStyle(fontSize: 12, color: isLightTheme(context) ? Colors.black54 : Colors.white60),),
        trailing: IconButton(onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (_)=> ViewTotalStatuses(user: widget.user,)));
        }, icon: Icon(Icons.more_vert, color: isLightTheme(context) ? Colors.black : Colors.white,)),
      ),
    );
  }}
}
