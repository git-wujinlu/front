import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  final TextEditingController _passwordCheckController =
      TextEditingController();
  bool _obscurePasswordCheck = true;
  bool passwordChecked = true;
  int nowPage = 0;

  void login() {
    if (nowPage == 1) {
      setState(() {
        nowPage = 0;
      });
    } else {
      Navigator.pushNamedAndRemoveUntil(context, '/homepage', (route) => false);
    }
  }

  void signUp() {
    if (nowPage == 0) {
      setState(() {
        nowPage = 1;
      });
    } else {
      if (!passwordChecked) {
      } else {
        setState(() {
          nowPage = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    return Scaffold(
      body: Center(
        child: Container(
          width: 0.8 * width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(width: 2),
                ),
                child: TextField(
                  textAlignVertical: TextAlignVertical.center,
                  controller: _usernameController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '用户名',
                    prefixIcon: Icon(Icons.person),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: _usernameController.clear,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 0.03 * height),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    width: 2,
                    color:
                        passwordChecked || nowPage == 0
                            ? Colors.black
                            : Colors.red,
                  ),
                ),
                child: TextField(
                  style: TextStyle(
                    color:
                        passwordChecked || nowPage == 0
                            ? Colors.black
                            : Colors.red,
                  ),
                  onChanged: (String s) {
                    passwordChecked =
                        s.compareTo(_passwordCheckController.text) == 0;
                  },
                  textAlignVertical: TextAlignVertical.center,
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '密码',
                    prefixIcon: Icon(
                      Icons.lock,
                      color:
                          passwordChecked || nowPage == 0
                              ? Colors.black
                              : Colors.red,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color:
                            passwordChecked || nowPage == 0
                                ? Colors.black
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
              ),
              nowPage == 1
                  ? (Column(
                    children: [
                      SizedBox(height: 0.03 * height),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            width: 2,
                            color:
                                passwordChecked || nowPage == 0
                                    ? Colors.black
                                    : Colors.red,
                          ),
                        ),
                        child: TextField(
                          style: TextStyle(
                            color:
                                passwordChecked || nowPage == 0
                                    ? Colors.black
                                    : Colors.red,
                          ),
                          onChanged: (String s) {
                            passwordChecked =
                                s.compareTo(_passwordController.text) == 0;
                          },
                          textAlignVertical: TextAlignVertical.center,
                          controller: _passwordCheckController,
                          obscureText: _obscurePasswordCheck,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '确认密码',
                            prefixIcon: Icon(
                              Icons.lock,
                              color:
                                  passwordChecked || nowPage == 0
                                      ? Colors.black
                                      : Colors.red,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePasswordCheck
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color:
                                    passwordChecked || nowPage == 0
                                        ? Colors.black
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
                      ),
                    ],
                  ))
                  : (SizedBox()),
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
                          border: Border.all(color: Colors.blue.shade500),
                          color:
                              nowPage == 0
                                  ? Colors.blue.shade500
                                  : Colors.white,
                        ),
                        child: Center(
                          child: Text(
                            "登录",
                            style: TextStyle(
                              color:
                                  nowPage == 0
                                      ? Colors.grey.shade200
                                      : Colors.blue.shade500,
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
                          border: Border.all(color: Colors.blue.shade500),
                          color:
                              nowPage == 1
                                  ? Colors.blue.shade500
                                  : Colors.white,
                        ),
                        child: Center(
                          child: Text(
                            "注册",
                            style: TextStyle(
                              color:
                                  nowPage == 1
                                      ? Colors.grey.shade200
                                      : Colors.blue.shade500,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
