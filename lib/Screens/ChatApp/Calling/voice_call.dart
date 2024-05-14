import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';
import 'package:notepad/Services/calls_service.dart';
import 'package:notepad/Services/user_services.dart';

import '../../../Models/user_model.dart';
import '../../../utils/settings.dart';

class VoiceCall extends StatefulWidget {
  final User user;
  final User chatUser;

  const VoiceCall({super.key, required this.user, required this.chatUser});

  @override
  State<VoiceCall> createState() => _VoiceCallState();
}

class _VoiceCallState extends State<VoiceCall> {
  late String pushToken = '';
  UserService userService = UserService();
  CallsServices callsServices = CallsServices();
  late String startTime = '';

  getUserPushToken() async {
    pushToken = await userService.getPushToken(
        context: context, id: widget.chatUser.id);
  }

  final AgoraClient _client = AgoraClient(
      agoraConnectionData: AgoraConnectionData(
          appId: appId, channelName: 'ourChat', tempToken: token));

  @override
  void initState() {
    _initAgora();
    super.initState();
    getUserPushToken();
    startTime = DateTime.now().millisecondsSinceEpoch.toString();
    // callsServices.addCall(context: context, user: widget.user, chatUser: widget.chatUser, pushToken: pushToken, time: startTime, duration: '');
  }

  Future<void> _initAgora() async {
    await _client.initialize();
  }

  String getDurationFromSpecificTime(DateTime specificTime) {
    DateTime currentTime = DateTime.now();
    Duration difference = currentTime.difference(specificTime);

    int hours = difference.inHours;
    int minutes = difference.inMinutes.remainder(60);
    int seconds = difference.inSeconds.remainder(60);

    String formattedDuration =
        '${hours.toString().padLeft(2, '0')} hr : ${minutes.toString().padLeft(2, '0')} min : ${seconds.toString().padLeft(2, '0')} secs';

    return formattedDuration;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          widget.chatUser.name,
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          AgoraVideoButtons(
            client: _client,
            enabledButtons: [BuiltInButtons.toggleMic, BuiltInButtons.callEnd],
            onDisconnect: () {
              callsServices.addCall(
                  context: context,
                  user: widget.user,
                  chatUser: widget.chatUser,
                  pushToken: pushToken,
                  time: startTime,
                  duration: getDurationFromSpecificTime(
                      DateTime.fromMillisecondsSinceEpoch(
                          int.parse(startTime))));
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }
}
