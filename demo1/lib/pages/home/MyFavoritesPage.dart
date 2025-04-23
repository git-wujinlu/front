import 'package:flutter/material.dart';

class MyFavoritesPage extends StatefulWidget {
  const MyFavoritesPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MyFavoritesPageState();
  }
}

class _MyFavoritesPageState extends State<MyFavoritesPage> {
  final List<Map<String, dynamic>> _favorites = [
    {
      'title': 'Flutter性能优化最佳实践',
      'content': '本文详细介绍了Flutter应用性能优化的各种技巧和最佳实践...',
      'time': '2024-03-15',
      'type': '文章',
      'author': '张工程师',
    },
    {
      'title': 'Dart异步编程详解',
      'content': '深入理解Dart中的异步编程模型，包括Future、Stream和async/await的使用...',
      'time': '2024-03-10',
      'type': '问答',
      'author': '李老师',
    },
    {
      'title': 'Flutter UI设计指南',
      'content': '一份完整的Flutter UI设计指南，包含布局、主题、动画等各个方面...',
      'time': '2024-03-05',
      'type': '文章',
      'author': '王设计师',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的收藏'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView.builder(
        itemCount: _favorites.length,
        itemBuilder: (context, index) {
          final favorite = _favorites[index];
          return _buildFavoriteCard(favorite);
        },
      ),
    );
  }

  Widget _buildFavoriteCard(Map<String, dynamic> favorite) {
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
            print('进入收藏详情');
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
                        color: Colors.deepPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        favorite['type'],
                        style: const TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        favorite['title'],
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
                  favorite['content'],
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
                      favorite['time'],
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      favorite['author'],
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
