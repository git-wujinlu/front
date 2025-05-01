import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../utils/api_error_handler.dart';

class ApiConfig {
  static Dio createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) {
          return status != null && status < 500; // 只处理500以下的错误
        },
      ),
    );

    // 添加拦截器
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('发送请求: ${options.uri}'); // 添加请求日志
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('收到响应: ${response.data}'); // 添加响应日志
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print('请求错误: ${e.message}'); // 添加错误日志
          final errorMessage = ApiErrorHandler.handleError(e);
          return handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              error: errorMessage,
              type: e.type,
            ),
          );
        },
      ),
    );

    return dio;
  }
}
