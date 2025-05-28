import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:demo1/pages/home/CommentPage.dart';
import 'package:demo1/services/user_service.dart';
import '../../services/message_service.dart';

// 引入 user_service

class ConversationPage extends StatefulWidget {
  final bool fromQuestion;
  final int user2Id;
  final int conversationId;


  const ConversationPage({
    super.key,
    required this.fromQuestion,
    required this.user2Id,
    required this.conversationId,
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
  String myUsername = '';
  String otherUsername = '';
  final ScrollController _inputScrollController = ScrollController(); // 输入框内部滚动
  double _keyboardHeight = 0;


  @override
  void initState() {
    super.initState();
    _loadMessagesAndAvatars();

  }

  Future<void> _loadMessagesAndAvatars() async {
    final prefs = await SharedPreferences.getInstance();
    myUsername = prefs.getString('username') ?? '';

    try {
      final user = await UserService().getUserById(widget.user2Id);
      otherUsername = user?['username'];
      final messagesResponse1 = await MessageService().getMessagesBetweenUsers(myUsername, otherUsername, widget.conversationId);
      final messagesResponse2 = await MessageService().getMessagesBetweenUsers(otherUsername, myUsername, widget.conversationId);
      final data1 = messagesResponse1['data'] as List;
      final data2 = messagesResponse2['data'] as List;

// 为 data1 添加 isMe: true
      final messagesFromMe = data1.map((msg) =>
      {
        'text': msg['content'],
        'isMe': true,
        'createTime': msg['createTime'],
      }).toList();

// 为 data2 添加 isMe: false
      final messagesFromOther = data2.map((msg) =>
      {
        'text': msg['content'],
        'isMe': false,
        'createTime': msg['createTime'],
      }).toList();

// 合并两个消息列表
      final combinedMessages = [...messagesFromMe, ...messagesFromOther];

// 按 createTime 排序（升序）
      combinedMessages.sort((a, b) => a['createTime'].compareTo(b['createTime']));

// 去掉 createTime 字段，只保留 text 和 isMe
      _messages = combinedMessages.map((msg) =>
      {
        'text': msg['text'],
        'isMe': msg['isMe'],
      }).toList();
      final me = await UserService().getUserByUsername();
      final other = await UserService().getUserById(widget.user2Id);
      setState(() {
        _myAvatarUrl = me['data']['avatar'];
        _otherAvatarUrl = other?['avatar'];
      });
    } catch (e) {
      print('加载消息或头像失败: $e');
    }
    setState(() {});
    _scrollToBottomWhenReady();
  }

  void _scrollToBottomWhenReady() async {
    while (!_scrollController.hasClients || _scrollController.position.maxScrollExtent == 0) {
      await Future.delayed(const Duration(milliseconds: 20));
    }
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
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
      await MessageService().addMessage(widget.user2Id,widget.conversationId, text);
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    final newKeyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    if (newKeyboardHeight != _keyboardHeight) {
      _keyboardHeight = newKeyboardHeight;

      // 键盘弹出时滚动到底部
      if (_keyboardHeight > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
      }
    }
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
                      otherUsername,
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
                  final msg = _messages[index];
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
            //SizedBox(height: 0.05 * height),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.05 * width),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: 0.18 * height,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.purple.shade700, // 改为紫色
                          width: 2,             // 加粗边框
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: Scrollbar(
                        thumbVisibility: false,
                        controller: _inputScrollController,
                        child: TextField(
                          controller: _textController,
                          scrollController: _inputScrollController,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          onChanged: (text) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (_scrollController.hasClients) {
                                _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                              }
                            });
                          },
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            hintText: '输入消息',
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),
                  // 发送按钮
                  ElevatedButton(
                    onPressed: _sendMessage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade700,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text('发送', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),

            SizedBox(height: 0.01 * height),
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
                                targetUser: otherUsername
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
