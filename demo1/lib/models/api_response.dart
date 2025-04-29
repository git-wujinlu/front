class ApiResponse<T> {
  final T? data;
  final String? message;

  ApiResponse({this.data, this.message});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return ApiResponse(
      data:
          json['data'] != null
              ? fromJson(json['data'] as Map<String, dynamic>)
              : null,
      message: json['message'] as String?,
    );
  }

  bool get isSuccess => message == null;
}
