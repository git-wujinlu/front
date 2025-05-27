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
    print('开始提问');
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
      int questionId=jsonDecode(response.body)['data']['id'];
      var response2 = await http.put(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.askUsers}'),
        headers: await RequestModel.getHeaders(),
        body: json.encode({
          'questionId': jsonDecode(response.body)['data'],
          'userIds': ids,
        }),
      );
      if (jsonDecode(response2.body)['success'] == true) {
        print('发送问题结果：${jsonDecode(response2.body)}');
        for(int i=0;i<ids.length;++i){
          makeConversation(ids[i], questionId);
        }
        return true;
      }
      print('发送问题error: ${jsonDecode(response2.body)}');
    }
    print('创建问题error: ${jsonDecode(response.body)}');
    return false;
  }

  Future<bool> makeConversation(int user2, int questionId) async {
    var response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.conversation}'),
      headers: await RequestModel.getHeaders(),
      body: json.encode({
        'user2': user2,
        'questionId': questionId,
      }),
    );
    if (jsonDecode(response.body)['success'] == true) {
      print('向$user2 发送问题成功：${jsonDecode(response.body)}');
      return true;
    }
    print('向$user2 发送问题error： ${jsonDecode(response.body)}');
    return false;
  }
}

  Future<List<dynamic>> getConversationList() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/hangzd/conversations'),
        headers: await RequestModel.getHeaders(),
      );
      final userService = UserService();
      int id = (await userService.getUserByUsername())['data']['id'];
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('获取对话列表成功：$responseData');
        for (var item in responseData['data']) {
          if (item['user1'] == id) {
            item['user1'] = -1;
          }
        }
        return responseData['data']; // 如果你后端是放在 data 字段里
      } else {
        print('获取对话列表失败: ${response.body}');
        return [];
      }
    } catch (e) {
      print('请求对话列表异常: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getQuestionById(int questionId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.question}/$questionId');
    final headers = await RequestModel.getHeaders();

    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          print('获取问题成功：$data');
          return data['data'];
        } else {
          print('接口返回失败：$data');
        }
      } else {
        print('HTTP错误 ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('请求失败: $e');
    }
    return null;
  }


}
