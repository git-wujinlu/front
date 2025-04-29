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
          // 在请求发送前处理，比如添加token
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // 在响应返回时处理
          if (response.statusCode == 200) {
            return handler.next(response);
          } else {
            return handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                response: response,
                type: DioExceptionType.badResponse,
              ),
            );
          }
        },
        onError: (DioException e, handler) {
          // 处理错误
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
