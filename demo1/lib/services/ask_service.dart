import 'dart:convert';

import 'package:demo1/constants/api_constants.dart';
import 'package:demo1/models/request_model.dart';
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

  Future<bool> askQuestion(String title, String content) async {
    var response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.question}'),
        headers: await RequestModel.getHeaders(),
        body: json.encode({
          "images": '1',
          "categoryId": '1',
          "title": title,
          "content": content,
        }));
    if (jsonDecode(response.body)['success'] == true) {
      print(jsonDecode(response.body));
      return true;
    }
    print(jsonDecode(response.body));
    return false;
  }
}
