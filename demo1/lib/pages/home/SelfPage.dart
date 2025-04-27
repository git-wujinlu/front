import 'package:flutter/material.dart';
import 'package:demo1/pages/home/SettingsPage.dart';
import 'package:demo1/pages/home/ProfilePage.dart';
import 'package:demo1/pages/home/MyQuestionsPage.dart';
import 'package:demo1/pages/home/MyAnswersPage.dart';

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
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: Theme.of(context).iconTheme,
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // 头像和姓名部分
            Container(
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20.0,
                  horizontal: 16.0,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(
                        'https://via.placeholder.com/150',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '陈某某',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '北京航空航天大学 计算机科学与技术 大三学生',
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '积分：1280',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 我的标签部分
            Container(
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20.0,
                  horizontal: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '我的标签',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: [
                        Chip(
                          side: BorderSide(color: Theme.of(context).cardTheme.color as Color),
                          label: const Text('算法'),
                          backgroundColor: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.8),
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                        Chip(
                          side: BorderSide(color: Theme.of(context).cardTheme.color as Color),
                          label: const Text('机器学习'),
                          backgroundColor: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.8),
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                        Chip(
                          side: BorderSide(color: Theme.of(context).cardTheme.color as Color),
                          label: const Text('Python'),
                          backgroundColor: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.8),
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                        Chip(
                          side: BorderSide(color: Theme.of(context).cardTheme.color as Color),
                          label: const Text('Web 开发'),
                          backgroundColor: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.8),
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // 功能按钮部分
            _buildFunctionButton(
              icon: Icons.account_circle,
              title: '个人资料',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildFunctionButton(
              icon: Icons.comment,
              title: '我的回答',
              trailing: '38条',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyAnswersPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildFunctionButton(
              icon: Icons.question_answer,
              title: '我的提问',
              trailing: '2条',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyQuestionsPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFunctionButton({
    required IconData icon,
    required String title,
    String? trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 20.0,
              horizontal: 16.0,
            ),
            child: Row(
              children: [
                Icon(icon, size: 30, color: Theme.of(context).primaryColor),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const Spacer(),
                if (trailing != null) ...[
                  Text(
                    trailing,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                      fontSize: 14.0,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
