import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notepad/Constants/date_util.dart';
import 'package:notepad/Constants/utils.dart';
import 'package:notepad/Models/message_model.dart';
import 'package:notepad/Models/user_model.dart';
import 'package:notepad/Screens/ChatApp/chat_user_profile_screen.dart';
import 'package:notepad/Screens/image_viewer.dart';
import 'package:notepad/Services/message_services.dart';
import 'package:notepad/Services/user_services.dart';
import 'package:notepad/Styles/app_style.dart';
import 'package:notepad/Widgets/chatting_bubble.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../../main.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../Camera/camera_screen.dart';

class ChattingScreen extends StatefulWidget {
  final User chatUser;
  final User user;

  const ChattingScreen({super.key, required this.chatUser, required this.user});

  @override
  State<ChattingScreen> createState() => _ChattingScreenState();
}

class _ChattingScreenState extends State<ChattingScreen> {
  TextEditingController _messageController = TextEditingController();
  MessageServices messageServices = MessageServices();
  UserService userService = UserService();
  bool isTyping = false;
  bool _showEmoji = false;
  List<Message> messages = [];
  late IO.Socket socket;
  final recorder = AudioRecorder();
  late String pushToken = '';
  final _formKey = GlobalKey<FormState>();

  getMessages() async {
    messages = await messageServices.getMessages(
        context: context,
        userId: widget.user.id,
        chatUserId: widget.chatUser.id);
    setState(() {});
  }

  getUserPushToken() async {
    pushToken = await userService.getPushToken(
        context: context, id: widget.chatUser.id);
  }

  @override
  void initState() {
    connect();
    getMessages();
    super.initState();
    getUserPushToken();
  }

  void connect() {
    // Initialize the Socket.io connection
    socket = IO.io(uri, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false
    });

    // Emit a 'signIn' event with the user's ID
    socket.emit('signIn', widget.user.id);
    socket.on('signIn', (id) {
      widget.chatUser.id == id
          ? setState(() {
              widget.chatUser.is_online = true;
            })
          : setState(() {});
      ;
    });
    socket.on('userDisconnected', (id) {
      widget.chatUser.id == id
          ? setState(() {
              widget.chatUser.is_online = false;
            })
          : setState(() {});
    });
    socket.on('isTyping', (params) {
      final userId = params['param2'];
      final chatUserId = params['param1'];
      widget.chatUser.id == chatUserId && widget.user.id == userId
          ? setState(() {
              isTyping = true;
            })
          : setState(() {});
    });
    socket.on('isNotTyping', (params) {
      final userId = params['param2'];
      final chatUserId = params['param1'];
      widget.chatUser.id == chatUserId && widget.user.id == userId
          ? setState(() {
              isTyping = false;
            })
          : setState(() {});
    });
    socket.on('profileUpdated', (params) {
      final userId = params['id'];
      final userName = params['name'];
      final userAbout = params['about'];
      if (userId == widget.chatUser.id) {
        setState(() {
          widget.chatUser.name = userName;
          widget.chatUser.about = userAbout;
        });
      }
    });
    socket.on('proPicUpdated', (params) {
      final userId = params['id'];
      final image = params['image'];
      widget.chatUser.id == userId
          ? setState(() {
              widget.chatUser.image = image.toString();
            })
          : setState(() {});
    });

    // Listen for 'message' events
    socket.on("message", (msg) {
      // Update the UI with the received message
      setState(() {
        messages.add(Message(
            id: msg['id'].toString(),
            sender: msg['senderId'].toString(),
            receiver: msg['receiverId'].toString(),
            text: msg['text'].toString(),
            type: msg['type'].toString(),
            readAt: msg['readAt'].toString(),
            sentAt: msg['sentAt'].toString()));
      });
    });
    socket.on('MessageRead', (msg) {
      setState(() {
        messageServices.getMessages(context: context, userId: widget.user.id, chatUserId: widget.chatUser.id);
      });
    });
    socket.on('updateMessage', (msg) {
      setState(() {
        getMessages();
      });
    });
    socket.on('deleteMessage', (message) {
      setState(() {
        getMessages();
      });
    });
    // Listen for the 'connect' event
    socket.onConnect((data) {
      // Update the user's online status
      userService.updateOnlineStatus(
          context: context,
          isOnline: true,
          last_active: DateTime.now().millisecondsSinceEpoch.toString());

      // Print a message when connected
      print("Connected");
    });

