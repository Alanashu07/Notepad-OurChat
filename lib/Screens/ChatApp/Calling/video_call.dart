import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';
import 'package:notepad/utils/settings.dart';

import '../../../Models/user_model.dart';

class VideoCall extends StatefulWidget {
  final User chatUser;
  const VideoCall({super.key, required this.chatUser});

  @override
  State<VideoCall> createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {

  final AgoraClient _client = AgoraClient(agoraConnectionData: AgoraConnectionData(appId: appId, channelName: 'ourChat', tempToken: token), enabledPermission: [Permission.audio, Permission.bluetoothConnect], );

  @override
  void initState() {
    _initAgora();
    super.initState();
  }

  Future<void> _initAgora() async {
    await _client.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(widget.chatUser.name, style: TextStyle(color: Colors.white),), centerTitle: true,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              AgoraVideoViewer(client: _client),
              AgoraVideoButtons(client: _client, autoHideButtons: true,)
            ],
          ),
        ),
      ),
    );
  }
}
