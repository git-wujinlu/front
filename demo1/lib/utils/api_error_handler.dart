import 'package:dio/dio.dart';

class ApiErrorHandler {
  static String handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return '网络连接超时，请检查网络设置';
      case DioExceptionType.badResponse:
        return _handleResponseError(error.response);
      case DioExceptionType.cancel:
        return '请求被取消';
      case DioExceptionType.connectionError:
        return '网络连接错误，请检查网络设置';
      default:
        return '未知错误：${error.message}';
    }
  }

  static String _handleResponseError(Response? response) {
    if (response == null) return '服务器响应错误';

    // 处理HTTP状态码
    switch (response.statusCode) {
      case 200:
        return '请求成功';
      case 400:
        return '请求参数错误';
      case 401:
        return '未授权，请重新登录';
      case 403:
        return '拒绝访问';
      case 404:
        return '请求的资源不存在';
      case 500:
        return '服务器内部错误';
      default:
        return '服务器响应错误：${response.statusCode}';
    }
  }
}
