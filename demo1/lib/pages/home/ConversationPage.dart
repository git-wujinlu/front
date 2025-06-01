import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:demo1/pages/home/CommentPage.dart';
import 'package:demo1/services/user_service.dart';
import '../../services/message_service.dart';

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
  final ScrollController _inputScrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];

  String? _myAvatarUrl;
  String? _otherAvatarUrl;
  String myUsername = '';
  String otherUsername = '';
  double _keyboardHeight = 0;
  bool endConversation = false;

  @override
  void initState() {
    super.initState();
    _initialize(); // 异步操作放这里
  }

  Future<void> _initialize() async {
    _loadMessagesAndAvatars();
    endConversation = await MessageService().getConversationStatus(widget.conversationId);
    setState(() {}); // 更新状态
  }

  bool isImageUrl(String str) {
    final uri = Uri.tryParse(str);
    return uri != null &&
        (str.endsWith('.png') ||
            str.endsWith('.jpg') ||
            str.endsWith('.jpeg') ||
            str.endsWith('.gif') ||
            str.endsWith('.webp')) &&
        (str.startsWith('http://') || str.startsWith('https://'));
  }

  Future<void> _loadMessagesAndAvatars() async {
    final prefs = await SharedPreferences.getInstance();
    myUsername = prefs.getString('username') ?? '';

    try {
      final user = await UserService().getUserById(widget.user2Id);
      otherUsername = user?['username'] ?? '';
      _otherAvatarUrl = UserService.getFullAvatarUrl(user?['avatar']);
      final myInfo = await UserService().getOtherUserByUsername(myUsername);
      _myAvatarUrl = UserService.getFullAvatarUrl(myInfo['data']['avatar']);
      final messagesResponse1 = await MessageService().getMessagesBetweenUsers(
          myUsername, otherUsername, widget.conversationId);
      final messagesResponse2 = await MessageService().getMessagesBetweenUsers(
          otherUsername, myUsername, widget.conversationId);
      final data1 = messagesResponse1['data'] as List;
      final data2 = messagesResponse2['data'] as List;

      final messagesFromMe = data1
          .map((msg) => {
        'text': msg['content'],
        'isMe': true,
        'createTime': msg['createTime'],
      })
          .toList();

      final messagesFromOther = data2
          .map((msg) => {
        'text': msg['content'],
        'isMe': false,
        'createTime': msg['createTime'],
      })
          .toList();

      final combinedMessages = [...messagesFromMe, ...messagesFromOther];
      combinedMessages.sort((a, b) => a['createTime'].compareTo(b['createTime']));

      _messages = combinedMessages
          .map((msg) => {
        'text': msg['text'],
        'isMe': msg['isMe'],
      })
          .toList();
    } catch (e) {
      print('加载消息或头像失败: $e');
    }

    setState(() {});
    _scrollToBottomWhenReady();
  }

  void _scrollToBottomWhenReady() async {
    while (!_scrollController.hasClients ||
        _scrollController.position.maxScrollExtent == 0) {
      await Future.delayed(const Duration(milliseconds: 20));
    }
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  void _sendMessage(bool type) async {
    final String? text;
    try {
      if (type) {
        text = _textController.text.trim();
        if (text.isEmpty) return;
        await MessageService()
            .addMessage(widget.user2Id, widget.conversationId, text);
      } else {
        text = await MessageService()
            .pickAndUploadImage(widget.user2Id, widget.conversationId);
      }

      setState(() {
        _messages.add({'text': text, 'isMe': true});
        _textController.clear();
      });

      if (type) {
        // 文本消息，直接滚动到底部
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      } else {
        // 图片消息：轮询滚动高度是否稳定
        double lastExtent = _scrollController.position.maxScrollExtent;
        int stableCount = 0;
        const int requiredStableCount = 20; // 连续稳定 5 次认为加载完成
        const int maxTries = 30; // 最多尝试 30 次（3 秒）
        int tries = 0;

        void poll() async {
          await Future.delayed(const Duration(milliseconds: 100));
          if (!_scrollController.hasClients) return;

          double currentExtent = _scrollController.position.maxScrollExtent;
          if ((currentExtent - lastExtent).abs() < 1.0) {
            stableCount++;
          } else {
            stableCount = 0;
          }

          lastExtent = currentExtent;
          tries++;

          if (stableCount >= requiredStableCount || tries >= maxTries) {
            // 加载完成或超时
            _scrollController.animateTo(
              currentExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
            return;
          }

          poll(); // 继续下一次检测
        }

        poll();
      }
    } catch (e) {
      print('发送消息失败: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    final newKeyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    if (newKeyboardHeight != _keyboardHeight) {
      _keyboardHeight = newKeyboardHeight;
      if (_keyboardHeight > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent);
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
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.01 * width),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
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
                    if (!endConversation && widget.fromQuestion)
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CommentPage(
                                  fromQuestion: widget.fromQuestion,
                                  targetUser: otherUsername,
                                  conversationId: widget.conversationId,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '结束对话',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

// ListView 构建部分
      Expanded(
      child: ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 0.05 * width, vertical: 8),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final isMe = msg['isMe'];
        final avatarUrl = isMe ? _myAvatarUrl : _otherAvatarUrl;
        final content = msg['text'];

        final avatarWidget = (avatarUrl == null || avatarUrl.isEmpty)
            ? Image.asset(
          'assets/img.png',
          width: 32,
          height: 32,
          fit: BoxFit.fill,
        )
            : Image.network(
          avatarUrl,
          width: 32,
          height: 32,
          fit: BoxFit.fill,
          errorBuilder: (_, __, ___) => Image.asset(
            'assets/img.png',
            width: 32,
            height: 32,
            fit: BoxFit.fill,
          ),
        );

        final bubble = Container(
          constraints: BoxConstraints(maxWidth: 0.7 * width),
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isMe ? Colors.purple.shade700 : Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: isImageUrl(content)
              ? Image.network(
            content,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Text('图片加载失败'),
          )
              : Text(
            content,
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
              if (!isMe) ...[
                ClipOval(child: avatarWidget),
                const SizedBox(width: 8),
              ],
              bubble,
              if (isMe) ...[
                const SizedBox(width: 8),
                ClipOval(child: avatarWidget),
              ],
            ],
          ),
        );
      },
    ),
    ),
            !endConversation
                ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.05 * width),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: 0.18 * height,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.purple.shade700,
                          width: 2,
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
                            setState(() {});
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (_scrollController.hasClients) {
                                _scrollController.jumpTo(
                                    _scrollController.position.maxScrollExtent);
                              }
                            });
                          },
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            hintText: '输入消息',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _textController.text.isEmpty
                      ? Ink(
                    decoration: const ShapeDecoration(
                      shape: CircleBorder(),
                      color: Colors.purple,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () => _sendMessage(false),
                    ),
                  )
                      : ElevatedButton(
                    onPressed: () => _sendMessage(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade700,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    child: const Text('发送',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            )
                : Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  '当前对话已经结束~',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                    fontStyle: FontStyle.italic,
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
