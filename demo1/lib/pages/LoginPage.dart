import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:demo1/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final UserService _userService = UserService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  final TextEditingController _passwordCheckController =
      TextEditingController();
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _captchaController = TextEditingController();
  bool _obscurePasswordCheck = true;
  bool passwordChecked = true;
  bool mailChecked = true;
  int nowPage = 0;
  bool codeCollDown = true;
  int codeTime = 0;
  String _errorMessage = '';

  Timer codeTimer = Timer(const Duration(seconds: 1), () => {});

  void codeTimerHandle() {}

  void sendCode() async {
    if (_mailController.text.isEmpty) {
      setState(() {
        mailChecked = false;
      });
    } else if (!mailChecked) {
    } else if (codeCollDown) {
      setState(() {
        codeCollDown = false;
      });
      codeTime = 60;
      codeTimer = Timer.periodic(const Duration(seconds: 1), (codeTimer) {
        if (codeTime != 0) {
          setState(() {
            --codeTime;
          });
        } else {
          setState(() {
            codeCollDown = true;
          });
          codeTimer.cancel();
        }
      });
      _userService.sendCode(_mailController.text);
    }
  }

  void showError(String message) {
    setState(() {
      _errorMessage = message;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _errorMessage = '';
        });
      }
    });
  }


  void login() async {
    if (nowPage == 1) {
      setState(() {
        nowPage = 0;
      });
    } else {
      if (_usernameController.text.isEmpty ) {
        showError('用户名为空');
      } else if (_passwordController.text.isEmpty) {
        showError('密码为空');
      } else {
        final loginResult = await _userService.login(_usernameController.text,
            _passwordController.text, _captchaController.text);
        final Map<String, dynamic> jsonMap = jsonDecode(loginResult);
        bool success = jsonMap['success'] == true;
        if (success) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/homepage',
            (route) => false,
          );
        } else {
          showError(jsonMap['message']);
        }
      }
    }
  }

  void signUp() async {
    if (nowPage == 0) {
      setState(() {
        nowPage = 1;
      });
    } else {
      if (_usernameController.text.isEmpty) {
        showError('用户名为空');
      } else if(RegExp(r'[\u4e00-\u9fa5]').hasMatch(_usernameController.text)) {
        showError('用户名暂时不能含有中文');
      } else if ( _passwordController.text.isEmpty) {
        showError('密码为空');
      } else if (!passwordChecked) {
        showError('两次输入密码不一致');
      } else if (_mailController.text.isEmpty ) {
        showError('邮箱为空');
      } else if (_codeController.text.isEmpty) {
        showError('验证码为空');
      } else {
        final signUpResult = await _userService.signUp(_usernameController.text, _passwordController.text, _mailController.text, _codeController.text);
        final Map<String, dynamic> jsonMap = jsonDecode(signUpResult);
        bool success = jsonMap['success'] == true;
        if (success) {
          setState(() {
            nowPage = 0;
          });
        } else {
          showError(jsonMap['message']);
        }
      }
    }
  }

  Future<Uint8List>? captcha;

  @override
  void initState() {
    Future<bool> flag = _userService.checkLogin();
    flag.then((data) {
      if (data) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/homepage',
          (route) => false,
        );
      }
    });
    captcha = _userService.captcha();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 0.8 * width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                textAlignVertical: TextAlignVertical.center,
                controller: _usernameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: themeProvider.isDarkMode
                          ? Colors.deepPurple.shade700
                          : Colors.deepPurple.shade300,
                    ),
                  ),
                  hintText: '用户名',
                  prefixIcon: Icon(
                    Icons.person,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    color: Theme.of(context).iconTheme.color,
                    onPressed: _usernameController.clear,
                  ),
                ),
              ),
              SizedBox(height: 0.03 * height),
              TextField(
                style: TextStyle(
                  color: passwordChecked || nowPage == 0
                      ? Colors.black
                      : Colors.red,
                ),
                onChanged: (String s) {
                  setState(() {
                    passwordChecked =
                        s.compareTo(_passwordCheckController.text) == 0;
                  });
                },
                onSubmitted: (String s) {
                  _passwordController.text = s;
                  if (nowPage == 0) login();
                },
                textAlignVertical: TextAlignVertical.center,
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: passwordChecked || nowPage == 0
                          ? Colors.black
                          : Colors.red,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: passwordChecked || nowPage == 0
                          ? Colors.black
                          : Colors.red,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: passwordChecked || nowPage == 0
                          ? themeProvider.isDarkMode
                              ? Colors.deepPurple.shade700
                              : Colors.deepPurple.shade300
                          : Colors.red,
                    ),
                  ),
                  hintText: '密码',
                  prefixIcon: Icon(
                    Icons.lock,
                    color: passwordChecked || nowPage == 0
                        ? Theme.of(context).iconTheme.color
                        : Colors.red,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: passwordChecked || nowPage == 0
                          ? Theme.of(context).iconTheme.color
                          : Colors.red,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              nowPage == 1
                  ? (Column(
                      children: [
                        SizedBox(height: 0.03 * height),
                        TextField(
                          style: TextStyle(
                            color: passwordChecked || nowPage == 0
                                ? Colors.black
                                : Colors.red,
                          ),
                          onChanged: (String s) {
                            setState(() {
                              passwordChecked =
                                  s.compareTo(_passwordController.text) == 0;
                            });
                          },
                          textAlignVertical: TextAlignVertical.center,
                          controller: _passwordCheckController,
                          obscureText: _obscurePasswordCheck,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: passwordChecked || nowPage == 0
                                    ? Colors.black
                                    : Colors.red,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: passwordChecked || nowPage == 0
                                    ? Colors.black
                                    : Colors.red,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: passwordChecked || nowPage == 0
                                    ? themeProvider.isDarkMode
                                        ? Colors.deepPurple.shade700
                                        : Colors.deepPurple.shade300
                                    : Colors.red,
                              ),
                            ),
                            hintText: '确认密码',
                            prefixIcon: Icon(
                              Icons.lock,
                              color: passwordChecked || nowPage == 0
                                  ? Theme.of(context).iconTheme.color
                                  : Colors.red,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePasswordCheck
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: passwordChecked || nowPage == 0
                                    ? Theme.of(context).iconTheme.color
                                    : Colors.red,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePasswordCheck =
                                      !_obscurePasswordCheck;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 0.03 * height),
                        TextField(
                          onChanged: (String s) {
                            setState(() {
                              if (s.isEmpty) {
                                mailChecked = true;
                              } else {
                                mailChecked = RegExp(
                                  "^([a-z0-9A-Z]+[-|\\.]?)+[a-z0-9A-Z]@([a-z0-9A-Z]+(-[a-z0-9A-Z]+)?\\.)+[a-zA-Z]{2,}\$",
                                ).hasMatch(s);
                              }
                            });
                          },
                          textAlignVertical: TextAlignVertical.center,
                          controller: _mailController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: mailChecked || nowPage == 0
                                    ? Colors.black
                                    : Colors.red,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: mailChecked || nowPage == 0
                                    ? Colors.black
                                    : Colors.red,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: mailChecked || nowPage == 0
                                    ? themeProvider.isDarkMode
                                        ? Colors.deepPurple.shade700
                                        : Colors.deepPurple.shade300
                                    : Colors.red,
                              ),
                            ),
                            hintText: '邮箱',
                            prefixIcon: Icon(
                              Icons.mail,
                              color: mailChecked || nowPage == 0
                                  ? Theme.of(context).iconTheme.color
                                  : Colors.red,
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear),
                              color: mailChecked || nowPage == 0
                                  ? Theme.of(context).iconTheme.color
                                  : Colors.red,
                              onPressed: _mailController.clear,
                            ),
                          ),
                        ),
                      ],
                    ))
                  : (const SizedBox()),
              SizedBox(height: 0.03 * height),
              Row(
                children: [
                  Flexible(
                    flex: 7,
                    child: TextField(
                      textAlignVertical: TextAlignVertical.center,
                      controller:
                          nowPage == 0 ? _captchaController : _codeController,
                      onSubmitted: nowPage == 0
                          ? (String s) {
                              _captchaController.text = s;
                              login();
                            }
                          : (String s) {
                              _codeController.text = s;
                              signUp();
                            },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: themeProvider.isDarkMode
                                ? Colors.deepPurple.shade700
                                : Colors.deepPurple.shade300,
                          ),
                        ),
                        hintText: '验证码',
                        prefixIcon: Icon(
                          Icons.ad_units,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          color: Theme.of(context).iconTheme.color,
                          onPressed: nowPage == 0
                              ? _captchaController.clear
                              : _codeController.clear,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 4,
                    child: nowPage == 0
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                captcha = _userService.captcha();
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(left: 0.02 * width),
                              child: FutureBuilder(
                                  future: captcha,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Text('');
                                    } else if (snapshot.hasData) {
                                      return Image.memory(snapshot.data!);
                                    } else {
                                      return const Text('加载失败');
                                    }
                                  }),
                            ),
                          )
                        : GestureDetector(
                            onTap: sendCode,
                            child: Container(
                              padding: EdgeInsets.only(
                                top: 0.01 * height,
                                bottom: 0.01 * height,
                              ),
                              margin: EdgeInsets.only(left: 0.02 * width),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                      0.08,
                                    ), // 阴影颜色
                                    offset: const Offset(1, 1), // 阴影偏移
                                    spreadRadius: 0.1, // 阴影扩散度
                                  ),
                                ],
                                // border: Border.all(width: 1),
                                // borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  codeCollDown ? '获取验证码' : '$codeTime秒后发送',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: codeCollDown
                                        ? Colors.black
                                        : Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
              SizedBox(height: 0.03 * height),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: login,
                      child: Container(
                        margin: EdgeInsets.all(0.01 * width),
                        height: 0.05 * height,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: themeProvider.isDarkMode
                                ? Colors.deepPurple.shade700
                                : Colors.deepPurple.shade300,
                          ),
                          color: nowPage == 0
                              ? themeProvider.isDarkMode
                                  ? Colors.deepPurple.shade700
                                  : Colors.deepPurple.shade300
                              : Colors.white,
                        ),
                        child: Center(
                          child: Text(
                            "登录",
                            style: TextStyle(
                              color: nowPage == 0
                                  ? Colors.grey.shade300
                                  : themeProvider.isDarkMode
                                      ? Colors.deepPurple.shade700
                                      : Colors.deepPurple.shade300,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: signUp,
                      child: Container(
                        margin: EdgeInsets.all(0.01 * width),
                        height: 0.05 * height,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: themeProvider.isDarkMode
                                ? Colors.deepPurple.shade700
                                : Colors.deepPurple.shade300,
                          ),
                          color: nowPage == 1
                              ? themeProvider.isDarkMode
                                  ? Colors.deepPurple.shade700
                                  : Colors.deepPurple.shade300
                              : Colors.white,
                        ),
                        child: Center(
                          child: Text(
                            "注册",
                            style: TextStyle(
                              color: nowPage == 1
                                  ? Colors.grey.shade300
                                  : themeProvider.isDarkMode
                                      ? Colors.deepPurple.shade700
                                      : Colors.deepPurple.shade300,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 0.01 * height),
              AnimatedOpacity(
                opacity: _errorMessage.isEmpty ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: SizedBox(
                  height: _errorMessage.isEmpty ? 0 : 30, // 有错误时高30，无错误时高0
                  child: Center(
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
