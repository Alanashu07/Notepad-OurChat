import 'package:flutter/material.dart';
import 'package:notepad/Constants/date_util.dart';
import 'package:notepad/Constants/utils.dart';
import 'package:notepad/Services/AuthServices/auth_services.dart';
import 'package:notepad/Services/message_services.dart';

import '../../../../Models/user_model.dart';
import '../../../../Styles/app_style.dart';

class ViewTotalStatuses extends StatefulWidget {
  final User user;
  const ViewTotalStatuses({super.key, required this.user});

  @override
  State<ViewTotalStatuses> createState() => _ViewTotalStatusesState();
}

class _ViewTotalStatusesState extends State<ViewTotalStatuses> {

  MessageServices messageServices = MessageServices();
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Status"),
      ),
      body: ListView.builder(
          itemCount: widget.user.status.length,
          itemBuilder: (context, index) {
        final status = widget.user.status[index];
        final url = status['url'].toString();
        final users = status['users'];
        final time = status['time'];
        return Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                  radius: 27,
                  backgroundImage: NetworkImage(url.toString()), backgroundColor: Colors.white,),
              title: Text("${users.length.toString()} views", style: TextStyle(fontWeight: FontWeight.bold, color: isLightTheme(context) ? Colors.black : Colors.white),),
              subtitle: Text(DateUtil.getMessageTime(context: context, time: time), style: TextStyle(fontSize: 12, color: isLightTheme(context) ? Colors.black54 : Colors.white60),),
              trailing: IconButton(onPressed: (){
                messageServices.deleteStatus(statusId: status['_id'], userId: widget.user.id, context: context, onSuccess: (){
                  setState(() {
                    authService.getUserData(context);
                  });
                  showSnackBar(context, 'Status Deleted Successfully');
                });
              }, icon: Icon(Icons.delete_forever, color: isLightTheme(context) ? Colors.black : Colors.white,)),
            ),
            Divider(color: isLightTheme(context) ? Colors.black54 : Colors.white60,)
          ],
        );
      }),
    );
  }
}
