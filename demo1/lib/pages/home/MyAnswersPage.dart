import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import '../../models/request_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyAnswersPage extends StatefulWidget {
  const MyAnswersPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MyAnswersPageState();
  }
}

class _MyAnswersPageState extends State<MyAnswersPage> {
  final UserService _userService = UserService();
  bool _isLoading = true;
  String? _error;
  List<dynamic> _answers = [];

  @override
  void initState() {
    super.initState();
    _loadAnswers();
  }

  Future<void> _loadAnswers() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final username = prefs.getString('username');
      print('当前 token: ' + (token ?? 'null'));
      print('当前 username: ' + (username ?? 'null'));

      final response = await _userService.getUserAnswers(username ?? '');

      // 检查登录状态和数据有效性
      if (response['success'] != true || response['data'] == null) {
        setState(() {
          _answers = [];
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _answers = response['data'];
        _isLoading = false;
      });
    } catch (e) {
      print('加载回答列表失败: $e');
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
              ElevatedButton(onPressed: _loadAnswers, child: const Text('重试')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的回答'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: Theme.of(context).iconTheme,
      ),
      body: _answers.isEmpty
          ? const Center(child: Text('暂无回答'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _answers.length,
              itemBuilder: (context, index) {
                final answer = _answers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          answer['content'] ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.thumb_up,
                              size: 16,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text('${answer['likeCount'] ?? 0}'),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: answer['useful'] == 1
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              answer['useful'] == 1 ? '已采纳' : '未采纳',
                              style: TextStyle(
                                color: answer['useful'] == 1
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '回答时间：${answer['createTime'] ?? ''}',
                          style: TextStyle(
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
