import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:demo1/pages/home/CommentPage.dart';
import 'package:demo1/services/user_service.dart';

// 引入 user_service

class ConversationPage extends StatefulWidget {
  final bool fromQuestion;
  final String name;

  const ConversationPage({
    super.key,
    required this.fromQuestion,
    required this.name,
  });

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  String? _myAvatarUrl;
  String? _otherAvatarUrl;
  String _myUsername = '';

  @override
  void initState() {
    super.initState();
    _loadMessagesAndAvatars();
  }

  Future<void> _loadMessagesAndAvatars() async {
    final prefs = await SharedPreferences.getInstance();
    _myUsername = prefs.getString('username') ?? '';

    try {
      final messagesResponse1 = await UserService().getMessagesBetweenUsers(_myUsername,widget.name);
      final messagesResponse2 = await UserService().getMessagesBetweenUsers(widget.name,_myUsername);
      final data1 = messagesResponse1['data'] as List;
      final data2 = messagesResponse2['data'] as List;

// 为 data1 添加 isMe: true
      final messagesFromMe = data1.map((msg) => {
        'text': msg['content'],
        'isMe': true,
        'createTime': msg['createTime'],
      }).toList();

// 为 data2 添加 isMe: false
      final messagesFromOther = data2.map((msg) => {
        'text': msg['content'],
        'isMe': false,
        'createTime': msg['createTime'],
      }).toList();

// 合并两个消息列表
      final combinedMessages = [...messagesFromMe, ...messagesFromOther];

// 按 createTime 排序（升序）
      combinedMessages.sort((a, b) => b['createTime'].compareTo(a['createTime']));

// 去掉 createTime 字段，只保留 text 和 isMe
      _messages = combinedMessages.map((msg) => {
        'text': msg['text'],
        'isMe': msg['isMe'],
      }).toList();
      final me = await UserService().getUserByUsername();
      final other = await UserService().getOtherUserByUsername(widget.name);
      setState(() {
        _myAvatarUrl = me['data']['avatar'];
        _otherAvatarUrl = other['data']['avatar'];
      });
    } catch (e) {
      print('加载消息或头像失败: $e');
    }
    setState(() {});
  }

  Widget _buildAvatar(String? url) {
    if (url == null || url.isEmpty) {
      return ClipOval(
        child: Image.asset('assets/img.png', width: 32, height: 32, fit: BoxFit.cover),
      );
    }
    return ClipOval(
      child: Image.network(
        url,
        width: 32,
        height: 32,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Image.asset('assets/img.png', width: 32, height: 32, fit: BoxFit.cover);
        },
      ),
    );
  }

  void _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    try {
      await UserService().addMessage(widget.name, text);
      UserService().getMessagesBetweenUsers("c", "b");
      setState(() {
        _messages.add({'text': text, 'isMe': true});
        _textController.clear();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          0, // 如果 ListView 设置了 reverse: true，0 表示滚动到底部
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    } catch (e) {
      print('发送消息失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
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
                      widget.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 0.05 * width, vertical: 8),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[_messages.length - 1 - index];
                  final isMe = msg['isMe'];
                  final avatar = isMe
                      ? _buildAvatar(_myAvatarUrl)
                      : _buildAvatar(_otherAvatarUrl);

                  final bubble = Container(
                    constraints: BoxConstraints(maxWidth: 0.7 * width),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.purple.shade700 : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      msg['text'],
                      style: TextStyle(
                        fontSize: 16,
                        color: isMe ? Colors.white : Colors.black,
                      ),
                    ),
                  );

                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isMe) ...[avatar, const SizedBox(width: 8)],
                        bubble,
                        if (isMe) ...[const SizedBox(width: 8), avatar],
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 0.02 * height),
            SizedBox(
              height: 0.18 * height,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.05 * width),
                child: Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: '输入消息',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12), // 设置圆角半径
                      ),
                    ),
                    maxLines: null,
                  ),
                      )
                    ),
                    const SizedBox(width: 8),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: ElevatedButton(
                        onPressed: _sendMessage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade700,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        child: const Text(
                          '发送',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 0.02 * height),
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
                        builder: (context) =>
                            CommentPage(
                                fromQuestion: widget.fromQuestion,
                                targetUser: widget.name
                            ),
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
            SizedBox(height: 0.02 * height),
          ],
        ),
      ),
    );
  }
}
