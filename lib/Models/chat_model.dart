import 'package:notepad/Models/user_model.dart';

class ChatModel{
  final User user;
  final String time;
  final String currentMessage;
  ChatModel({required this.time, required this.currentMessage, required this.user});
}