import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notepad/Constants/date_util.dart';
import 'package:notepad/Models/call_model.dart';
import 'package:notepad/Screens/ChatApp/Calling/call_add.dart';
import 'package:notepad/Services/calls_service.dart';
import 'package:page_transition/page_transition.dart';

import '../../../Models/user_model.dart';
import '../../../Styles/app_style.dart';

class CallsScreen extends StatefulWidget {
  final User user;

  const CallsScreen({super.key, required this.user});

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  CallsServices callsServices = CallsServices();
  late List<Calls> calls = [];
  late List<User> users = [];
  int selectedIndex = -1;

  getCalls() async {
    calls = await callsServices.getCalls(context: context, userId: widget.user.id);
    for(int i = 0; i<calls.length; i++) {
      if(calls[i].callerId == widget.user.id) {
        User user = await callsServices.findUser(context: context, userId: calls[i].receiverId);
        users.add(user);
      } else{
        User user = await callsServices.findUser(context: context, userId: calls[i].callerId);
        users.add(user);
      }
    }
    setState(() {});
  }
  getRandomColor() {
    Random random = Random();
    return AppStyle.cardsColor[random.nextInt(AppStyle.cardsColor.length)];
  }

  @override
  void initState() {
    getCalls();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
          itemCount: users.length,
          shrinkWrap: true,
          reverse: true,
          itemBuilder: (context, index) {
        return
            Column(
              children: [
                InkWell(
                  onTap: (){
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: selectedIndex == index ? Container(
                    padding: EdgeInsets.all(16),
                    color: getRandomColor(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.black,
                              backgroundImage: NetworkImage(users[index].image.toString()),),
                            SizedBox(width: 20,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(users[index].name, style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),),
                                SizedBox(height: 10,),
                                Text(DateUtil.getMessageTime(context: context, time: calls[index].time), style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),),
                                SizedBox(height: 10,),
                                Text(calls[index].duration!, style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 16),)
                              ],
                            ),
                          ],
                        ),
                        IconButton(onPressed: (){
                          Navigator.push(context, PageTransition(child: CallsAdd(), type: PageTransitionType.bottomToTopJoined, childCurrent: CallsScreen(user: widget.user)));
                        }, icon: Icon(Icons.call, color: Colors.black,))
                      ],
                    ),
                  ) :Container(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundImage: NetworkImage(users[index].image.toString()),),
                        SizedBox(width: 20,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(users[index].name, style: TextStyle(color: isLightTheme(context) ? Colors.black : Colors.white, fontSize: 18),),
                            SizedBox(height: 10,),
                            Text(DateUtil.getMessageTime(context: context, time: calls[index].time), style: TextStyle(color: isLightTheme(context) ? Colors.black54 : Colors.white60),),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(thickness: .5, color: isLightTheme(context) ? Colors.black54 : Colors.white60,),
              ],
            );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, PageTransition(child: CallsAdd(), type: PageTransitionType.bottomToTopJoined, childCurrent: CallsScreen(user: widget.user)));
        },
        child: Icon(Icons.add_call),
      ),
    );
  }
}
