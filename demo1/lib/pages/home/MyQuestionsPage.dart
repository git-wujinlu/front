import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import '../../models/request_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home/ConversationPage.dart';

class MyQuestionsPage extends StatefulWidget {
  const MyQuestionsPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MyQuestionsPageState();
  }
}

class _MyQuestionsPageState extends State<MyQuestionsPage> {
  final UserService _userService = UserService();
  bool _isLoading = true;
  String? _error;
  List<dynamic> _questions = [];
  // 保存问题详情的Map
  final Map<int, Map<String, dynamic>> _questionDetails = {};

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
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

      final response = await _userService.getUserQuestions(
        username ?? '',
      );

      // 检查登录状态和数据有效性
      if (response['success'] != true || response['data'] == null) {
        setState(() {
          _questions = [];
          _isLoading = false;
        });
        return;
      }

      final questions = response['data'] as List;

      // 为每个问题加载详情
      for (var question in questions) {
        if (question['questionId'] != null) {
          try {
            final questionId = question['questionId'] as int;
            final detailResponse =
                await _userService.getQuestionById(questionId);
            if (detailResponse['success'] == true &&
                detailResponse['data'] != null) {
              _questionDetails[questionId] = detailResponse['data'];
            }
          } catch (e) {
            print('加载问题详情失败: $e');
          }
        }
      }

      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      print('加载问题列表失败: $e');
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
              ElevatedButton(
                  onPressed: _loadQuestions, child: const Text('重试')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的提问'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: Theme.of(context).iconTheme,
      ),
      body: _questions.isEmpty
          ? const Center(child: Text('暂无提问'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                final question = _questions[index];
                final questionId = question['questionId'] as int?;
                final details =
                    questionId != null ? _questionDetails[questionId] : null;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () {
                      // 跳转到聊天界面
                      if (question['user2'] != null &&
                          question['questionId'] != null &&
                          question['id'] != null) {
                        _navigateToConversation(
                          user2Id: question['user2'] as int,
                          questionId: question['questionId'] as int,
                          conversationId: question['id'] as int,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('无法打开会话，缺少必要信息')),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            details != null
                                ? details['title'] ?? '未知标题'
                                : '加载中...',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            details != null
                                ? details['content'] ?? '无内容'
                                : '加载中...',
                            style: const TextStyle(fontSize: 16),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
                              Text('${question['likeCount'] ?? 0}'),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '创建时间: ${_formatDateTime(question['createTime'])}',
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
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  // 格式化日期时间
  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return '未知时间';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeStr;
    }
  }

  // 获取状态文本
  String _getStatusText(int? status) {
    switch (status) {
      case 0:
        return '进行中';
      case 1:
        return '已结束';
      case 2:
        return '已取消';
      default:
        return '未知状态';
    }
  }

  // 导航到聊天页面
  void _navigateToConversation(
      {required int user2Id,
      required int questionId,
      required int conversationId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConversationPage(
          fromQuestion: true,
          user2Id: user2Id,
          conversationId: conversationId,
        ),
      ),
    );
  }
}
