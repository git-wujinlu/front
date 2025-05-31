import 'package:demo1/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:demo1/services/message_service.dart';
import 'package:demo1/services/ask_service.dart';
import 'ConversationPage.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> questions = [];
  List<dynamic> answers = [];
  final AskService askService = AskService(); // 实例化 UserService
  final UserService userService = UserService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    //askService.askQuestion("Q4", "one question two answerer", [1,3]);
    getConversations();
  }

  Future<String> getUser2Name(int user2Id) async {
    final res = await userService.getUserById(user2Id);
    return res?['data']['username'];
  }


  // Get active questions
  Future<void> getConversations() async {
    try {
      final MessageService messageService = MessageService();
      final AskService askService = AskService(); // 如果未声明全局
      final UserService userService = UserService();

      final response = await messageService.getConversationList();
      List<dynamic> tempQuestions = [];
      List<dynamic> tempAnswers = [];
      for (var item in response) {
        int questionId = item['questionId'];
        int user2Id = item['user2'];
        // 获取问题
        item['question'] = await askService.getQuestionById(questionId);
        // 获取用户名
        final userResponse = await userService.getUserById(user2Id);
        item['user2Name'] = userResponse?['username'];
        item['user2Avatar'] = userResponse?['avatar'];
        // 分类
        if (item['user1'] == -1) {
          tempQuestions.add(item);
        } else {
          tempAnswers.add(item);
        }
      }
      setState(() {
        questions = tempQuestions;
        answers = tempAnswers;
      });
    } catch (e) {
      print('获取用户问题失败: $e');
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
                    MyQuestionsTab(activeQuestions: questions),
                    MyAnswersTab(activeAnswers: answers),
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


class MyQuestionsTab extends StatefulWidget {
  final List<dynamic> activeQuestions;
  const MyQuestionsTab({super.key, required this.activeQuestions});

  @override
  State<MyQuestionsTab> createState() => _MyQuestionsTabState();
}

class _MyQuestionsTabState extends State<MyQuestionsTab> {
  final Map<int, bool> _expandedMap = {};

  @override
  Widget build(BuildContext context) {
    if (widget.activeQuestions.isEmpty) {
      return const Center(
        child: Text(
          "当前暂无提问",
          style: TextStyle(fontSize: 24),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    // 按照 question['question']['id'] 进行分组
    Map<int, List<dynamic>> grouped = {};
    for (var q in widget.activeQuestions) {
      int questionId = q['question']['id'];
      grouped.putIfAbsent(questionId, () => []).add(q);
    }

    return ListView(
      children: grouped.entries.map((entry) {
        int questionId = entry.key;
        List<dynamic> conversations = entry.value;
        String title = conversations[0]['question']['title'];
        String content = conversations[0]['question']['content'];

        bool isExpanded = _expandedMap[questionId] ?? false;

        return Column(
          children: [
            SizedBox(
              height: 0.15 * height,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _expandedMap[questionId] = !isExpanded;
                  });
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 0.01 * height, horizontal: 12),
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
                      // 左边保留头像占位的宽度，保持布局一致
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 0.55 * width, // 0.65 减去右边箭头预留空间
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center, // 垂直居中内容
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
                      const Spacer(),
                      Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                    ],
                  ),
                ),
              ),
            ),

            if (isExpanded)
              ...conversations.map((q) {
                int conversationId = q['id'];
                int user2Id = q['user2'];
                String userName = q['user2Name'];
                String avatarUrl = UserService.getFullAvatarUrl(q['user2Avatar']);
                return GestureDetector(
                  onTap: () {
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
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 24),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).textTheme.bodyLarge?.color == Colors.white
                          ? Colors.purple.shade800
                          : Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: Row(
                      children: [
                        ClipOval(
                          child: avatarUrl.isEmpty
                              ? Image.asset(
                            'assets/img.png',
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          )
                              : Image.network(
                            avatarUrl,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.asset(
                              'assets/img.png',
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            userName,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        );
      }).toList(),
    );
  }
}


class MyAnswersTab extends StatelessWidget {
  final List<dynamic> activeAnswers;
  const MyAnswersTab({super.key, required this.activeAnswers});

  @override
  Widget build(BuildContext context) {

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
        String title = answer['question']['title'];
        String content = answer['question']['content'];
        String avatar = answer['images'] != null && answer['images'].isNotEmpty
            ? answer['images'][0]
            : 'assets/img.png'; // 默认头像

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConversationPage(fromQuestion: false,user2Id: answer['user1'],conversationId: answer['id'],),
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
