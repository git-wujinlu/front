import 'package:flutter/material.dart';

class CommentPage extends StatefulWidget {
  final bool fromQuestion;
  const CommentPage({super.key, required this.fromQuestion});

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      backgroundColor:Theme.of(context).textTheme.bodyLarge?.color == Colors.white
        ? Colors.black
        : Colors.white,
      body: Column(
        children: [
          Container(
            height: 0.05 * height,
          ),

          // 上方5%：浅灰色背景+右上角返回按钮
          SizedBox(
            height: 0.05 * height,
            child: Container(
              color: Theme.of(context).cardTheme.color,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon:  Icon(Icons.close,
                        color: Theme.of(context).textTheme.bodyLarge?.color
                    ), // 图标设置成白色
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),


          // 往下25%：浅灰色背景
          Container(
            color: Theme.of(context).cardTheme.color,
            height: 0.275 * height,
          ),
          // 往下5%：提示语句
          SizedBox(
            height: 0.05 * height,
            child: Container(
              color: Theme.of(context).cardTheme.color,
              child: Center(
              child: Text(
                widget.fromQuestion ? '请对回答者做出评价~' : '请对提问者做出评价~',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            ),
          ),
          Container(
            height: 0.02 * height,
            color: Theme.of(context).cardTheme.color,
          ),
          // 往下10%：大拇指按钮
          SizedBox(
            height: 0.10 * height,
            child: Container(
              color: Theme.of(context).cardTheme.color,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () => print('好'),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      child: const Icon(Icons.thumb_up, color: Colors.white),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => print('坏'),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                      ),
                      child: const Icon(Icons.thumb_down, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),


          Container(
            height: 0.03 * height,
            color: Theme.of(context).cardTheme.color,

          ),
          // 往下5%：确定取消按钮

          Container(
            height: 0.05 * height,
            color: Theme.of(context).cardTheme.color,
            child: Center(
              child: SizedBox(
                width: 0.25 * width,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).dividerColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text('确定', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
              ),
            ),
          ),
          ),
          // 往下40%：浅灰色背景
          Expanded(
            child: Container(
              color: Theme.of(context).cardTheme.color,

            ),
          ),
        ],
      ),
    );
  }
}
