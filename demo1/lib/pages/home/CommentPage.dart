import 'package:demo1/services/message_service.dart';
import 'package:flutter/material.dart';
// 引入 user_service

class CommentPage extends StatefulWidget {
  final bool fromQuestion;
  final String targetUser;
  final int conversationId;

  const CommentPage({
    super.key,
    required this.fromQuestion,
    required this.targetUser,
    required this.conversationId,
  });

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  bool _isPublic = true; // 默认是公开
  int? _lastRating; // 记录最后一次点击，1表示好评，-1表示差评

  void endConversation() async {
    if (_lastRating != null) {
      try {
        await MessageService().like(widget.targetUser, _lastRating!);
        print('评价成功');
      } catch (e) {
        print('评价失败: $e');
      }
    } else {
      print('未进行评价');
    }
    await MessageService().endConversation(widget.conversationId);
    MessageService().setConversationPublic(widget.conversationId, _isPublic);
    Navigator.pop(context);
    Navigator.pop(context);
  }

  Widget _buildSwitchTile() {
    return GestureDetector(
      onTap: () {
        setState(() => _isPublic = !_isPublic);
      },
      child: Container(
        width: 60,
        height: 30,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: _isPublic ? Colors.deepPurple : Colors.grey.shade300,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: _isPublic ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
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
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: Theme.of(context).cardTheme.color,
            height: 0.225 * height,
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
          Container(height: 0.01 * height, color: Theme.of(context).cardTheme.color),
          SizedBox(
            height: 0.06 * height,
            child: Container(
              color: Theme.of(context).cardTheme.color,
              padding: EdgeInsets.symmetric(horizontal: 0.1 * width),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Spacer(flex: 2),
                  Text(
                    '问题公开：',
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const Spacer(flex: 1),
                  _buildSwitchTile(),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
          Container(height: 0.02 * height, color: Theme.of(context).cardTheme.color),
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
                  onPressed: endConversation,
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


