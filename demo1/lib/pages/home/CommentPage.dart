import 'package:flutter/material.dart';
import 'package:demo1/services/user_service.dart'; // 引入 user_service

class CommentPage extends StatefulWidget {
  final bool fromQuestion;
  final String targetUser;

  const CommentPage({
    super.key,
    required this.fromQuestion,
    required this.targetUser,
  });

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  int? _lastRating; // 记录最后一次点击，1表示好评，-1表示差评

  void _submitRating() async {
    if (_lastRating != null) {
      try {
        await UserService().like(widget.targetUser, _lastRating!);
        print('评价成功');
      } catch (e) {
        print('评价失败: $e');
      }
    } else {
      print('未进行评价');
    }
    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      backgroundColor:
      Theme.of(context).textTheme.bodyLarge?.color == Colors.white
          ? Colors.black
          : Colors.white,
      body: Column(
        children: [
          Container(height: 0.05 * height),
          SizedBox(
            height: 0.05 * height,
            child: Container(
              color: Theme.of(context).cardTheme.color,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.close,
                        color: Theme.of(context).textTheme.bodyLarge?.color),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: Theme.of(context).cardTheme.color,
            height: 0.275 * height,
          ),
          SizedBox(
            height: 0.05 * height,
            child: Container(
              color: Theme.of(context).cardTheme.color,
              child: Center(
                child: Text(
                  widget.fromQuestion ? '请对回答者做出评价~' : '请对提问者做出评价~',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Container(height: 0.02 * height, color: Theme.of(context).cardTheme.color),
          SizedBox(
            height: 0.10 * height,
            child: Container(
              color: Theme.of(context).cardTheme.color,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() => _lastRating = 1);
                      print('好评');
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _lastRating == 1 ? Colors.red.shade800 : Colors.red,
                      ),
                      child: const Icon(Icons.thumb_up, color: Colors.white),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() => _lastRating = -1);
                      print('差评');
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _lastRating == -1 ? Colors.green.shade800 : Colors.green,
                      ),
                      child: const Icon(Icons.thumb_down, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(height: 0.03 * height, color: Theme.of(context).cardTheme.color),
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
                  onPressed: _submitRating,
                  child: Text('确定',
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color)),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(color: Theme.of(context).cardTheme.color),
          ),
        ],
      ),
    );
  }
}
