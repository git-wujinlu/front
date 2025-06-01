import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../models/request_model.dart';
import '../utils/api_error_handler.dart';

class UserService {
  final Dio _dio;
  String? CaptchaOwner;

  // 添加静态变量用于存储最新的用户信息
  static Map<String, dynamic>? _latestUserInfo;

  // 添加静态方法用于获取完整的图片URL
  static String getFullAvatarUrl(String? path, {bool optimize = true}) {
    if (path == null || path.isEmpty) return '';

    // 如果已经是完整URL，则直接返回
    if (path.startsWith('http')) {
      // 如果需要优化且URL不包含参数，则添加优化参数
      if (optimize && !path.contains('?')) {
        return '$path?x-oss-process=image/resize,m_lfit,w_800,h_800';
      }
      return path;
    }

    // 否则添加OSS前缀
    final fullUrl = '${ApiConstants.ossBaseUrl}$path';
    // 如果需要优化显示效果，添加参数
    if (optimize) {
      return '$fullUrl?x-oss-process=image/resize,m_lfit,w_800,h_800';
    }
    return fullUrl;
  }

  // 使用真实后端而不是Mock服务
  UserService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: Duration(milliseconds: ApiConstants.connectTimeout),
            receiveTimeout: Duration(milliseconds: ApiConstants.receiveTimeout),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    print('初始化UserService，使用真实后端: ${ApiConstants.baseUrl}');
  }

  Future<void> _clearOldData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('username');
    CaptchaOwner = null; // 清除验证码 cookie
  }

  // 获取登录验证码
  Future<Uint8List> captcha() async {
    try {
      print('开始请求验证码 (真实后端)');
      final headers = await RequestModel.getHeaders();
      print('验证码请求头: ${headers.keys}'); // 只打印键名，不打印敏感信息

      final url = '${ApiConstants.baseUrl}${ApiConstants.captcha}';
      print('请求验证码URL: $url');

      final response = await http.get(Uri.parse(url), headers: headers);

      // 添加响应内容打印
      print('验证码响应状态码: ${response.statusCode}');
      print('验证码响应头键: ${response.headers.keys.toList()}');

      // 检查响应状态
      if (response.statusCode != 200) {
        print('验证码请求失败，状态码: ${response.statusCode}');
        throw Exception('获取验证码失败，请重试 (状态码: ${response.statusCode})');
      }

      // 处理Cookie
      final setCookie = response.headers['set-cookie'];
      if (setCookie != null && setCookie.contains(';')) {
        CaptchaOwner = setCookie.substring(0, setCookie.indexOf(';'));
        print(
            '已设置验证码Cookie: ${CaptchaOwner?.substring(0, min(10, CaptchaOwner?.length ?? 0))}...');
      } else {
        print('未找到验证码Cookie，响应头: ${response.headers}');
        // 如果没有cookie，尝试从响应体中获取内容
        if (response.bodyBytes.isNotEmpty) {
          print('无Cookie但有响应数据，尝试使用图片数据');
          return response.bodyBytes; // 仍然返回图片数据
        }
        throw Exception('验证码请求失败，未获取到必要信息');
      }

      print('验证码获取成功，返回图片数据 (${response.bodyBytes.length} 字节)');
      return response.bodyBytes;
    } catch (e) {
      print('获取验证码出错: $e');
      // 重新抛出异常，让上层处理
      throw Exception('获取验证码失败: $e');
    }
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
      print(jsonDecode(response.body));
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

      // 处理返回的头像URL，添加用于前端显示的完整URL
      final userData = response.data['data'];
      if (userData['avatar'] != null &&
          userData['avatar'].toString().isNotEmpty) {
        // 保存原始avatar值，同时添加用于显示的fullAvatarUrl
        print('原始头像路径: ${userData['avatar']}');
        userData['fullAvatarUrl'] = getFullAvatarUrl(userData['avatar']);
        print('完整显示头像URL: ${userData['fullAvatarUrl']}');
      }

      return response.data;
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.handleError(e));
    } catch (e) {
      throw Exception('获取用户信息失败：$e');
    }
  }

  Future<Map<String, dynamic>> getOtherUserByUsername(String username) async {
    try {
      final headers = await RequestModel.getHeaders();
      final url = ApiConstants.userInfo.replaceAll('{username}', username);
      print('调用用户信息接口: ${ApiConstants.baseUrl}$url');
      print('请求 headers: $headers');

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

      // 处理返回的头像URL，添加用于前端显示的完整URL
      final userData = response.data['data'];
      if (userData['avatar'] != null &&
          userData['avatar'].toString().isNotEmpty) {
        userData['fullAvatarUrl'] = getFullAvatarUrl(userData['avatar']);
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

  // 上传文件到OSS并返回URL
  Future<String> uploadFile(File file) async {
    try {
      print('开始上传文件: ${file.path}');
      print('文件大小: ${await file.length()} 字节');
      print('文件类型: ${file.path.split('.').last}');

      // 获取请求头
      final headers = await RequestModel.getHeaders();
      print('上传请求头: $headers');

      // 修改文件名以防冲突
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'avatar_${timestamp}_${file.path.split('/').last}';
      print('使用文件名: $filename');

      // 创建FormData
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: filename,
        ),
      });

      print('FormData字段: ${formData.fields}');
      print(
          'FormData文件: ${formData.files.map((e) => e.key + ': ' + e.value.filename!).join(', ')}');

      print('调用文件上传接口: ${ApiConstants.baseUrl}${ApiConstants.fileUpload}');

      // 使用不同的超时设置
      final response = await _dio.post(
        ApiConstants.fileUpload,
        data: formData,
        options: Options(
          headers: headers,
          contentType: 'multipart/form-data',
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      print('文件上传响应状态码: ${response.statusCode}');
      print('文件上传响应数据类型: ${response.data.runtimeType}');
      print('文件上传响应: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        // 获取文件路径并添加OSS前缀
        final filePath = response.data['data'];
        if (filePath == null) {
          throw Exception('上传成功但未返回文件路径');
        }

        final fullUrl = '${ApiConstants.ossBaseUrl}$filePath';
        print('文件上传成功，完整URL: $fullUrl');
        return fullUrl;
      } else {
        // 尝试获取详细错误信息
        final errorMessage = response.data['message'] ?? '文件上传失败';
        final errorCode = response.data['code'] ?? '未知错误码';
        throw Exception('上传失败 [错误码: $errorCode]: $errorMessage');
      }
    } on DioException catch (e) {
      print('文件上传DIO异常: ${e.message}');
      print('错误类型: ${e.type}');
      if (e.response != null) {
        print('错误响应状态码: ${e.response?.statusCode}');
        print('错误响应数据: ${e.response?.data}');
      }
      throw Exception('文件上传网络错误: ${ApiErrorHandler.handleError(e)}');
    } catch (e) {
      print('文件上传过程中发生未知错误: $e');

      // 如果是文件不存在或无法访问的问题
      if (e.toString().contains('FileSystemException')) {
        throw Exception('无法访问选择的图片文件，请重新选择');
      }

      throw Exception('文件上传失败：$e');
    }
  }

  // 备用方法：使用http包上传文件
  Future<String> uploadFileWithHttp(File file) async {
    try {
      print('使用HTTP方式上传文件: ${file.path}');

      // 获取请求头
      final headers = await RequestModel.getHeaders();
      // 移除Content-Type，让multipart自动设置
      headers.remove('Content-Type');

      // 创建multipart请求
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.fileUpload}'),
      );

      // 添加头信息
      request.headers.addAll(headers);

      // 添加文件
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
      ));

      print('发送HTTP上传请求...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('HTTP上传响应状态码: ${response.statusCode}');
      print('HTTP上传响应: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        final filePath = responseData['data'];
        final fullUrl = '${ApiConstants.ossBaseUrl}$filePath';
        print('HTTP上传成功，完整URL: $fullUrl');
        return fullUrl;
      } else {
        throw Exception(responseData['message'] ?? '文件上传失败');
      }
    } catch (e) {
      print('HTTP上传过程中发生错误: $e');
      throw Exception('HTTP上传失败：$e');
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
        // 如果avatar是带有OSS前缀的完整URL，提取出路径部分
        if (avatar.startsWith(ApiConstants.ossBaseUrl)) {
          // 移除OSS前缀
          String path = avatar.substring(ApiConstants.ossBaseUrl.length);

          // 如果路径中包含参数（如?x-oss-process=），则只保留参数前的部分
          if (path.contains('?')) {
            path = path.substring(0, path.indexOf('?'));
          }

          print('从完整URL中提取的路径: $path');
          requestBody['avatar'] = path;
        } else {
          // 检查avatar中是否直接包含参数
          if (avatar.contains('?')) {
            avatar = avatar.substring(0, avatar.indexOf('?'));
          }
          requestBody['avatar'] = avatar;
        }
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

        // 更新SharedPreferences中的用户名
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('username', newUsername);
        print('更新本地存储的用户名: $oldUsername -> $newUsername');

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
      print('==== 开始修改密码流程 ====');
      print('密码长度 - 旧密码: ${oldPassword.length}, 新密码: ${newPassword.length}');

      // 在修改密码前，先获取当前用户信息，用于日志记录
      final prefs = await SharedPreferences.getInstance();
      final currentUsername = prefs.getString('username');
      print('当前登录用户: $currentUsername');

      // 获取请求头，优先使用传入的request
      Map<String, dynamic> headers;
      if (request != null) {
        headers = request.toHeaders();
        print('使用传入的请求头: ${headers.keys}'); // 只打印键名不打印值
      } else {
        headers = await RequestModel.getHeaders();
        print('使用默认的请求头: ${headers.keys}'); // 只打印键名不打印值
      }

      // 添加一个额外的标记，避免缓存问题
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      print(
          '发送密码修改请求到: ${ApiConstants.baseUrl}${ApiConstants.userPassword}?t=$timestamp');

      // 第一次尝试修改密码
      final response = await _dio.put(
        '${ApiConstants.userPassword}?t=$timestamp',
        data: {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        },
        options: Options(
          headers: headers,
          contentType: 'application/json',
          validateStatus: (status) => status != null && status < 500,
          receiveTimeout: Duration(seconds: 15),
          sendTimeout: Duration(seconds: 15),
        ),
      );

      print('密码修改响应状态码: ${response.statusCode}');

      // 详细打印响应信息
      if (response.data != null) {
        print('响应数据类型: ${response.data.runtimeType}');
        print('响应success字段: ${response.data['success']}');
        print('响应完整数据: ${response.data}');
      }

      if (response.statusCode == 200) {
        if (response.data['success'] == true) {
          print('密码修改成功，服务器已确认');

          // 立即发送第二次请求，确保服务器端处理完成
          try {
            print('尝试发送确认请求，确保密码已更新...');

            // 延迟一小段时间，确保服务器处理完第一个请求
            await Future.delayed(Duration(milliseconds: 500));

            // 再次发送相同的请求
            final confirmResponse = await _dio.put(
              '${ApiConstants.userPassword}?t=${DateTime.now().millisecondsSinceEpoch}',
              data: {
                'oldPassword': oldPassword,
                'newPassword': newPassword,
              },
              options: Options(
                headers: headers,
                contentType: 'application/json',
                validateStatus: (status) => status != null && status < 500,
              ),
            );

            print('确认请求响应: ${confirmResponse.statusCode}');
            if (confirmResponse.data != null) {
              print('确认请求响应数据: ${confirmResponse.data}');
            }
          } catch (confirmError) {
            print('确认请求失败，但不影响主流程: $confirmError');
          }

          print('==== 密码修改完成 ====');
          return response.data;
        } else {
          print('密码修改被服务器拒绝: ${response.data['message']}');
          throw Exception(response.data['message'] ?? '密码修改失败');
        }
      } else {
        print('服务器返回错误状态码: ${response.statusCode}');
        throw Exception(
            response.data['message'] ?? '密码修改失败 (状态码: ${response.statusCode})');
      }
    } on DioException catch (e) {
      print('密码修改请求异常: ${e.message}');
      print('错误类型: ${e.type}');
      if (e.response != null) {
        print('错误响应: ${e.response?.data}');
      }
      print('==== 密码修改失败 ====');
      throw Exception(ApiErrorHandler.handleError(e));
    } catch (e) {
      print('密码修改过程中发生未知错误: $e');
      print('==== 密码修改失败 ====');
      throw Exception('密码修改失败：$e');
    }
  }

  // 获取用户的回答列表
  Future<Map<String, dynamic>> getUserAnswers(String username) async {
    try {
      print('开始获取用户回答列表');

      // 获取当前用户ID
      final currentUserId = await getCurrentUserId();
      if (currentUserId == null) {
        throw Exception('无法获取当前用户ID');
      }

      // 获取所有会话
      final conversationsResponse = await getConversations();
      if (conversationsResponse['success'] != true ||
          conversationsResponse['data'] == null) {
        throw Exception('获取会话列表失败');
      }

      // 筛选出当前用户作为回答者的会话
      final allConversations = conversationsResponse['data'] as List;
      final myAnswers = allConversations
          .where((conv) => conv['user2'] == currentUserId)
          .toList();

      print('用户回答数量: ${myAnswers.length}');

      return {'code': '0', 'message': null, 'data': myAnswers, 'success': true};
    } catch (e) {
      print('获取用户回答列表失败: $e');
      throw Exception('获取用户回答列表失败：$e');
    }
  }

  // 获取用户的问题列表
  Future<Map<String, dynamic>> getUserQuestions(
    String username, {
    RequestModel? request,
  }) async {
    try {
      print('开始获取用户问题列表');

      // 获取当前用户ID
      final currentUserId = await getCurrentUserId();
      if (currentUserId == null) {
        throw Exception('无法获取当前用户ID');
      }

      // 获取所有会话
      final conversationsResponse = await getConversations();
      if (conversationsResponse['success'] != true ||
          conversationsResponse['data'] == null) {
        throw Exception('获取会话列表失败');
      }

      // 筛选出当前用户作为提问者的会话
      final allConversations = conversationsResponse['data'] as List;
      final myQuestions = allConversations
          .where((conv) => conv['user1'] == currentUserId)
          .toList();

      print('用户问题数量: ${myQuestions.length}');

      return {
        'code': '0',
        'message': null,
        'data': myQuestions,
        'success': true
      };
    } catch (e) {
      print('获取用户问题列表失败: $e');
      throw Exception('获取用户问题列表失败：$e');
    }
  }

  Future<bool> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    final token = prefs.getString('token');
    if (username == null || token == null) {
      return false;
    }
    final response = await http.get(
      Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.checkLogin}?username=$username&token=$token'),
      headers: await RequestModel.getHeaders(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    return false;
  }

  // 清除缓存数据（用于测试）
  static void clearCache() {
    _latestUserInfo = null;
  }

  // 登出
  Future<void> logout() async {
    try {
      print('==== 开始退出登录流程 ====');

      // 保存当前用户名用于日志记录
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username');
      final token = prefs.getString('token');
      print('当前登出用户: $username');

      // 显式地调用服务器端登出，尝试强制使服务器端会话失效
      if (username != null && token != null) {
        try {
          print('尝试调用服务器端登出接口...');
          // 先使用http直接调用，避免任何问题
          final httpResponse = await http.post(
            Uri.parse('${ApiConstants.baseUrl}${ApiConstants.logout}'),
            headers: {
              'username': username,
              'token': token,
              'Content-Type': 'application/json',
            },
          );
          print('HTTP服务器端登出响应: ${httpResponse.statusCode}');

          // 再使用dio调用一次，双重保险
          final dioResponse = await _dio.post(
            '${ApiConstants.baseUrl}/api/hangzd/user/logout',
            options: Options(
              headers: {
                'username': username,
                'token': token,
                'Content-Type': 'application/json',
              },
              validateStatus: (status) => true, // 接受任何状态码
            ),
          );
          print('DIO服务器端登出响应: ${dioResponse.statusCode}');

          // 最后尝试获取一个新的验证码，进一步刷新服务器状态
          try {
            print('尝试获取新验证码，进一步刷新服务器状态...');
            await captcha();
            print('验证码获取成功，有助于刷新会话状态');
          } catch (e) {
            print('获取验证码失败，但不影响主流程: $e');
          }
        } catch (e) {
          print('服务器端登出请求失败: $e');
          // 继续处理本地登出，即使服务器请求失败
        }
      }

      // 完全重置应用状态
      UserService.clearCache(); // 清除静态缓存
      _latestUserInfo = null; // 清除实例缓存
      CaptchaOwner = null; // 清除验证码 cookie

      // 列出所有可能与用户会话相关的键
      final keys = prefs.getKeys();
      print('SharedPreferences中的所有键: $keys');

      // 清除所有与用户相关的数据
      await prefs.remove('username');
      await prefs.remove('token');
      await prefs.remove('last_modified_username');
      await prefs.remove('last_modified_password');

      // 可选：清除其他可能的用户相关数据
      if (username != null) {
        // 清除可能以用户名为前缀的其他数据
        final userKeys =
            keys.where((key) => key.startsWith('${username}_')).toList();
        for (var key in userKeys) {
          print('清除用户相关数据: $key');
          await prefs.remove(key);
        }
      }

      // 打印清理后的状态
      final remainingKeys = prefs.getKeys();
      print('清理后剩余的SharedPreferences键: $remainingKeys');
      print('登出操作完成，所有本地凭证已移除');
      print('==== 退出登录完成 ====');
    } catch (e) {
      print('退出登录过程中出错: $e');
      // 再次尝试清除关键数据，确保不会有残留状态
      try {
        print('尝试应急清理...');
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('username');
        await prefs.remove('token');
        await prefs.remove('last_modified_username');
        await prefs.remove('last_modified_password');
        UserService.clearCache();
        _latestUserInfo = null;
        CaptchaOwner = null;
        print('应急清理完成');
      } catch (secondError) {
        print('应急清理失败: $secondError');
      }
    }
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    try {
      var response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getUserById}/$id'),
        headers: await RequestModel.getHeaders(),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['success'] == true) {
          // 处理返回的用户数据中的头像URL
          final userData = data['data'];
          if (userData != null &&
              userData['avatar'] != null &&
              userData['avatar'].toString().isNotEmpty) {
            userData['fullAvatarUrl'] = getFullAvatarUrl(userData['avatar']);
          }
          return userData; // 返回用户信息
        } else {
          print('获取用户信息失败：${data['message']}');
        }
      } else {
        print('请求失败：${response.statusCode}');
      }
    } catch (e) {
      print('获取用户信息异常: $e');
    }
    return null;
  }

  // 验证密码修改是否生效
  Future<bool> verifyPasswordChange({
    required String username,
    required String newPassword,
    required String code,
  }) async {
    try {
      print('==== 开始验证密码修改是否生效 ====');
      // 尝试使用新密码登录
      final loginResult = await login(username, newPassword, code);

      if (loginResult) {
        print('使用新密码登录成功，密码修改已生效');
        return true;
      } else {
        print('使用新密码登录失败，密码修改可能未生效');
        return false;
      }
    } catch (e) {
      print('验证密码修改时出错: $e');
      return false;
    }
  }

  // 获取用户ID
  Future<int?> getCurrentUserId() async {
    try {
      final userInfo = await getUserByUsername();
      if (userInfo['success'] == true && userInfo['data'] != null) {
        return userInfo['data']['id'] as int?;
      }
      return null;
    } catch (e) {
      print('获取用户ID失败: $e');
      return null;
    }
  }

  // 获取会话列表
  Future<Map<String, dynamic>> getConversations() async {
    try {
      final headers = await RequestModel.getHeaders();
      print('调用会话列表接口: ${ApiConstants.baseUrl}${ApiConstants.conversations}');
      print('请求 headers: $headers');

      final response = await _dio.get(
        ApiConstants.conversations,
        options: Options(
          headers: headers,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      print('获取会话列表响应: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      print('获取会话列表失败: ${e.message}');
      throw Exception(ApiErrorHandler.handleError(e));
    } catch (e) {
      print('获取会话列表异常: $e');
      throw Exception('获取会话列表失败：$e');
    }
  }

  // 获取问题详情
  Future<Map<String, dynamic>> getQuestionById(int questionId) async {
    try {
      print('开始获取问题详情，ID: $questionId');
      final headers = await RequestModel.getHeaders();

      final response = await _dio.get(
        '${ApiConstants.question}/$questionId',
        options: Options(
          headers: headers,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      print('获取问题详情响应: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      print('获取问题详情失败: ${e.message}');
      throw Exception(ApiErrorHandler.handleError(e));
    } catch (e) {
      print('获取问题详情异常: $e');
      throw Exception('获取问题详情失败：$e');
    }
  }
}
