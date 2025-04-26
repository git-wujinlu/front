import 'package:flutter/material.dart';
import 'package:demo1/pages/home/ConversationPage.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
              SizedBox(height: 0.02 * height),
              Container(
                height: 0.05 * height,
                alignment: Alignment.centerLeft,
                child: Text("logo", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              Container(
                height: 0.05 * height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[200],
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: false, // 平均分配宽度
                  indicatorSize: TabBarIndicatorSize.tab, // 指示器覆盖整个 Tab
                  indicator: BoxDecoration(
                    color: Colors.blue.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black,
                  tabs: const [
                    Tab(text: "我的提问"),
                    Tab(text: "我的回答"),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    MyQuestionsTab(),
                    MyAnswersTab(),
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
  const MyQuestionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery
        .of(context)
        .size;
    final width = size.width;
    final height = size.height;

    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ConversationPage(fromQuestion: true),
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
                      child: Image.asset(
                        'assets/img.png',
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
                      children: const [
                        Text(
                          "问题标题",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold),

                        ),
                        SizedBox(height: 4),
                        Text(
                          "提问内容提问内容提问内容提问内容提问内容",
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
  const MyAnswersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ConversationPage(fromQuestion: false),
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
                      child: Image.asset(
                        'assets/img.png',
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
                      children: const [
                        Text(
                          "问题标题",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "回答内容回答内容回答内容回答内容回答内容",
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
