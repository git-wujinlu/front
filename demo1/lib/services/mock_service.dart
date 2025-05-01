import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../models/request_model.dart';

class MockService {
  static final Map<String, dynamic> _mockUserInfo = {
    'code': '0',
    'message': null,
    'data': {
      'id': 1,
      'studentId': null,
      'username': 'wjy',
      'introduction': '哎一股',
      'likeCount': 0,
      'collectCount': 0,
      'usefulCount': 0,
      'phone': '123',
      'tags': '算法,机器学习,Python,Web 开发',
    },
    'success': true,
  };

  static final Map<String, dynamic> _mockTags = {
    'code': '0',
    'message': null,
    'data': ['算法', '机器学习', 'Python', 'Web 开发'],
    'success': true,
  };

  static final Map<String, dynamic> _mockStats = {
    'code': '0',
    'message': null,
    'data': {'questions': 2, 'answers': 38, 'helpfulAnswers': 28},
    'success': true,
  };

  static final Map<String, dynamic> _mockUserAnswers = {
    'code': '0',
    'message': null,
    'data': [
      {
        'answered': 1,
        'content': '这是一个示例回答，包含了详细的解释和说明。',
        'createTime': '2024-03-15 10:30:00',
        'delFlag': 0,
        'id': 1,
        'images': null,
        'likeCount': 5,
        'questionId': 1,
        'updateTime': '2024-03-15 10:30:00',
        'useful': 1,
        'userId': 1,
        'username': 'wjy'
      },
      {
        'answered': 1,
        'content': '这是另一个示例回答，提供了不同的解决方案。',
        'createTime': '2024-03-14 15:20:00',
        'delFlag': 0,
        'id': 2,
        'images': null,
        'likeCount': 3,
        'questionId': 2,
        'updateTime': '2024-03-14 15:20:00',
        'useful': 0,
        'userId': 1,
        'username': 'wjy'
      }
    ],
    'success': true
  };

