import 'package:flutter/material.dart';
import 'package:demo1/pages/home/CommentPage.dart';

class ConversationPage extends StatefulWidget {
  final bool fromQuestion; // 新增参数
  const ConversationPage({super.key, required this.fromQuestion});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final TextEditingController _textController = TextEditingController();
  final List<Map<String, dynamic>> _messages = List.generate(
    20,
        (index) => {
      'text': '对话 ' * (index + 1),
      'isMe': index % 2 == 0,
    },
  );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 顶部导航栏 (10%)
            SizedBox(
              height: 0.05 * height,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Center(
                    child: Text(
                      '对话者',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 对话列表 (75%)
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: 0.05 * width,
                  vertical: 8,
                ),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final avatar = ClipOval(
                    child: Image.asset(
                      'assets/img.png',
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                    ),
                  );
                  final bubble = Container(
                    constraints: BoxConstraints(maxWidth: 0.7 * width),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: msg['isMe'] ? Color(0xFFC7EFA9) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      msg['text'],
                      style: const TextStyle(fontSize: 16),
                    ),
                  );

                  return Align(
                    alignment: msg['isMe'] ? Alignment.centerRight : Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!msg['isMe']) ...[
                          avatar,
                          const SizedBox(width: 8),
                        ],
                        bubble,
                        if (msg['isMe']) ...[
                          const SizedBox(width: 8),
                          avatar,
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              height: 0.02 * height,
            ),
            // 输入框与发送按钮 (5%)
            SizedBox(
              height: 0.05 * height,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.05 * width),
                child: Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: TextField(
                          controller: _textController,
                          keyboardType: TextInputType.multiline,
                          minLines: 1,
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: '输入消息',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: ElevatedButton(
                        onPressed: () {
                          print('send');
                          _textController.clear();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFC7EFA9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        child: const Text('发送'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 0.02 * height,
            ),
            // 结束对话按钮 (5%)
            SizedBox(
              height: 0.05 * height,
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.05 * width),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CommentPage(fromQuestion: widget.fromQuestion),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '结束对话',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 0.02 * height,
            ),
          ],
        ),
      ),
    );
  }
}
