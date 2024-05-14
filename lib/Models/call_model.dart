import 'dart:convert';

class Calls {
  final String? id;
  final String callerId;
  final String receiverId;
  final String time;
  final String? duration;

  Calls(
      {this.id,
      required this.callerId,
      required this.receiverId,
      required this.time,
      this.duration});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'callerId': callerId,
      'receiverId': receiverId,
      'time': time,
      'duration': duration
    };
  }

  factory Calls.fromMap(Map<String, dynamic> map) {
    return Calls(
        id: map['_id'] ?? '',
        callerId: map['callerId'] ?? '',
        receiverId: map['receiverId'] ?? '',
        time: map['time'] ?? '',
        duration: map['duration'] ?? ''
    );
  }
  String toJson() => jsonEncode(toMap());
  factory Calls.fromJson(String source) => Calls.fromMap(jsonDecode(source));

}
