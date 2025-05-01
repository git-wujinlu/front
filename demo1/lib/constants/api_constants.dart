class ApiConstants {
  // API基础路径
  static const String baseUrl =
      'http://43.143.231.162:8000';

  // 用户相关接口
  static const String user = '/api/hangzd/user';
  static const String userInfo = '$user/{username}';
  static const String userProfile = '$user';
  static const String userTags = '$user/tags';
  static const String userPassword = '$user/password';
  static const String userActiveAnswers = '$user/active_answers';
  static const String userActiveQuestions = '$user/active_questions';
  static const String login = '$user/login';
  static const String logout = '$user/logout';
  static const String sendCode = '$user/send-code';
  static const String captcha = '$user/captcha';

  // 问答相关接口
  static const String questions = '/api/hangzd/questions';
  static const String answers = '/api/hangzd/answers';
  static const String myQuestions = '$questions/my';
  static const String myAnswers = '$answers/my';

  // 设置相关接口
  static const String settings = '/api/hangzd/settings';
  static const String notification = '$settings/notification';
  static const String security = '$settings/security';
  static const String email = '$settings/email';

  // 认证相关
  static const String auth = '/api/hangzd/auth';
  static const String refreshToken = '$auth/refresh';

  // 请求配置
  static const int connectTimeout = 5000; // 5秒
  static const int receiveTimeout = 3000; // 3秒
  static const int maxRetries = 3; // 最大重试次数
}
