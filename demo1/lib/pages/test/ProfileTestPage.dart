import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import '../../models/request_model.dart';

class ProfileTestPage extends StatefulWidget {
  const ProfileTestPage({super.key});

  @override
  State<ProfileTestPage> createState() => _ProfileTestPageState();
}

class _ProfileTestPageState extends State<ProfileTestPage> {
  final UserService _userService = UserService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _introductionController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
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
        ).showSnackBar(const SnackBar(content: Text('更新成功')));
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

  Future<void> _addTag() async {
    if (_tagController.text.isEmpty) return;

    final newTag = _tagController.text.trim();
    if (_tags.contains(newTag)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('标签已存在')));
      return;
    }

    try {
      final request = RequestModel(
        token: '9d83504a-5d28-4dca-a034-374c569e17d0',
        username: 'wjy',
      );

      final newTags = [..._tags, newTag];

      await _userService.updateUserTags(
        username: _userInfo?['username'] ?? '',
        tags: newTags,
      );

      UserService.clearCache();

      setState(() {
        _tags = newTags;
        _tagController.clear();
      });

      await _loadUserInfo();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('标签添加成功')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('添加标签失败：$e')));
    }
  }

  Future<void> _removeTag(String tag) async {
    try {
      final request = RequestModel(
        token: '9d83504a-5d28-4dca-a034-374c569e17d0',
        username: 'wjy',
      );

      final newTags = _tags.where((t) => t != tag).toList();

      await _userService.updateUserTags(
        username: _userInfo?['username'] ?? '',
        tags: newTags,
      );

      UserService.clearCache();

      setState(() {
        _tags = newTags;
      });

      await _loadUserInfo();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('标签删除成功')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('删除标签失败：$e')));
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
      appBar: AppBar(title: const Text('个人资料测试')),
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
                    const Text(
                      '标签:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        ..._tags.map(
                          (tag) => Chip(
                            label: Text(tag),
                            onDeleted: () => _removeTag(tag),
                            deleteIcon: const Icon(Icons.close, size: 18),
                          ),
                        ),
                      ],
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
                      '添加标签',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _tagController,
                            decoration: const InputDecoration(
                              labelText: '新标签',
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (_) => _addTag(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _addTag,
                          child: const Text('添加'),
                        ),
                      ],
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

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _introductionController.dispose();
    _tagController.dispose();
    super.dispose();
  }
}
