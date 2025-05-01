import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import '../../models/request_model.dart';
import '../home/ProfilePage.dart';
import '../home/SelfPage.dart';

class ProfileSyncTestPage extends StatefulWidget {
  const ProfileSyncTestPage({super.key});

  @override
  State<ProfileSyncTestPage> createState() => _ProfileSyncTestPageState();
}

class _ProfileSyncTestPageState extends State<ProfileSyncTestPage> {
  final UserService _userService = UserService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _introductionController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _newTagController = TextEditingController();
  List<String> _tags = [];

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _userInfo;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final request = RequestModel(
        token: '9d83504a-5d28-4dca-a034-374c569e17d0',
        username: 'wjy',
      );

      final userResponse = await _userService.getUserByUsername();
      final userData = userResponse['data'];

      final tagsString = userData['tags'] as String? ?? '';
      final tagsList =
          tagsString.isNotEmpty
              ? tagsString.split(',').map((e) => e.trim()).toList()
              : <String>[];

      setState(() {
        _userInfo = userData;
        _tags = tagsList;
        _usernameController.text = userData['username'] ?? '';
        _phoneController.text = userData['phone'] ?? '';
        _introductionController.text = userData['introduction'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final request = RequestModel(
        token: '9d83504a-5d28-4dca-a034-374c569e17d0',
        username: 'wjy',
      );

      final response = await _userService.updateUserProfile(
        oldUsername: _userInfo?['username'] ?? '',
        newUsername: _usernameController.text,
        phone: _phoneController.text,
        introduction: _introductionController.text,
      );

      setState(() {
        _userInfo = response['data'];
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('更新成功，请检查其他页面')));
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('更新失败: $e')));
      }
    }
  }

  void _addTag() {
    print('开始添加标签');
    if (_newTagController.text.isEmpty) {
      print('标签为空');
      return;
    }

    final newTag = _newTagController.text.trim();
    if (_tags.contains(newTag)) {
      print('标签已存在');
      return;
    }

    setState(() {
      _tags.add(newTag);
      _newTagController.clear();
    });
    print('标签已添加到列表: $newTag');
    print('当前标签列表: $_tags');
  }

  void _removeTag(String tag) {
    print('开始删除标签: $tag');
    setState(() {
      _tags.remove(tag);
    });
    print('标签已删除');
    print('当前标签列表: $_tags');
  }

  Future<void> _saveTags() async {
    print('开始保存标签');
    try {
      final result = await _userService.updateUserTags(
        username: _userInfo?['username'] ?? '',
        tags: _tags,
      );
      print('标签保存响应: $result');

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('标签更新成功')));
        await _loadUserInfo();
      }
    } catch (e) {
      print('标签保存失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('标签更新失败: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadUserInfo, child: const Text('重试')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('数据同步测试'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              UserService.clearCache();
              _loadUserInfo();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '当前用户信息',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('用户名: ${_userInfo?['username']}'),
                    Text('手机号: ${_userInfo?['phone']}'),
                    Text('简介: ${_userInfo?['introduction']}'),
                    const SizedBox(height: 8),
                    _buildTagsSection(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '修改用户信息',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: '用户名',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: '手机号',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _introductionController,
                      decoration: const InputDecoration(
                        labelText: '个人简介',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _updateProfile,
                      child: const Text('保存修改'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '测试其他页面',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfilePage(),
                          ),
                        );
                      },
                      child: const Text('打开个人资料页面'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SelfPage(),
                          ),
                        );
                      },
                      child: const Text('打开个人中心页面'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '标签',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _tags
                  .map(
                    (tag) => Chip(
                      label: Text(tag),
                      onDeleted: () => _removeTag(tag),
                      deleteIcon: const Icon(Icons.close, size: 18),
                    ),
                  )
                  .toList(),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _newTagController,
                decoration: const InputDecoration(
                  labelText: '新标签',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(onPressed: _addTag, child: const Text('添加')),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: _saveTags, child: const Text('保存标签')),
      ],
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _introductionController.dispose();
    _tagController.dispose();
    _newTagController.dispose();
    super.dispose();
  }
}
