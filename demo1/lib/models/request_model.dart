class Request {
  final String? token;
  final String? username;

  Request({this.token, this.username});

  Map<String, String> toHeaders() {
    return {
      if (token != null) 'token': token!,
      if (username != null) 'username': username!,
    };
  }
}
