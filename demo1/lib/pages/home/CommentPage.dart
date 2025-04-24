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
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: 0.05 * height,
          ),

          // 上方5%：浅灰色背景+右上角返回按钮
          SizedBox(
            height: 0.05 * height,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
          ),

          // 往下25%：浅灰色背景
          Container(
            height: 0.25 * height,
          ),
          Container(
            height: 0.01 * height,
            color: Colors.white,
          ),
          // 往下5%：提示语句
          SizedBox(
            height: 0.05 * height,
            child: Center(
              child: Text(
                widget.fromQuestion ? '请对回答者做出评价~' : '请对提问者做出评价~',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(
            height: 0.02 * height,
          ),
          // 往下10%：大拇指按钮
          SizedBox(
            height: 0.10 * height,
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


          SizedBox(
            height: 0.03 * height,
          ),
          // 往下5%：确定取消按钮

          SizedBox(
            height: 0.05 * height,
            child: Center(
              child: SizedBox(
                width: 0.25 * width,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('确定', style: TextStyle(color: Colors.black)),
                ),
              ),
            ),
          ),
          // 往下40%：浅灰色背景
          Expanded(
            child: Container(
            ),
          ),
        ],
      ),
    );
  }
}
