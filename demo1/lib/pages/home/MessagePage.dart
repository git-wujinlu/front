import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/user_service.dart';
import 'ConversationPage.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> activeQuestions = [];
  List<dynamic> activeAnswers = [];
  bool isLoadingQuestions = true;
  bool isLoadingAnswers = true;

  final UserService _userService = UserService(); // 实例化 UserService

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Load active questions when the page is first initialized
    getActiveQuestions();
    getActiveAnswers();
  }

  // Get active questions
  Future<void> getActiveQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username') ?? '';

    try {
      final response = await _userService.getUserQuestions(username);
      setState(() {
        activeQuestions = response['data'];
        isLoadingQuestions = false;
      });
    } catch (e) {
      print('获取用户问题失败: $e');
      setState(() {
        isLoadingQuestions = false;
      });
    }
  }

  // Get active answers
  Future<void> getActiveAnswers() async {
    final prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username') ?? '';

    try {
      final response = await _userService.getUserAnswers(username);
      setState(() {
        activeAnswers = response['data'];
        isLoadingAnswers = false;
      });
    } catch (e) {
      print('获取用户回答失败: $e');
      setState(() {
        isLoadingAnswers = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.05 * width),
          child: Column(
            children: [
              // Header: Logo and Title
              Container(
                height: 0.05 * height,
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Image.asset(
                      'assets/logo1.png',
                      height: 0.04 * height,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "航准答",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // TabBar
              SizedBox(height: 0.01 * height),
              Container(
                height: 0.05 * height,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: false,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: const BoxDecoration(
                    color: Colors.deepPurple,
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black,
                  tabs: const [
                    Tab(text: "我的提问"),
                    Tab(text: "我的回答"),
                  ],
                ),
              ),
              // TabView
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    MyQuestionsTab(activeQuestions: activeQuestions, isLoading: isLoadingQuestions),
                    MyAnswersTab(activeAnswers: activeAnswers, isLoading: isLoadingAnswers),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class MyQuestionsTab extends StatelessWidget {
  final List<dynamic> activeQuestions;
  final bool isLoading;

  const MyQuestionsTab({super.key, required this.activeQuestions, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (activeQuestions.isEmpty) {
      return const Center(
        child: Text(
          "当前暂无提问",
          style: TextStyle(fontSize: 24), // 增大字号
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return ListView.builder(
      itemCount: activeQuestions.length,
      itemBuilder: (context, index) {
        var question = activeQuestions[index];
        String title = question['title'] ?? '无标题';
        String content = question['content'] ?? '无内容';
        String avatar = question['images'] != null && question['images'].isNotEmpty
            ? question['images'][0]
            : 'assets/img.png'; // 默认头像

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>  ConversationPage(fromQuestion: true,name: question['username'],),
              ),
            );
          },
          child: SizedBox(
            height: 0.15 * height,
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 0.01 * height),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(context).textTheme.bodyLarge?.color == Colors.white
                      ? Colors.black
                      : Colors.white,
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 0.15 * width,
                    child: ClipOval(
                      child: avatar.startsWith('http') ?
                      Image.network( avatar,
                        width: 0.15 * width,
                        height: 0.15 * width,
                        fit: BoxFit.cover,) :
                      Image.asset(
                        avatar,
                        width: 0.15 * width,
                        height: 0.15 * width,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 0.65 * width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          content,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class MyAnswersTab extends StatelessWidget {
  final List<dynamic> activeAnswers;
  final bool isLoading;

  const MyAnswersTab({super.key, required this.activeAnswers, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (activeAnswers.isEmpty) {
      return const Center(child: Text(
          "当前暂无回答",
          style: TextStyle(fontSize: 24), ),);
    }

    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return ListView.builder(
      itemCount: activeAnswers.length,
      itemBuilder: (context, index) {
        var answer = activeAnswers[index];
        String title = answer['title'] ?? '无标题';
        String content = answer['content'] ?? '无内容';
        String avatar = answer['images'] != null && answer['images'].isNotEmpty
            ? answer['images'][0]
            : 'assets/img.png'; // 默认头像

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConversationPage(fromQuestion: false,name: answer['username'],),
              ),
            );
          },
          child: SizedBox(
            height: 0.15 * height,
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 0.01 * height),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(context).textTheme.bodyLarge?.color == Colors.white
                      ? Colors.black
                      : Colors.white,
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 0.15 * width,
                    child: ClipOval(
                      child: avatar.startsWith('http') ?
                      Image.network( avatar,
                        width: 0.15 * width,
                        height: 0.15 * width,
                        fit: BoxFit.cover,) :
                      Image.asset(
                        avatar,
                        width: 0.15 * width,
                        height: 0.15 * width,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 0.65 * width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          content,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
