import 'package:flutter/material.dart';

class SelfPage extends StatefulWidget {
  const SelfPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SelfPageState();
  }
}

class _SelfPageState extends State<SelfPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人中心'),
        backgroundColor: Colors.white, // 设置背景为白色
        iconTheme: const IconThemeData(color: Colors.black), // 图标颜色为黑色
        actions: [
          // 设置按钮
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black), // 设置图标
            onPressed: () {
              print('进入设置页面');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // 头像和姓名部分，背景色设置为白色，无阴影
            Container(
              margin: const EdgeInsets.only(bottom: 16.0), // 减小间距
              color: Colors.white, // 设置背景为白色
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage('https://via.placeholder.com/150'), // 头像
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '陈某某',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '北京航空航天大学 计算机科学与技术 大三学生',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // 我的标签部分，背景色设置为白色，无阴影
            Container(
              margin: const EdgeInsets.only(bottom: 16.0), // 减小间距
              color: Colors.white, // 设置背景为白色
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '我的标签',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10), // 添加间距
                    // 具体标签部分，去除左右边距
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: const [
                        Chip(
                          label: Text('算法'),
                          backgroundColor: Colors.purple,
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        Chip(
                          label: Text('机器学习'),
                          backgroundColor: Colors.orange,
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        Chip(
                          label: Text('Python'),
                          backgroundColor: Colors.green,
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        Chip(
                          label: Text('Web 开发'),
                          backgroundColor: Colors.blue,
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // 个人资料部分，整个区域可点击
            ElevatedButton(
              onPressed: () {
                print('进入个人资料');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // 背景色设置为白色
                foregroundColor: Colors.black, // 文字颜色
                elevation: 0, // 去掉阴影
                padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(
                children: const [
                  const Icon(Icons.account_circle, size: 40, color: Colors.blue),
                  const SizedBox(width: 16),
                  const Text(
                    '个人资料',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios),
                ],
              ),
            ),
            const SizedBox(height: 16), // 设置个人资料与回答之间的间距

            // 我的回答部分，包含条数，文字和条数在同一个按钮上，去除左右边距
            ElevatedButton(
              onPressed: () {
                print("我的回答被点击了！");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // 背景色设置为白色
                foregroundColor: Colors.black, // 文字颜色
                elevation: 0, // 去掉阴影
                padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.comment, size: 30, color: Colors.blue), // 图标
                  SizedBox(width: 16),
                  Text(
                    '我的回答',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  Text(
                    '38条',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios),
                ],
              ),
            ),
            const SizedBox(height: 16), // 设置回答和提问之间的间距

            // 我的提问部分，包含条数，文字和条数在同一个按钮上，去除左右边距
            ElevatedButton(
              onPressed: () {
                print("我的提问被点击了！");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // 背景色设置为白色
                foregroundColor: Colors.black, // 文字颜色
                elevation: 0, // 去掉阴影
                padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.question_answer, size: 30, color: Colors.blue), // 图标
                  SizedBox(width: 16),
                  Text(
                    '我的提问',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  Text(
                    '2条',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
