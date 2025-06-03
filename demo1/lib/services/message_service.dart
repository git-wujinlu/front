import 'dart:convert';
import 'dart:io';

import 'package:demo1/constants/api_constants.dart';
import 'package:demo1/models/request_model.dart';
import 'package:demo1/services/user_service.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
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
      final senderId =
          (await userService.getOtherUserByUsername(username1))['data']['id'];
      final receiverId =
          (await userService.getOtherUserByUsername(username2))['data']['id'];
      // 获取双方之间的消息
      final url =
          'http://43.143.231.162:8000/api/hangzd/messages/sender/$senderId/receiver/$receiverId/conv/$conversationId';
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

  Future<void> addMessage(int toId, int conversationId, String content) async {
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
        'fromId': myId,
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

  Future<void> like(int conversationId) async {
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
        'PUT',
        Uri.parse('http://43.143.231.162:8000/api/hangzd/user/like'),
      );
      request.body = json.encode({'cid': conversationId});
      request.headers.addAll(headers);
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

  Future<String?> pickAndUploadImage(int toId, int conversationId) async {
    try {
      // 选择图片
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile == null) {
        print('用户取消选择图片');
        return null;
      }

      final File file = File(pickedFile.path);
      final String fileName = basename(file.path);
      final String? mimeType = lookupMimeType(file.path);
      final mime = mimeType?.split('/') ?? ['application', 'octet-stream'];

      // 获取本地缓存的 token 和用户名
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final username = prefs.getString('username') ?? '';

      final uri = Uri.parse('http://43.143.231.162:8000/api/hangzd/oss/upload');
      final request = http.MultipartRequest('POST', uri);

      // 添加字段头部
      request.headers.addAll({
        'token': token,
        'username': username,
        'Content-Type': 'multipart/form-data',
      });

      // 添加文件字段
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: MediaType(mime[0], mime[1]),
        filename: fileName,
      ));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final Map<String, dynamic> decoded = json.decode(responseBody);
        final String filePath = decoded['data'];
        print('上传成功: $decoded');

        final String fullUrl = '${ApiConstants.ossBaseUrl}$filePath';

        // 发送消息
        addMessage(toId, conversationId, fullUrl);

        return fullUrl;
      } else {
        print('上传失败: ${response.statusCode} - ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      print('上传图片失败: $e');
      return null;
    }
  }

  Future<void> endConversation(int conversationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final username = prefs.getString('username') ?? '';

      var headers = {
        'token': token,
        'username': username,
      };

      var url =
          'http://43.143.231.162:8000/api/hangzd/conversation/$conversationId/end';
      var request = http.Request('PUT', Uri.parse(url));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final resStr = await response.stream.bytesToString();
        print('结束对话成功: $resStr');
      } else {
        print('结束对话失败: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('结束对话异常: $e');
    }
  }

  Future<void> setConversationPublic(int conversationId, bool isPublic) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final username = prefs.getString('username') ?? '';

      var headers = {
        'token': token,
        'username': username,
      };

      var url =
          'http://43.143.231.162:8000/api/hangzd/conversation/$conversationId/public';
      var request = http.MultipartRequest('PUT', Uri.parse(url));

      request.fields.addAll({
        'isPublic': isPublic ? 'true' : 'false',
      });

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final resStr = await response.stream.bytesToString();
        print('设置公开状态成功: $resStr');
      } else {
        print('设置公开状态失败: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('设置公开状态异常: $e');
    }
  }

  Future<Map<String, dynamic>> getPublicConversations(
      int page, int size) async {
    print('开始获取公开对话');
    var response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.public}')
          .replace(queryParameters: {'current': '$page', 'size': '$size'}),
      headers: await RequestModel.getHeaders(),
    );
    if (jsonDecode(response.body)['success'] == true) {
      print('公开对话结果：${jsonDecode(response.body)}');
      return jsonDecode(response.body)['data'];
    } else {
      print('公开对话error: ${jsonDecode(response.body)}');
      return jsonDecode(response.body)['data'];
    }
  }

  Future<bool> getConversationStatus(int conversationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final username = prefs.getString('username') ?? '';

      final headers = {
        'token': token,
        'username': username,
      };

      final request = http.Request(
        'GET',
        Uri.parse(
            'http://43.143.231.162:8000/api/hangzd/conversation/$conversationId/status'),
      );
      request.headers.addAll(headers);

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        return json.decode(responseBody)['data'] != 0;
      } else {
        print('获取状态失败: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('请求 conversation status 失败: $e');
    }

    // 添加这一行确保总是返回一个 bool 值
    return false;
  }

  Future<List<dynamic>> getConversationById(int id) async{
    print('开始获取id为$id 的对话内容');
    var response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getConversation}/$id'),
      headers: await RequestModel.getHeaders(),
    );
    if (jsonDecode(response.body)['success'] == true) {
      print('对话内容结果：${jsonDecode(response.body)}');
      // return jsonDecode(response.body)['data'];
    } else {
      print('对话内容error: ${jsonDecode(response.body)}');
      // return jsonDecode(response.body)['data'];
    }
    return [];
  }
}
