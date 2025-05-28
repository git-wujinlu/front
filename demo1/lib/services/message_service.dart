import 'dart:convert';

import 'package:demo1/constants/api_constants.dart';
import 'package:demo1/models/request_model.dart';
import 'package:demo1/services/user_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MessageService {
  final userService = UserService();

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
      print('与$user2 创建对话成功：${jsonDecode(response.body)}');
      return true;
    } else {
      print('与$user2 创建对话error： ${jsonDecode(response.body)}');
    }
    return false;
  }

  Future<List<dynamic>> getConversationList() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/hangzd/conversations'),
        headers: await RequestModel.getHeaders(),
      );
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

  Future<Map<String, dynamic>> getMessagesBetweenUsers(
      String username1,
      String username2,
      int conversationId,
      ) async {
    try {
      // 获取第一个用户的 ID
      final senderId = (await userService.getOtherUserByUsername(username1))['data']['id'];
      final receiverId = (await userService.getOtherUserByUsername(username2))['data']['id'];
      // 获取双方之间的消息
      final url = 'http://43.143.231.162:8000/api/hangzd/messages/sender/$senderId/receiver/$receiverId/conv/$conversationId';
      final responseMessages = await http.get(
        Uri.parse(url),
        headers: await RequestModel.getHeaders(),
      );

      if (responseMessages.statusCode == 200) {
        final responseData = jsonDecode(responseMessages.body);
        print('获取消息成功: $responseData');
        return responseData;
      } else {
        print('获取消息失败: ${responseMessages.body}');
        return {};
      }
    } catch (e) {
      print('请求消息列表异常: $e');
      return {};
    }
  }

  Future<void> addMessage(int toId,int conversationId, String content) async {
    try {
      // 第二步：获取当前用户token和username
      final prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString('token') ?? '';
      final String username = prefs.getString('username') ?? '';
      final int myId = (await userService.getUserByUsername())['data']['id'];
      // 第三步：构造HTTP请求发送消息
      final url = Uri.parse('http://43.143.231.162:8000/api/hangzd/message');
      final request = http.Request('POST', url);
      request.body = json.encode({
        'fromId':myId,
        'toId': toId,
        'content': content,
        'type': 'answer', // 如果有类型变更逻辑，可单独提出来
        'conversationId': conversationId
      });
      request.headers.addAll({
        'token': token,
        'username': username,
        'Content-Type': 'application/json',
      });

      final responseStream = await request.send();

      if (responseStream.statusCode == 200) {
        final responseBody = await responseStream.stream.bytesToString();
        print('消息发送成功: $responseBody');
      } else {
        final error = await responseStream.stream.bytesToString();
        print('消息发送失败: ${responseStream.statusCode} $error');
        throw Exception('消息发送失败: ${responseStream.reasonPhrase}');
      }
    } catch (e) {
      print('addMessage 错误: $e');
      rethrow;
    }
  }

  Future<void> like(String targetUsername, int value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final username = prefs.getString('username') ?? '';

      final headers = {
        'token': token,
        'username': username,
        'Content-Type': 'application/json',
      };

      final request = http.Request(
        'POST',
        Uri.parse('http://43.143.231.162:8000/api/hangzd/user/like'),
      );

      request.body = json.encode({
        'username': targetUsername,
        'increment': value, // 1 表示好评，-1 表示差评
      });

      request.headers.addAll(headers);
      print('准备点赞：target=$targetUsername, value=$value');
      print('请求头: $headers');
      print('请求体: ${request.body}');

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        print('评价成功: $responseBody');
      } else {
        print('评价失败: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('发送 like 请求失败: $e');
      rethrow;
    }
  }

}