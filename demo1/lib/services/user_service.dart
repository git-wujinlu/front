import 'package:dio/dio.dart';
import 'api_config.dart';

class UserService {
  final Dio _dio = ApiConfig.createDio();

  // 获取用户信息
  Future<Map<String, dynamic>> getUserInfo(String userId) async {
    try {
      final response = await _dio.get('/api/users/$userId');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 更新用户信息
  Future<Map<String, dynamic>> updateUserInfo(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put('/api/users/$userId', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 统一处理错误
  Exception _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('网络连接超时');
      case DioExceptionType.badResponse:
        return Exception('服务器响应错误: ${e.response?.statusCode}');
      case DioExceptionType.cancel:
        return Exception('请求被取消');
      default:
        return Exception('网络请求错误: ${e.message}');
    }
  }
}
