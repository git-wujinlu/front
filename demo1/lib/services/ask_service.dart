import 'dart:convert';

import 'package:demo1/constants/api_constants.dart';
import 'package:demo1/models/request_model.dart';
import 'package:demo1/services/message_service.dart';
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
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.recommend}'),
      headers: headers,
      body: json.encode({"question": s}),
    );
    if (response.statusCode == 200) {
      print(jsonDecode(response.body)['data']);
      return jsonDecode(response.body)['data'];
    } else {
      print("推荐error:$response");
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
        final MessageService messageService= MessageService();
        for(int i=0;i<ids.length;++i){
          messageService.makeConversation(ids[i], questionId);
        }
        return true;
      } else {
        print('发送问题error: ${jsonDecode(response2.body)}');
        return false;
      }
    } else {
      print('创建问题error: ${jsonDecode(response.body)}');
      return false;
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