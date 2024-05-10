import 'package:shared_preferences/shared_preferences.dart';

class ServerName {
  static SharedPreferences? _prefs;
  static const _keyServerName = "server_name";

  static Future init() async => _prefs = await SharedPreferences.getInstance();

  static Future setServerName(String server) async => await _prefs!.setString(_keyServerName, server);

  static String getServerName() => _prefs!.getString(_keyServerName) ?? 'http://192.168.53.163:3000';
}