    // Connect to the server
    socket.connect();

    // Print the connection status
    print(socket.connected);
  }

  void sendMessage() {
    messageServices.sendMessage(
        context: context,
        senderId: widget.user.id,
        receiverId: widget.chatUser.id,
        text: _messageController.text.trim(),
        type: 'text',
        readAt: '',
        sentAt: DateTime.now().millisecondsSinceEpoch.toString(),
        chatUser: widget.chatUser,
        user: widget.user,
        pushToken: pushToken,
        onSuccess: () {
          socket.emit('message', {
            'id': messageId,
            'senderId': widget.user.id,
            'receiverId': widget.chatUser.id,
            'text': _messageController.text.trim(),
            'type': 'text',
            'readAt': '',
            'sentAt': DateTime.now().millisecondsSinceEpoch.toString()
          });
          setState(() {
            messages.add(Message(
                id: messageId,
                sender: widget.user.id,
                receiver: widget.chatUser.id,
                text: _messageController.text.trim(),
                type: 'text',
                readAt: '',
                sentAt: DateTime.now().millisecondsSinceEpoch.toString()));
          });
          _messageController.clear();
          socket.emit('isNotTyping',
              {'param1': widget.user.id, 'param2': widget.chatUser.id});
        });
  }

  void sendMediaMessage(String type, XFile image) {
    messageServices.sendMediaMessage(
        context: context,
        senderId: widget.user.id,
        receiverId: widget.chatUser.id,
        type: type,
        readAt: '',
        sentAt: DateTime.now().millisecondsSinceEpoch.toString(),
        image: image,
        user: widget.user,
        chatUser: widget.chatUser,
        pushToken: pushToken,
        onSuccess: () {
          socket.emit('message', {
            'id': messageId,
            'senderId': widget.user.id,
            'receiverId': widget.chatUser.id,
            'text': mediaUrl,
            'type': type,
            'readAt': '',
            'sentAt': DateTime.now().millisecondsSinceEpoch.toString()
          });
          setState(() {
            messages.add(Message(
                sender: widget.user.id,
                receiver: widget.chatUser.id,
                text: mediaUrl,
                type: type,
                readAt: '',
                sentAt: DateTime.now().millisecondsSinceEpoch.toString()));
          });
          messageServices.sendPushNotification(
              context: context,
              pushToken: pushToken,
              message: Message(
                  sender: widget.user.id,
                  receiver: widget.chatUser.id,
                  text: mediaUrl,
                  type: type,
                  readAt: '',
                  sentAt: DateTime.now().millisecondsSinceEpoch.toString()),
              user: widget.user);
        });
  }

  void sendGif(String type, XFile image) {
    messageServices.sendGif(
        context: context,
        senderId: widget.user.id,
        receiverId: widget.chatUser.id,
        type: type,
        readAt: '',
        sentAt: DateTime.now().millisecondsSinceEpoch.toString(),
        image: image,
        user: widget.user,
        chatUser: widget.chatUser,
        pushToken: pushToken, onSuccess: () {
      socket.emit('message', {
        'id': messageId,
        'senderId': widget.user.id,
        'receiverId': widget.chatUser.id,
        'text': mediaUrl,
        'type': type,
        'readAt': '',
        'sentAt': DateTime.now().millisecondsSinceEpoch.toString()
      });
      setState(() {
        messages.add(Message(
            sender: widget.user.id,
            receiver: widget.chatUser.id,
            text: mediaUrl,
            type: type,
            readAt: '',
            sentAt: DateTime.now().millisecondsSinceEpoch.toString()));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    sortMessages() {
      messages.sort((b, a) => a.sentAt.compareTo(b.sentAt));
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: widget.user.wallpaper.isNotEmpty
            ? BoxDecoration(
                image: DecorationImage(
                    image: CachedNetworkImageProvider(widget.user.wallpaper),
                    fit: BoxFit.cover))
            : BoxDecoration(),
        child: WillPopScope(
          onWillPop: () {
            if (_showEmoji) {
              setState(() {
                _showEmoji = !_showEmoji;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            backgroundColor: widget.user.wallpaper.isNotEmpty
                ? Colors.transparent
                : isLightTheme(context)
                    ? AppStyle.cardsColor[6]
                    : Colors.black54,
            appBar: AppBar(
              iconTheme: IconThemeData(color: Colors.white),
              title: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ChatUserProfileScreen(
                                chatUser: widget.chatUser,
                                messages: messages,
                              )));
                },
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 18.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => ImageViewer(
                                      text: widget.chatUser.name,
                                      image: widget.chatUser.image)));
                        },
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(widget.chatUser.image),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.chatUser.name,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                          isTyping && widget.chatUser.is_online
                              ? Text(
                                  'Typing...',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.white),
                                )
                              : widget.chatUser.is_online
                                  ? Text(
                                      'online',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.white),
                                    )
                                  : Text(
                                      overflow: TextOverflow.fade,
                                      DateUtil.getLastActiveTime(
                                          context: context,
                                          lastActive:
                                              widget.chatUser.last_active),
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.white))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                PopupMenuButton<String>(
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem(
                          child: Text("Refresh Chat"),
                          value: 'refresh',
                          onTap: (){
                            setState(() {
                              getMessages();
                            });
                          },
                        ),
                        PopupMenuItem(
                          child: Text("Set Wallpaper"),
                          value: 'wallpaper',
                          onTap: () async {
                            final ImagePicker _picker = ImagePicker();
                            final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                            if (image != null) {
                              userService.updateWallpaper(context: context, user: widget.user, image: image, onSuccess: (){
                                setState(() {
                                  widget.user.wallpaper = wallpaperUrl;
                                });
                              });
                            }
                          },
                        ),
                        PopupMenuItem(
                          child: Text("Delete Chat"),
                          value: 'delete',
                          onTap: (){
                            if (messages.isNotEmpty)
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Are you sure?"),
                                          Icon(
                                            Icons.info_outline,
                                            color: Colors.black,
                                          )
                                        ],
                                      ),
                                      content: Text(
                                          "All the messages sent by you will be deleted!"),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              for (int i = 0;
                                              i < messages.length;
                                              i++) {
                                                messageServices.deleteMessage(
                                                    context: context,
                                                    message: messages[i],
                                                    user: widget.user,
                                                    onSuccess: () {
                                                      setState(() {
                                                        getMessages();
                                                      });
                                                      socket.emit('deleteMessage',
                                                          (messages[i]));
                                                    });
                                              }
                                              Navigator.pop(context);
                                            },
                                            child: const Text("Delete")),
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text("Cancel")),
                                      ],
                                    );
                                  });
                          },
                        ),
                      ];
                    }),
              ],
            ),
            body: Container(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                        shrinkWrap: true,
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          sortMessages();
                          return InkWell(
                              highlightColor: isLightTheme(context)
                                  ? LightMode.accentColor.withOpacity(0.2)
                                  : DarkMode.accentColor.withOpacity(0.2),
                              splashColor: isLightTheme(context)
                                  ? LightMode.accentColor.withOpacity(0.2)
                                  : DarkMode.accentColor.withOpacity(0.2),
                              onLongPress: () {
                                messages[index].type != 'text'
                                    ? showMediaOptions(messages[index])
                                    : showOptions(messages[index]);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: ChatBubble(
                                  message: messages[index],
                                  onSuccess: () {
                                    socket.emit(
                                        'messageRead', (messages[index]));
                                  }, progress: '',
                                ),
                              ));
                        }),
                  ),
                  _chatInput(),
                  if (_showEmoji)
                    SizedBox(
                        height: mq.height * .35,
                        child: EmojiPicker(
                          textEditingController: _messageController,
                          config: Config(
                              bottomActionBarConfig: BottomActionBarConfig(
                                backgroundColor: Colors.transparent,
                                buttonColor: Colors.transparent,
                                buttonIconColor: isLightTheme(context)
                                    ? LightMode.mainColor
                                    : DarkMode.mainColor,
                                showSearchViewButton: false,
                              ),
                              categoryViewConfig: CategoryViewConfig(
                                backgroundColor: Colors.transparent,
                                dividerColor: Colors.transparent,
                                indicatorColor: Colors.transparent,
                              ),
                              emojiViewConfig: EmojiViewConfig(
                                backgroundColor: Colors.transparent,
                                columns: 8,
                              )),
                        ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<XFile> convertUint8ListToXFile(Uint8List uint8List) async {
    final tempDir = await getTemporaryDirectory();
    final tempPath = tempDir.path + '/temp_image.png';

    // Write the Uint8List data to a temporary file
    await File(tempPath).writeAsBytes(uint8List);

    return XFile(tempPath);
  }

  Widget _chatInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Card(
              color: isLightTheme(context) ? Colors.white : Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _showEmoji = !_showEmoji;
                        });
                      },
                      icon: Icon(
                        size: 26,
                        Icons.emoji_emotions,
                        color: isLightTheme(context)
                            ? LightMode.accentColor
                            : DarkMode.accentColor,
                      )),
                  Expanded(
                      child: TextFormField(
                    contentInsertionConfiguration:
                        ContentInsertionConfiguration(
                      onContentInserted: (value) async {
                        final content = value.data;
                        if (content is Uint8List) {
                          convertUint8ListToXFile(content).then((xFile) {
                            sendGif('gif', xFile);
                          });
                        } else {
                          // Handle other types of content
                          setState(() {
                            _messageController.text = content.toString();
                          });
                        }
                      },
                      allowedMimeTypes: [
                        'image/png',
                        'image/jpeg',
                        'image/gif'
                      ],
                    ),
                    onTap: () {
                      if (_showEmoji)
                        setState(() {
                          _showEmoji = !_showEmoji;
                        });
                    },
                    onChanged: (value) {
                      if (value.length > 0) {
                        socket.emit('isTyping', {
                          'param1': widget.user.id,
                          'param2': widget.chatUser.id
                        });
                      } else {
                        socket.emit('isNotTyping', {
                          'param1': widget.user.id,
                          'param2': widget.chatUser.id
                        });
                      }
                    },
                    textCapitalization: TextCapitalization.sentences,
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 5,
                    controller: _messageController,
                    decoration: InputDecoration(
                        hintText: "Type here...",
                        hintStyle: TextStyle(
                            color: isLightTheme(context)
                                ? LightMode.accentColor
                                : DarkMode.accentColor),
                        border: InputBorder.none),
                  )),
                  IconButton(
                      onPressed: _imageSelection,
                      icon: Icon(
                        size: 26,
                        Icons.image,
                        color: isLightTheme(context)
                            ? LightMode.accentColor
                            : DarkMode.accentColor,
                      )),
                  IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => CameraScreen(
                                      user: widget.user,
                                      chatUser: widget.chatUser,
                                      messages: messages,
                                    )));
                      },
                      icon: Icon(
                        size: 26,
                        Icons.camera_alt_rounded,
                        color: isLightTheme(context)
                            ? LightMode.accentColor
                            : DarkMode.accentColor,
                      )),
                  SizedBox(
                    width: mq.width * .02,
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 3.0),
            child: MaterialButton(
              onPressed: () {
                if (_messageController.text.trim().isNotEmpty) {
                  sendMessage();
                }
              },
              child: Icon(
                Icons.send,
                color: Colors.white,
              ),
              shape: CircleBorder(),
              minWidth: 25,
              color: isLightTheme(context)
                  ? LightMode.mainColor
                  : DarkMode.mainColor,
              height: 40,
            ),
          )
        ],
      ),
    );
  }

  Future _imageSelection() {
    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (builder) => Container(
              width: mq.width,
              height: mq.height * .3,
              margin: EdgeInsets.all(16),
              child: Card(
                color: isLightTheme(context)
                    ? LightMode.mainColor
                    : DarkMode.mainColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "Select Media File",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () async {
                            final ImagePicker _picker = ImagePicker();
                            final List<XFile> images =
                                await _picker.pickMultiImage();
                            for (var image in images) {
                              sendMediaMessage('image', image);
                            }
                            Navigator.pop(context);
                          },
                          child: CircleAvatar(
                              radius: 48,
                              child: Icon(
                                Icons.insert_photo,
                                color: isLightTheme(context)
                                    ? LightMode.mainColor
                                    : DarkMode.mainColor,
                                size: 48,
                              )),
                        ),
                        InkWell(
                          onTap: () async {
                            final ImagePicker _picker = ImagePicker();
                            final XFile? video = await _picker.pickVideo(
                                source: ImageSource.gallery);
                            if (video != null) {
                              Navigator.pop(context);
                              sendMediaMessage('video', video);
                            }
                          },
                          child: CircleAvatar(
                              radius: 48,
                              child: Icon(
                                Icons.video_camera_back_rounded,
                                color: isLightTheme(context)
                                    ? LightMode.mainColor
                                    : DarkMode.mainColor,
                                size: 48,
                              )),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ));
  }

  Future showOptions(Message message) {
    return showModalBottomSheet(
        backgroundColor:
            isLightTheme(context) ? LightMode.mainColor : Colors.black,
        context: context,
        builder: (_) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 15),
            height: mq.height * .48,
            child: ListView(
              children: [
                InkWell(
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: message.text))
                        .then((value) {
                      Navigator.pop(context);
                      showSnackBar(context, 'Message copied to clipboard');
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      height: mq.height * .05,
                      child: Row(
                        children: [
                          Icon(Icons.copy_all),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            "Copy Text",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Divider(),
                if (message.sender == widget.user.id)
                  InkWell(
                    onTap: () {
                      showDialog(context: context, builder: (BuildContext context) {
                        return AlertDialog(
                          title: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Edit Message"),
                              Icon(
                                Icons.info_outline,
                                color: Colors.black,
                              )
                            ],
                          ),
                          content: Form(
                            key: _formKey,
                            child: TextFormField(
                              // controller: _textController,
                              initialValue: message.text,
                              onSaved: (text) => message.text = text ?? '',
                              validator: (text) =>
                              text != null && text.isNotEmpty ? null : "Enter Text",
                              decoration: InputDecoration(
                                  hintText: "Enter your Message",
                                  label: Text('Message'),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  prefixIcon: Icon(
                                    Icons.person,
                                    color: isLightTheme(context)
                                        ? LightMode.mainColor
                                        : DarkMode.mainColor,
                                  )),
                            ),
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
                            TextButton(onPressed: (){if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              messageServices.updateMessage(context: context, message: message, user: widget.user, text: message.text, onSuccess: (){
                                Navigator.pop(context);
                                Navigator.pop(context);
                                setState(() {
                                  messageServices.getMessages(context: context, userId: widget.user.id, chatUserId: widget.chatUser.id);
                                });
                                socket.emit('updateMessage', (message));
                              });
                            }
                            }, child: Text("Update")),
                          ],
                        );
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        height: mq.height * .05,
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(
                              width: 20,
                            ),
                            Text("Edit Message",
                                style: TextStyle(color: Colors.white))
                          ],
                        ),
                      ),
                    ),
                  ),
                if (message.sender == widget.user.id) Divider(),
                if (message.sender == widget.user.id)
                  InkWell(
                    onTap: () {
                      messageServices.deleteMessage(
                          context: context,
                          message: message,
                          user: widget.user,
                          onSuccess: () {
                            Navigator.pop(context);
                            setState(() {
                              messages.remove(message);
                            });
                            socket.emit('deleteMessage', (message));
                          });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        height: mq.height * .05,
                        child: Row(
                          children: [
                            Icon(CupertinoIcons.delete),
                            SizedBox(
                              width: 20,
                            ),
                            Text("Delete Message",
                                style: TextStyle(color: Colors.white))
                          ],
                        ),
                      ),
                    ),
                  ),
                if (message.sender == widget.user.id) Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    height: mq.height * .05,
                    child: Row(
                      children: [
                        Icon(Icons.done_all),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                            "Sent At: ${DateUtil.getMessageTime(context: context, time: message.sentAt)}",
                            style: TextStyle(color: Colors.white))
                      ],
                    ),
                  ),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    height: mq.height * .05,
                    child: Row(
                      children: [
                        Icon(Icons.remove_red_eye_outlined),
                        SizedBox(
                          width: 20,
                        ),
                        message.readAt!.isEmpty
                            ? Text("Not read yet!",
                                style: TextStyle(color: Colors.white))
                            : Text(
                                "Read At: ${DateUtil.getMessageTime(context: context, time: message.readAt!)}",
                                style: TextStyle(color: Colors.white))
                      ],
                    ),
                  ),
                ),
                Divider(),
              ],
            ),
          );
        });
  }

  Future showMediaOptions(Message message) {
    return showModalBottomSheet(
        backgroundColor:
            isLightTheme(context) ? LightMode.mainColor : Colors.black,
        context: context,
        builder: (_) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 15),
            height: mq.height * .48,
            child: ListView(
              children: [
                InkWell(
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: message.text))
                        .then((value) {
                      Navigator.pop(context);
                      showSnackBar(context, 'Message copied to clipboard');
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      height: mq.height * .05,
                      child: Row(
                        children: [
                          Icon(Icons.copy_all),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            "Copy Link",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Divider(),
                InkWell(
                  onTap: () {
                    if(message.type == 'image') _saveNetworkImage(message);
                    else if(message.type == 'gif') _saveNetworkGifFile(message);
                    else if(message.type == 'video') _saveNetworkVideoFile(message, '');
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      height: mq.height * .05,
                      child: Row(
                        children: [
                          Icon(Icons.download),
                          SizedBox(
                            width: 20,
                          ),
                          Text("Download Media",
                              style: TextStyle(color: Colors.white))
                        ],
                      ),
                    ),
                  ),
                ),
                Divider(),
                if (message.sender == widget.user.id)
                  InkWell(
                    onTap: () {
                      messageServices.deleteMessage(
                          context: context,
                          message: message,
                          user: widget.user,
                          onSuccess: () {
                            Navigator.pop(context);
                            setState(() {
                              messages.remove(message);
                            });
                            socket.emit('deleteMessage', (message));
                          });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        height: mq.height * .05,
                        child: Row(
                          children: [
                            Icon(CupertinoIcons.delete),
                            SizedBox(
                              width: 20,
                            ),
                            Text("Delete Media File",
                                style: TextStyle(color: Colors.white))
                          ],
                        ),
                      ),
                    ),
                  ),
                if (message.sender == widget.user.id) Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    height: mq.height * .05,
                    child: Row(
                      children: [
                        Icon(Icons.done_all),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                            "Sent At: ${DateUtil.getMessageTime(context: context, time: message.sentAt)}",
                            style: TextStyle(color: Colors.white))
                      ],
                    ),
                  ),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    height: mq.height * .05,
                    child: Row(
                      children: [
                        Icon(Icons.remove_red_eye_outlined),
                        SizedBox(
                          width: 20,
                        ),
                        message.readAt!.isEmpty
                            ? Text("Not read yet!",
                                style: TextStyle(color: Colors.white))
                            : Text(
                                "Read At: ${DateUtil.getMessageTime(context: context, time: message.readAt!)}",
                                style: TextStyle(color: Colors.white))
                      ],
                    ),
                  ),
                ),
                Divider(),
              ],
            ),
          );
        });
  }
  _saveNetworkImage(Message message) async {
    final time = DateUtil.getFormattedTime(context: context, time: DateTime.now().millisecondsSinceEpoch.toString());
    var response = await Dio().get(
        message.text,
        options: Options(responseType: ResponseType.bytes));
    await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.data), name: "NoteImage-$time");
    Navigator.pop(context);
  }

  _saveNetworkGifFile(Message message) async {
    final time = DateUtil.getFormattedTime(context: context, time: DateTime.now().millisecondsSinceEpoch.toString());
    var appDocDir = await getTemporaryDirectory();
    String savePath = appDocDir.path + "/NoteGif-$time.gif";
    String fileUrl =
        message.text;
    await Dio().download(fileUrl, savePath);
    await ImageGallerySaver.saveFile(savePath, isReturnPathOfIOS: true);
    Navigator.pop(context);
  }

  _saveNetworkVideoFile(Message message, String progress) async {
    final time = DateUtil.getFormattedTime(context: context, time: DateTime.now().millisecondsSinceEpoch.toString());
    var appDocDir = await getTemporaryDirectory();
    String savePath = appDocDir.path + "/NoteVideo-$time.mp4";
    String fileUrl =
        message.text;
    await Dio().download(fileUrl, savePath, onReceiveProgress: (count, total) {
      setState(() {
        progress = (count / total * 100).toStringAsFixed(0) + "%";
      });
    });
    await ImageGallerySaver.saveFile(savePath);
    Navigator.pop(context);
  }
}