  static final Map<String, dynamic> _mockUserQuestions = {
    'code': '0',
    'message': null,
    'data': [
      {
        'categoryId': 1,
        'content': '这是一个示例问题，我想知道如何解决这个问题。',
        'createTime': '2024-03-15 09:00:00',
        'id': 1,
        'images': null,
        'title': '如何优化Flutter应用的性能？',
        'userId': 1,
        'username': 'wjy',
        'viewCount': 100
      },
      {
        'categoryId': 2,
        'content': '这是另一个示例问题，关于Dart语言的使用。',
        'createTime': '2024-03-14 14:00:00',
        'id': 2,
        'images': null,
        'title': 'Dart中的异步编程最佳实践是什么？',
        'userId': 1,
        'username': 'wjy',
        'viewCount': 80
      }
    ],
    'success': true
  };

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: Duration(milliseconds: ApiConstants.connectTimeout),
      receiveTimeout: Duration(milliseconds: ApiConstants.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  static void setupMockInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            print('Mock拦截器收到请求: ${options.path}'); // 添加请求日志
            print('请求方法: ${options.method}'); // 添加方法日志
            print('请求数据: ${options.data}'); // 添加数据日志

            // 模拟网络延迟
            await Future.delayed(const Duration(milliseconds: 500));

            // 根据请求路径返回不同的模拟数据
            if (options.path.contains('/api/hangzd/user/')) {
              if (options.method == 'GET') {
                if (options.path.contains('/active_answers')) {
                  return handler.resolve(
                    Response(
                      requestOptions: options,
                      data: _mockUserAnswers,
                      statusCode: 200,
                    ),
                  );
                } else if (options.path.contains('/active_questions')) {
                  return handler.resolve(
                    Response(
                      requestOptions: options,
                      data: _mockUserQuestions,
                      statusCode: 200,
                    ),
                  );
                }
                return handler.resolve(
                  Response(
                    requestOptions: options,
                    data: _mockUserInfo,
                    statusCode: 200,
                  ),
                );
              } else if (options.method == 'PUT') {
                // 处理更新用户信息的请求
                if (options.path.contains('/profile')) {
                  try {
                    print('处理用户资料更新请求'); // 添加日志
                    print('请求数据类型: ${options.data.runtimeType}'); // 添加数据类型日志

                    // 处理不同类型的请求数据
                    if (options.data is FormData) {
                      // 处理FormData
                      final formData = options.data as FormData;
                      print('FormData字段: ${formData.fields}'); // 添加FormData字段日志
                      print('FormData文件: ${formData.files}'); // 添加FormData文件日志

                      // 更新用户信息
                      for (var field in formData.fields) {
                        print(
                            '处理字段: ${field.key} = ${field.value}'); // 添加字段处理日志
                        if (field.key == 'oldUsername') {
                          _mockUserInfo['data']['username'] = field.value;
                        } else if (field.key == 'newUsername') {
                          _mockUserInfo['data']['username'] = field.value;
                        } else if (field.key == 'phone') {
                          _mockUserInfo['data']['phone'] = field.value;
                        } else if (field.key == 'introduction') {
                          _mockUserInfo['data']['introduction'] = field.value;
                        } else if (field.key == 'avatar') {
                          _mockUserInfo['data']['avatar'] = field.value;
                        }
                      }

                      // 处理文件上传
                      if (formData.files.isNotEmpty) {
                        for (var file in formData.files) {
                          print('处理文件: ${file.key}'); // 添加文件处理日志
                          if (file.key == 'avatar') {
                            _mockUserInfo['data']['avatar'] =
                                'https://via.placeholder.com/150';
                          }
                        }
                      }
                    } else if (options.data is Map<String, dynamic>) {
                      // 处理普通Map数据
                      final data = options.data as Map<String, dynamic>;
                      print('处理Map数据: $data'); // 添加Map数据日志

                      if (data['oldUsername'] != null) {
                        _mockUserInfo['data']['username'] = data['oldUsername'];
                      } else if (data['newUsername'] != null) {
                        _mockUserInfo['data']['username'] = data['newUsername'];
                      }
                      if (data['phone'] != null) {
                        _mockUserInfo['data']['phone'] = data['phone'];
                      }
                      if (data['introduction'] != null) {
                        _mockUserInfo['data']['introduction'] =
                            data['introduction'];
                      }
                      if (data['avatar'] != null) {
                        _mockUserInfo['data']['avatar'] = data['avatar'];
                      }
                    }

                    print('更新后的用户信息: $_mockUserInfo'); // 添加更新后数据日志

                    return handler.resolve(
                      Response(
                        requestOptions: options,
                        data: _mockUserInfo,
                        statusCode: 200,
                      ),
                    );
                  } catch (e) {
                    print('处理用户资料更新时出错: $e'); // 添加错误日志
                    return handler.reject(
                      DioException(
                        requestOptions: options,
                        error: '处理请求数据失败: $e',
                        type: DioExceptionType.unknown,
                        response: Response(
                          requestOptions: options,
                          statusCode: 400,
                          data: {'message': '处理请求数据失败: $e'},
                        ),
                      ),
                    );
                  }
                } else if (options.path.contains('/tags')) {
                  // 处理标签更新
                  try {
                    print('处理标签更新请求'); // 添加日志
                    final data = options.data as Map<String, dynamic>;
                    print('标签数据: $data'); // 添加标签数据日志

                    if (data['tags'] != null) {
                      _mockUserInfo['data']['tags'] = data['tags'];
                      print('更新后的用户信息: $_mockUserInfo'); // 添加更新后数据日志
                    }

                    return handler.resolve(
                      Response(
                        requestOptions: options,
                        data: {
                          'code': '0',
                          'message': null,
                          'data': _mockUserInfo['data'],
                          'success': true,
                        },
                        statusCode: 200,
                      ),
                    );
                  } catch (e) {
                    print('处理标签更新时出错: $e'); // 添加错误日志
                    return handler.reject(
                      DioException(
                        requestOptions: options,
                        error: '处理标签更新失败: $e',
                        type: DioExceptionType.unknown,
                        response: Response(
                          requestOptions: options,
                          statusCode: 400,
                          data: {'message': '处理标签更新失败: $e'},
                        ),
                      ),
                    );
                  }
                }
              }
            } else if (options.path.contains('/api/hangzd/user/stats')) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  data: _mockStats,
                  statusCode: 200,
                ),
              );
            }

            // 如果没有匹配的模拟数据，继续发送真实请求
            return handler.next(options);
          } catch (e) {
            print('Mock拦截器出错: $e'); // 添加错误日志
            return handler.reject(
              DioException(
                requestOptions: options,
                error: '处理请求失败: $e',
                type: DioExceptionType.unknown,
                response: Response(
                  requestOptions: options,
                  statusCode: 500,
                  data: {'message': '处理请求失败: $e'},
                ),
              ),
            );
          }
        },
      ),
    );
  }

  static Dio get dio => _dio;
}
