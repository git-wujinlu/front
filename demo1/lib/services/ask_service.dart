import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AskService {
  Future<List<dynamic>> search(String s) async {
    final prefs = await SharedPreferences.getInstance();
    var headers = {
      'token': prefs.getString('token') ?? '',
      'username': prefs.getString('username') ?? '',
      'Content-Type': 'application/json',
    };
    print(headers);
    var response = await http.post(
      Uri.parse('http://192.168.107.1:4999/recommend'),
      headers: headers,
      body: json.encode({"question": s}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("error");
    }
    return [];
  }
}