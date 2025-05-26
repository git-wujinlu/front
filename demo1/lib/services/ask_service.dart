import 'dart:convert';

import 'package:demo1/constants/api_constants.dart';
import 'package:demo1/models/request_model.dart';
import 'package:demo1/services/user_service.dart';
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
      Uri.parse('http://43.143.231.162:4999/recommend'),
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

  Future<bool> askQuestion(String title, String content, List<int> ids) async {
    final _userService = new UserService();
    int id = (await _userService.getUserByUsername())['data']['id'];
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
      print('创建问题结果：${jsonDecode(response.body)}');
      var response2 = await http.put(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.askUsers}'),
        headers: await RequestModel.getHeaders(),
        body: json.encode({
          // 'aid': id,
          'questionId': jsonDecode(response.body)['data'],
          'userIds': ids,
        }),
      );
      if (jsonDecode(response2.body)['success'] == true) {
        print('发送问题结果：${jsonDecode(response2.body)}');
        return true;
      }
      print('发送问题error: ${jsonDecode(response2.body)}');
    }
    print('创建问题error: ${jsonDecode(response.body)}');
    return false;
  }
}
