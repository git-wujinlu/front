import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../models/request_model.dart';
import '../utils/api_error_handler.dart';
import 'mock_service.dart';
import 'dart:io';

class UserService {
  final Dio _dio;
  String? CaptchaOwner;

  // 添加静态变量用于存储最新的用户信息
  static Map<String, dynamic>? _latestUserInfo;

  UserService() : _dio = MockService.dio {
    // 移除 _clearOldData 调用
  }

  Future<void> _clearOldData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('username');
    CaptchaOwner = null; // 清除验证码 cookie
  }

  // 获取登录验证码
  Future<Uint8List> captcha() async {
    final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.captcha}'),
        headers: await RequestModel.getHeaders());

    // 添加响应内容打印
    print('验证码响应状态码: ${response.statusCode}');
    print('验证码响应头: ${response.headers}');
    print('验证码响应体: ${response.body}');

    // 添加空值检查
    final setCookie = response.headers['set-cookie'];
    if (setCookie != null) {
      CaptchaOwner = setCookie.substring(0, setCookie.indexOf(';'));
    }
    return response.bodyBytes;
  }

  // 登录
  Future<bool> login(String username, String password, String code) async {
    Map<String, String> headers = await RequestModel.getHeaders();
    headers['cookie'] = CaptchaOwner!;
    print('登录请求头: $headers');

    final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}'),
        body: json.encode({
          "username": username,
          "password": password,
          "code": code,
        }),
        headers: headers);

    print('登录响应状态码: ${response.statusCode}');
    print('登录响应体: ${response.body}');
    print('解析后的响应数据: ${jsonDecode(response.body)}');

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('token', jsonDecode(response.body)['data']['token']);
      prefs.setString('username', username);
      return (true);
    } else {
      return (false);
    }
  }

  // 验证码
  void sendCode(String mail) async {
    final response = await http.get(Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.sendCode}?mail=$mail'));
    print(jsonDecode(response.body)['success']);
  }

  // 注册
  Future<bool> signUp(
      String username, String password, String mail, String code) async {
    final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.user}'),
        body: json.encode({
          "username": username,
          "password": password,
          "mail": mail,
          "code": code,
        }),
        headers: await RequestModel.getHeaders());
    print(response.body);
    if (jsonDecode(response.body)['success'] == true) {
      return (true);
    } else {
      return (false);
    }
  }

  // 获取用户信息（通过用户名）
  Future<Map<String, dynamic>> getUserByUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username');
      final headers = await RequestModel.getHeaders();
      final url =
          ApiConstants.userInfo.replaceAll('{username}', username ?? '');
      print('调用用户信息接口: ${ApiConstants.baseUrl}$url');
      print('请求 headers: $headers');

      if (username == null) {
        throw Exception('未找到用户信息，请重新登录');
      }

      final response = await _dio.get(
        url,
        options: Options(
          headers: headers,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      print('服务器返回: ${response.data}');

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? '获取用户信息失败');
      }

      if (response.data['data'] == null) {
        throw Exception('获取用户信息失败');
      }

      return response.data;
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.handleError(e));
    } catch (e) {
      throw Exception('获取用户信息失败：$e');
    }
  }

  // 获取用户标签
  Future<Map<String, dynamic>> getUserTags(
    String username, {
    RequestModel? request,
  }) async {
    try {
      // 使用getUserByUsername获取用户信息，然后从用户信息中提取标签
      final userInfo = await getUserByUsername();
      final tagsString = userInfo['data']['tags'] as String? ?? '';
      final tagsList = tagsString.isNotEmpty
          ? tagsString.split(',').map((e) => e.trim()).toList()
          : <String>[];

      return {'code': '0', 'message': null, 'data': tagsList, 'success': true};
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.handleError(e));
    }
  }

  // 获取用户统计信息
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final response = await _dio.get(
        '${ApiConstants.userInfo}/${prefs.getString('username')}/stats',
        options: Options(headers: await RequestModel.getHeaders()),
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.handleError(e));
    }
  }

  // 更新用户资料
  Future<Map<String, dynamic>> updateUserProfile({
    required String oldUsername,
    required String newUsername,
    required String phone,
    required String introduction,
    String? avatar,
  }) async {
    try {
      print('开始更新用户资料'); // 添加调试日志
      print(
          '参数: oldUsername=$oldUsername, newUsername=$newUsername, phone=$phone, introduction=$introduction, avatar=$avatar'); // 添加参数日志

      // 创建请求体
      final requestBody = {
        'oldUsername': oldUsername,
        'newUsername': newUsername,
        'phone': phone,
        'introduction': introduction,
      };

      // 如果有头像，添加到请求体中
      if (avatar != null) {
        requestBody['avatar'] = avatar;
      }

      print('发送请求数据: $requestBody'); // 添加请求数据日志

      final response = await _dio.put(
        ApiConstants.userProfile,
        data: requestBody,
        options: Options(
          headers: await RequestModel.getHeaders(),
          contentType: 'application/json',
        ),
      );

      print('更新用户资料响应: ${response.data}'); // 添加响应日志

      if (response.statusCode == 200 && response.data['success'] == true) {
        // 更新本地缓存
        if (_latestUserInfo != null) {
          _latestUserInfo!['username'] = newUsername;
          _latestUserInfo!['phone'] = phone;
          _latestUserInfo!['introduction'] = introduction;
          if (avatar != null) {
            _latestUserInfo!['avatar'] = avatar;
          }
        }
        return response.data;
      } else {
        throw Exception(response.data['message'] ?? '更新失败');
      }
    } on DioException catch (e) {
      print('更新用户资料失败: ${e.message}'); // 添加错误日志
      print('错误类型: ${e.type}'); // 添加错误类型日志
      if (e.response != null) {
        print('错误响应: ${e.response?.data}'); // 添加错误响应日志
      }
      throw Exception(ApiErrorHandler.handleError(e));
    } catch (e) {
      print('未知错误: $e'); // 添加未知错误日志
      throw Exception('更新用户资料失败：$e');
    }
  }

  // 更新用户标签
  Future<Map<String, dynamic>> updateUserTags({
    required String username,
    required List<String> tags,
  }) async {
    try {
      print('开始更新用户标签'); // 添加调试日志
      // 将标签列表转换为逗号分隔的字符串，确保没有多余的空格
      final tagsString = tags
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .join(',');
      final data = tagsString.isEmpty ? {'tags': null} : {'tags': tagsString};
      final headers = await RequestModel.getHeaders();
      print('调用标签更新接口: ${ApiConstants.baseUrl}${ApiConstants.userTags}');
      print('请求 headers: $headers');
      print('请求数据: $data');

      final response = await _dio.put(
        ApiConstants.userTags, // 使用正确的 API 路径
        data: data,
        options: Options(headers: headers),
      );
      print('标签更新响应: ${response.data}'); // 添加调试日志

      // 更新最新数据中的标签
      if (_latestUserInfo != null) {
        _latestUserInfo!['tags'] = tagsString;
        print('更新后的 _latestUserInfo: $_latestUserInfo'); // 添加调试日志
      } else {
        _latestUserInfo = {
          'username': username,
          'tags': tagsString,
        };
        print('创建新的 _latestUserInfo: $_latestUserInfo'); // 添加调试日志
      }

      return response.data;
    } on DioException catch (e) {
      print('标签更新失败: ${e.message}'); // 添加调试日志
      throw Exception(ApiErrorHandler.handleError(e));
    }
  }

  // 修改密码
  Future<Map<String, dynamic>> updatePassword({
    required String oldPassword,
    required String newPassword,
    RequestModel? request,
  }) async {
    try {
      print('开始修改密码'); // 添加调试日志
      print(
        '请求参数: oldPassword=$oldPassword, newPassword=$newPassword',
      ); // 添加参数日志

      final response = await _dio.put(
        ApiConstants.userPassword,
        data: {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        },
        options: Options(
          headers: request?.toHeaders(),
          contentType: 'application/json',
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      print('密码修改响应状态码: ${response.statusCode}'); // 添加状态码日志
      print('密码修改响应数据: ${response.data}'); // 添加响应数据日志

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(response.data['message'] ?? '密码修改失败');
      }
    } on DioException catch (e) {
      print('密码修改失败: ${e.message}'); // 添加错误日志
      print('错误类型: ${e.type}'); // 添加错误类型日志
      throw Exception(ApiErrorHandler.handleError(e));
    } catch (e) {
      print('未知错误: $e'); // 添加未知错误日志
      throw Exception('密码修改失败：$e');
    }
  }

  // 获取用户的回答列表
  Future<Map<String, dynamic>> getUserAnswers(
    String username, {
    RequestModel? request,
  }) async {
    try {
      print('开始获取用户回答列表'); // 添加调试日志
      final response = await _dio.get(
        '${ApiConstants.userActiveAnswers}?username=$username',
        options: Options(headers: request?.toHeaders()),
      );
      print('获取用户回答列表成功: ${response.data}'); // 添加调试日志
      return response.data;
    } on DioException catch (e) {
      print('获取用户回答列表失败: ${e.message}'); // 添加错误日志
      throw Exception(ApiErrorHandler.handleError(e));
    }
  }

  // 获取用户的问题列表
  Future<Map<String, dynamic>> getUserQuestions(
    String username, {
    RequestModel? request,
  }) async {
    try {
      print('开始获取用户问题列表'); // 添加调试日志
      final response = await _dio.get(
        '${ApiConstants.userActiveQuestions}?username=$username',
        options: Options(headers: request?.toHeaders()),
      );
      print('获取用户问题列表成功: ${response.data}'); // 添加调试日志
      return response.data;
    } on DioException catch (e) {
      print('获取用户问题列表失败: ${e.message}'); // 添加错误日志
      throw Exception(ApiErrorHandler.handleError(e));
    }
  }

  // 清除缓存数据（用于测试）
  static void clearCache() {
    _latestUserInfo = null;
  }

  // 登出
  Future<void> logout() async {
    await _clearOldData();
    _latestUserInfo = null;
  }
}
