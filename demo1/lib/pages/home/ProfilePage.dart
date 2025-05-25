import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/user_service.dart';
import '../../models/request_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ProfilePageState();
  }
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService _userService = UserService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _userInfo;
  String? _oldUsername;
  List<String> _tags = [];
  final TextEditingController _tagController = TextEditingController();
  String? _avatarUrl;
  File? _selectedImage;

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
      final response = await _userService.getUserByUsername();
      final userData = response['data'];

      final tagsString = userData['tags'] as String? ?? '';
      final tagsList = tagsString.isNotEmpty
          ? tagsString.split(',').map((e) => e.trim()).toList()
          : <String>[];

      setState(() {
        _userInfo = userData;
        _oldUsername = userData['username'];
        _nameController.text = userData['username'] ?? '';
        _phoneController.text = userData['phone'] ?? '';
        _bioController.text = userData['introduction'] ?? '';
        _tags = tagsList;
        _avatarUrl = userData['avatar'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800, // 限制图片最大宽度
        maxHeight: 800, // 限制图片最大高度
        imageQuality: 85, // 压缩图片质量
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      } else {
        // 用户取消选择，不做任何处理
        print('用户取消选择图片');
      }
    } catch (e) {
      print('选择图片失败: $e'); // 添加错误日志
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择图片失败：$e')),
        );
      }
    }
  }

  void _addTag() {
    if (_tagController.text.isEmpty) return;

    final newTag = _tagController.text.trim();
    if (_tags.contains(newTag)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('标签已存在')),
      );
      return;
    }

    setState(() {
      _tags.add(newTag);
      _tagController.clear();
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

  Future<void> _saveUserInfo() async {
    if (_isLoading) return; // 防止重复保存

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      print('开始保存用户信息'); // 添加调试日志

      // 先更新用户基本信息
      final result = await _userService.updateUserProfile(
        oldUsername: _oldUsername ?? '',
        newUsername: _nameController.text,
        phone: _phoneController.text,
        introduction: _bioController.text,
        avatar: _selectedImage?.path ?? _avatarUrl,
      );

      print('用户基本信息更新成功: $result'); // 添加调试日志

      // 再更新标签
      await _userService.updateUserTags(
        username: _oldUsername ?? '',
        tags: _tags,
      );

      print('标签更新成功'); // 添加调试日志

      // 清除缓存以强制刷新数据
      UserService.clearCache();

      // 强制刷新一次用户信息，确保标签和后端一致
      final refreshed = await _userService.getUserByUsername();
      final refreshedData = refreshed['data'];
      final refreshedTagsString = refreshedData['tags'] as String? ?? '';
      final refreshedTagsList = refreshedTagsString.isNotEmpty
          ? refreshedTagsString
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList()
          : <String>[];

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存成功')),
      );

      // 更新本地状态
      setState(() {
        _userInfo = refreshedData;
        _oldUsername = refreshedData['username'];
        _avatarUrl = refreshedData['avatar'];
        _tags = refreshedTagsList;
        _selectedImage = null;
      });

      print('刷新后的标签列表: $_tags'); // 添加调试日志

      Navigator.pop(context, true);
    } catch (e) {
      print('保存用户信息失败: $e'); // 添加错误日志
      if (!mounted) return;

      setState(() {
        _error = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
        title: const Text('个人资料'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: Theme.of(context).iconTheme,
        actions: [
          TextButton(
            onPressed: _saveUserInfo,
            child: Text(
              '保存',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          // 头像部分
          Container(
            margin: const EdgeInsets.all(16),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : (_avatarUrl != null
                                    ? NetworkImage(_avatarUrl!)
                                    : const AssetImage('assets/img.png'))
                                as ImageProvider,
                        backgroundColor: Theme.of(
                          context,
                        ).primaryColor.withOpacity(0.2),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '点击更换头像',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // 基本信息部分
          _buildSection(
            title: '基本信息',
            children: [
              _buildTextField(
                icon: Icons.person,
                label: '姓名',
                controller: _nameController,
              ),
              _buildTextField(
                icon: Icons.phone,
                label: '手机号',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          // 个人简介部分
          _buildSection(
            title: '个人简介',
            children: [
              _buildTextField(
                icon: Icons.description,
                label: '简介',
                controller: _bioController,
                maxLines: 3,
              ),
            ],
          ),
          // 标签部分
          _buildSection(
            title: '我的标签',
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._tags.map((tag) => _buildTag(tag)),
                    _buildAddTag(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color:
                Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
          ),
          labelText: label,
          labelStyle: TextStyle(
            color:
                Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).dividerColor,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Chip(
      label: Text(
        tag,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
      backgroundColor: Theme.of(context).cardTheme.color,
      onDeleted: () {
        _removeTag(tag);
      },
      deleteIcon: Icon(
        Icons.close,
        size: 18,
        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
      ),
    );
  }

  Widget _buildAddTag() {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Theme.of(context).cardTheme.color,
              title: Text(
                '添加标签',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              content: TextField(
                controller: _tagController,
                decoration: InputDecoration(
                  labelText: '标签名称',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelStyle: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.6),
                  ),
                ),
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    '取消',
                    style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(0.6),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _addTag();
                    Navigator.pop(context);
                  },
                  child: Text(
                    '添加',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
      child: Chip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add,
              size: 18,
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(0.6),
            ),
            const SizedBox(width: 4),
            Text(
              '添加标签',
              style: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.6),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).cardTheme.color,
        deleteIcon: const SizedBox.shrink(),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _tagController.dispose();
    super.dispose();
  }
}
