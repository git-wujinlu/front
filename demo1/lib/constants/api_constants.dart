class ApiConstants {
  // API基础路径
  static const String baseUrl = 'YOUR_API_BASE_URL';

  // 用户相关接口
  static const String user = '/api/user';
  static const String userProfile = '$user/profile';
  static const String userTags = '$user/tags';
  static const String userPoints = '$user/points';

  // 问答相关接口
  static const String questions = '/api/questions';
  static const String answers = '/api/answers';
  static const String myQuestions = '$questions/my';
  static const String myAnswers = '$answers/my';

  // 设置相关接口
  static const String settings = '/api/settings';
  static const String notification = '$settings/notification';
  static const String security = '$settings/security';
  static const String email = '$settings/email';

  // 认证相关
  static const String auth = '/api/auth';
  static const String login = '$auth/login';
  static const String logout = '$auth/logout';
  static const String refreshToken = '$auth/refresh';
}
