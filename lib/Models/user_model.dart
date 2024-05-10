import 'dart:convert';

class User {
  late String id;
  late String name;
  final String email;
  late String password;
  late String about;
  final String createdAt;
  late String image;
  late String wallpaper;
  final List<dynamic> status;
  late bool is_online;
  late String last_active;
  final String token;
  final String pushToken;

  User(
      {required this.password,
      required this.name,
      required this.id,
      required this.about,
      required this.createdAt,
      required this.email,
      required this.image,
      required this.wallpaper,
      required this.is_online,
      required this.last_active,
      required this.status,
      required this.token,
      required this.pushToken});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'about': about,
      'createdAt': createdAt,
      'image': image,
      'wallpaper': wallpaper,
      'status': status,
      'is_online': is_online,
      'last_active': last_active,
      'token': token,
      'pushToken': pushToken
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
        id: map['_id'] ?? '',
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        password: map['password'] ?? '',
        about: map['about'] ?? '',
        createdAt: map['createdAt'] ?? '',
        image: map['image'] ?? '',
        wallpaper: map['wallpaper'] ?? '',
        status: List<Map<String, dynamic>>.from(
            map['status']?.map((x) => Map<String, dynamic>.from(x))),
        is_online: map['is_online'] ?? false,
        last_active: map['last_active'] ?? '',
        token: map['token'] ?? '',
        pushToken: '');
  }

  String toJson() => jsonEncode(toMap());

  factory User.fromJson(String source) => User.fromMap(jsonDecode(source));

  User copyWith(
      {String? id,
      String? name,
      String? email,
      String? password,
      String? about,
      String? createdAt,
      String? image,
      String? wallpaper,
      List<dynamic>? status,
      bool? is_online,
      String? last_active,
      String? token,
      String? pushToken}) {
    return User(
        password: password ?? this.password,
        name: name ?? this.name,
        id: id ?? this.id,
        about: about ?? this.about,
        createdAt: createdAt ?? this.createdAt,
        email: email ?? this.email,
        image: image ?? this.image,
        wallpaper: wallpaper ?? this.wallpaper,
        is_online: is_online ?? this.is_online,
        last_active: last_active ?? this.last_active,
        status: status ?? this.status,
        token: token ?? this.token,
        pushToken: pushToken ?? this.pushToken);
  }
}
