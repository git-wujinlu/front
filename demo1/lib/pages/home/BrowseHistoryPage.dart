import 'package:flutter/material.dart';

class BrowseHistoryPage extends StatefulWidget {
  const BrowseHistoryPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _BrowseHistoryPageState();
  }
}

class _BrowseHistoryPageState extends State<BrowseHistoryPage> {
  final List<Map<String, dynamic>> _history = [
    {
      'title': 'Flutter状态管理方案对比',
      'content': '本文对比了Provider、Bloc、GetX等主流状态管理方案的优缺点...',
      'time': '2024-03-15 14:30',
      'type': '文章',
      'duration': '5分钟',
    },
    {
      'title': '如何解决Flutter中的内存泄漏问题？',
      'content': '讨论Flutter应用中常见的内存泄漏问题及解决方案...',
      'time': '2024-03-15 10:15',
      'type': '问答',
      'duration': '3分钟',
    },
    {
      'title': 'Flutter跨平台开发实践',
      'content': '分享在多个平台上使用Flutter进行开发的实战经验...',
      'time': '2024-03-14 16:45',
      'type': '文章',
      'duration': '8分钟',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('浏览历史'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView.builder(
        itemCount: _history.length,
        itemBuilder: (context, index) {
          final item = _history[index];
          return _buildHistoryCard(item);
        },
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
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
            print('进入历史记录详情');
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item['type'],
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item['content'],
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      item['time'],
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.timer, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      item['duration'],
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
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
