import 'package:flutter/material.dart';

class MyAnswersPage extends StatefulWidget {
  const MyAnswersPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MyAnswersPageState();
  }
}

class _MyAnswersPageState extends State<MyAnswersPage> {
  final List<Map<String, dynamic>> _answers = [
    {
      'question': '如何优化Flutter应用的性能？',
      'answer':
          '可以通过以下几个方面来优化Flutter应用的性能：1. 使用const构造函数 2. 避免不必要的重建 3. 使用ListView.builder 4. 图片缓存优化 5. 使用isolate处理耗时操作',
      'time': '2024-03-15',
      'likes': 28,
      'isAccepted': true,
    },
    {
      'question': 'Dart中的Stream和Future有什么区别？',
      'answer':
          'Stream和Future的主要区别在于：Future表示单个异步操作的结果，而Stream表示多个异步事件的序列。Stream可以持续产生数据，而Future只能产生一次结果。',
      'time': '2024-03-10',
      'likes': 15,
      'isAccepted': false,
    },
    {
      'question': 'Flutter中如何实现页面跳转动画？',
      'answer': '可以使用PageRouteBuilder来自定义页面跳转动画，或者使用Hero动画实现页面间的元素过渡效果。',
      'time': '2024-03-05',
      'likes': 12,
      'isAccepted': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的回答'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: Theme.of(context).iconTheme,
      ),
      body: ListView.builder(
        itemCount: _answers.length,
        itemBuilder: (context, index) {
          final answer = _answers[index];
          return _buildAnswerCard(answer);
        },
      ),
    );
  }

  Widget _buildAnswerCard(Map<String, dynamic> answer) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          onTap: () {
            print('进入回答详情');
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (answer['isAccepted'])
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '已采纳',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        answer['question'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  answer['answer'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Theme.of(
                        context,
                      ).iconTheme.color?.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      answer['time'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.thumb_up,
                      size: 16,
                      color: Theme.of(
                        context,
                      ).iconTheme.color?.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${answer['likes']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
