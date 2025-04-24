import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SettingsPageState();
  }
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;
  bool _isNotificationEnabled = true;
  bool _isAutoPlay = true;
  String _selectedLanguage = '简体中文';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        children: [
          _buildSection(
            title: '通用设置',
            children: [
              _buildSwitchTile(
                icon: Icons.dark_mode,
                title: '深色模式',
                value: _isDarkMode,
                onChanged: (value) {
                  setState(() {
                    _isDarkMode = value;
                  });
                },
              ),
              _buildSwitchTile(
                icon: Icons.notifications,
                title: '消息通知',
                value: _isNotificationEnabled,
                onChanged: (value) {
                  setState(() {
                    _isNotificationEnabled = value;
                  });
                },
              ),
              _buildSwitchTile(
                icon: Icons.play_circle,
                title: '自动播放',
                value: _isAutoPlay,
                onChanged: (value) {
                  setState(() {
                    _isAutoPlay = value;
                  });
                },
              ),
            ],
          ),
          _buildSection(
            title: '语言设置',
            children: [
              _buildLanguageTile(
                title: '简体中文',
                isSelected: _selectedLanguage == '简体中文',
                onTap: () {
                  setState(() {
                    _selectedLanguage = '简体中文';
                  });
                },
              ),
              _buildLanguageTile(
                title: 'English',
                isSelected: _selectedLanguage == 'English',
                onTap: () {
                  setState(() {
                    _selectedLanguage = 'English';
                  });
                },
              ),
            ],
          ),
          _buildSection(
            title: '账号设置',
            children: [
              _buildButtonTile(
                icon: Icons.security,
                title: '账号安全',
                onTap: () {
                  print('进入账号安全设置');
                },
              ),
              _buildButtonTile(
                icon: Icons.privacy_tip,
                title: '隐私设置',
                onTap: () {
                  print('进入隐私设置');
                },
              ),
              _buildButtonTile(
                icon: Icons.help,
                title: '帮助与反馈',
                onTap: () {
                  print('进入帮助与反馈');
                },
              ),
            ],
          ),
          _buildSection(
            title: '关于',
            children: [
              _buildButtonTile(
                icon: Icons.info,
                title: '关于我们',
                onTap: () {
                  print('进入关于我们');
                },
              ),
              _buildButtonTile(
                icon: Icons.description,
                title: '用户协议',
                onTap: () {
                  print('进入用户协议');
                },
              ),
              _buildButtonTile(
                icon: Icons.policy,
                title: '隐私政策',
                onTap: () {
                  print('进入隐私政策');
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('退出登录'),
            ),
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

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(title),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.deepPurple,
        ),
      ),
    );
  }

  Widget _buildLanguageTile({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
        ),
      ),
      child: ListTile(
        leading: const Icon(Icons.language, color: Colors.deepPurple),
        title: Text(title),
        trailing:
            isSelected
                ? const Icon(Icons.check, color: Colors.deepPurple)
                : null,
        onTap: onTap,
      ),
    );
  }

  Widget _buildButtonTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
