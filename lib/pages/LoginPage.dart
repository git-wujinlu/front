import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    final TextEditingController _usernameController = TextEditingController();
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
                  border: Border.all(width: 2),
                ),
                child: TextField(
                  textAlignVertical: TextAlignVertical.center,
                  controller: _usernameController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '密码',
                    prefixIcon: Icon(Icons.person),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: _usernameController.clear,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 0.03 * height),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/homepage', (route) => false);
                },
                child: Text("登录"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
