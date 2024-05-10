import 'dart:convert';

class Message{
  final String? id;
  final String sender;
  final String receiver;
  late String text;
  final String sentAt;
  late String? readAt;
  final String type;

  Message({
    this.id,
    required this.sender,
    required this.receiver,
    required this.text,
    required this.sentAt,
    this.readAt,
    required this.type,
});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender': sender,
      'receiver': receiver,
      'text': text,
      'sentAt': sentAt,
      'readAt': readAt,
      'type': type
    };
  }

  // factory Message.fromJson(Map<String, dynamic> json) {
  //   return Message(sender: json['sender'], receiver: json['receiver'], text: json['text'], type: json['type']);
  // }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['_id'] ?? '',
      sender: map['sender'] ?? '',
      receiver: map['receiver'] ?? '',
      text: map['text'] ?? '',
      sentAt: map['sentAt'] ?? '',
      readAt: map['readAt'] ?? '',
      type: map['type'] ?? ''
    );
  }
  String toJson() => jsonEncode(toMap());

  factory Message.fromJson(String source) => Message.fromMap(jsonDecode(source));

}