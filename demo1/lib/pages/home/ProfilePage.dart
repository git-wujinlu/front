import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ProfilePageState();
  }
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController(
    text: '陈某某',
  );
  final TextEditingController _schoolController = TextEditingController(
    text: '北京航空航天大学',
  );
  final TextEditingController _majorController = TextEditingController(
    text: '计算机科学与技术',
  );
  final TextEditingController _gradeController = TextEditingController(
    text: '大三',
  );
  final TextEditingController _bioController = TextEditingController(
    text: '热爱编程，喜欢探索新技术',
  );

  @override
  void dispose() {
    _nameController.dispose();
    _schoolController.dispose();
    _majorController.dispose();
    _gradeController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人资料'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          TextButton(
            onPressed: () {
              // 保存个人资料
              print('保存个人资料');
            },
            child: const Text(
              '保存',
              style: TextStyle(color: Colors.deepPurple, fontSize: 16),
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
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                        'https://via.placeholder.com/150',
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple,
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
                const SizedBox(height: 8),
                const Text(
                  '点击更换头像',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
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
                icon: Icons.school,
                label: '学校',
                controller: _schoolController,
              ),
              _buildTextField(
                icon: Icons.book,
                label: '专业',
                controller: _majorController,
              ),
              _buildTextField(
                icon: Icons.grade,
                label: '年级',
                controller: _gradeController,
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
                    _buildTag('算法'),
                    _buildTag('机器学习'),
                    _buildTag('Python'),
                    _buildTag('Web 开发'),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
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
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: Colors.deepPurple),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: controller,
                maxLines: maxLines,
                decoration: InputDecoration(
                  labelText: label,
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(color: Colors.deepPurple, fontSize: 14),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.close, size: 16, color: Colors.deepPurple),
        ],
      ),
    );
  }

  Widget _buildAddTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.deepPurple),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add, size: 16, color: Colors.deepPurple),
          SizedBox(width: 4),
          Text(
            '添加标签',
            style: TextStyle(color: Colors.deepPurple, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
