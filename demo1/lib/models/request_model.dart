import 'package:shared_preferences/shared_preferences.dart';

class RequestModel {
  final String? token;
  final String? username;

  RequestModel({this.token, this.username});

  static Future<Map<String, String>> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      if (prefs.getString('token') != null) 'token': prefs.getString('token')!,
      if (prefs.getString('username') != null)
        'username': prefs.getString('username')!,
      'Content-Type': 'application/json'
    };
  }

  Map<String, String> toHeaders() {
    return {
      if (token != null) 'token': token!,
      if (username != null) 'username': username!,
    };
  }
}
