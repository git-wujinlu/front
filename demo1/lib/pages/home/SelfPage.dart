import 'package:flutter/material.dart';
import 'package:demo1/pages/home/SettingsPage.dart';
import 'package:demo1/pages/home/ProfilePage.dart';
import 'package:demo1/pages/home/MyQuestionsPage.dart';
import 'package:demo1/pages/home/MyAnswersPage.dart';
import '../../services/user_service.dart';
import '../../models/request_model.dart';

class SelfPage extends StatefulWidget {
  const SelfPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SelfPageState();
  }
}

class _SelfPageState extends State<SelfPage> {
  final UserService _userService = UserService();
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _userInfo;
  List<String> _tags = [];
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final request = Request(
        token: '9d83504a-5d28-4dca-a034-374c569e17d0',
        username: 'wjy',
      );

      // 使用用户名获取用户信息
      final userResponse = await _userService.getUserByUsername(
        'wjy',
        request: request,
      );
      final userData = userResponse['data'];

      // 从用户信息中获取标签字符串并转换为列表
      final tagsString = userData['tags'] as String? ?? '';
      final tagsList =
          tagsString.isNotEmpty
              ? tagsString.split(',').map((e) => e.trim()).toList()
              : <String>[];

      // 获取用户统计信息
      final statsResponse = await _userService.getUserStats(
        'wjy',
        request: request,
      );

      setState(() {
        _userInfo = userData;
        _tags = tagsList;
        _stats = statsResponse['data'];
        _isLoading = false;
      });
    } catch (e) {
      print('加载用户数据失败: $e');
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadUserData, child: const Text('重试')),
            ],
          ),
        ),
      );
    }

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
                        _userInfo?['avatar'] ??
                            'https://via.placeholder.com/150',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userInfo?['username'] ?? '未设置用户名',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '有用回答：${_userInfo?['usefulCount'] ?? 0}',
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
            _buildTagsSection(),
            // 功能按钮部分
            _buildFunctionButton(
              icon: Icons.account_circle,
              title: '个人资料',
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );

                // 如果返回true，说明数据已更新，需要刷新
                if (result == true) {
                  _loadUserData();
                }
              },
            ),
            const SizedBox(height: 16),
            _buildFunctionButton(
              icon: Icons.comment,
              title: '我的回答',
              trailing: '${_stats?['answers'] ?? 0}条',
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
              trailing: '${_stats?['questions'] ?? 0}条',
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

  Widget _buildTagsSection() {
    return Container(
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
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
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
              runSpacing: 8.0,
              children:
                  _tags
                      .map(
                        (tag) => Chip(
                          label: Text(tag),
                          backgroundColor: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                          labelStyle: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      )
                      .toList(),
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
