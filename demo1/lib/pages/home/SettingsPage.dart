import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:demo1/providers/theme_provider.dart';
import 'package:demo1/services/user_service.dart';
import 'package:demo1/models/request_model.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SettingsPageState();
  }
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isNotificationEnabled = true;
  bool _isSecurityExpanded = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
      ),
      body: ListView(
        children: [
          _buildSection(
            title: '通用设置',
            children: [
              _buildSwitchTile(
                icon: Icons.dark_mode,
                title: '深色模式',
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme();
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
            ],
          ),
          _buildSection(
            title: '账号设置',
            children: [
              _buildSecurityTile(),
              _buildButtonTile(
                icon: Icons.policy,
                title: '隐私政策',
                onTap: () {
                  print('进入隐私政策');
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
            ],
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
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
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.6),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
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
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).primaryColor,
        ),
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
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Theme.of(
            context,
          ).textTheme.bodyMedium?.color?.withOpacity(0.5),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSecurityItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final _oldPasswordController = TextEditingController();
    final _newPasswordController = TextEditingController();
    final _confirmPasswordController = TextEditingController();
    final _userService = UserService();
    bool _isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: const Text('修改密码'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _oldPasswordController,
                        decoration: const InputDecoration(
                          labelText: '旧密码',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _newPasswordController,
                        decoration: const InputDecoration(
                          labelText: '新密码',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _confirmPasswordController,
                        decoration: const InputDecoration(
                          labelText: '确认新密码',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        enabled: !_isLoading,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed:
                          _isLoading
                              ? null
                              : () {
                                Navigator.of(context).pop();
                              },
                      child: const Text('取消'),
                    ),
                    TextButton(
                      onPressed:
                          _isLoading
                              ? null
                              : () async {
                                // 只检查新密码是否一致
                                if (_newPasswordController.text !=
                                    _confirmPasswordController.text) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('两次输入的新密码不一致'),
                                    ),
                                  );
                                  return;
                                }

                                // 检查新密码是否为空
                                if (_newPasswordController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('新密码不能为空')),
                                  );
                                  return;
                                }

                                setDialogState(() {
                                  _isLoading = true;
                                });

                                try {
                                  final request = Request(
                                    token:
                                        '9d83504a-5d28-4dca-a034-374c569e17d0',
                                    username: 'wjy',
                                  );

                                  final result = await _userService
                                      .updatePassword(
                                        oldPassword:
                                            _oldPasswordController.text,
                                        newPassword:
                                            _newPasswordController.text,
                                        request: request,
                                      )
                                      .timeout(
                                        const Duration(seconds: 10),
                                        onTimeout: () {
                                          throw Exception('请求超时，请重试');
                                        },
                                      );

                                  if (!mounted) return;

                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('密码修改成功')),
                                  );
                                } catch (e) {
                                  if (!mounted) return;

                                  print('密码修改错误: $e');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('密码修改失败：$e')),
                                  );
                                  setDialogState(() {
                                    _isLoading = false;
                                  });
                                }
                              },
                      child:
                          _isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('确认'),
                    ),
                  ],
                ),
          ),
    );
  }

  Widget _buildSecurityTile() {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.security, color: Theme.of(context).primaryColor),
          title: Text(
            '账号安全',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          trailing: Icon(
            _isSecurityExpanded
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down,
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withOpacity(0.5),
          ),
          onTap: () {
            setState(() {
              _isSecurityExpanded = !_isSecurityExpanded;
            });
          },
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSecurityItem(
                  icon: Icons.lock,
                  title: '修改密码',
                  onTap: _showChangePasswordDialog,
                ),
              ],
            ),
          ),
          crossFadeState:
              _isSecurityExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }
}
