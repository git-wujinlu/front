import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:demo1/providers/theme_provider.dart';
import 'package:demo1/services/user_service.dart';
import 'package:demo1/models/request_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:demo1/constants/api_constants.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SettingsPageState();
  }
}

class _SettingsPageState extends State<SettingsPage> {
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
              onPressed: () async {
                print('用户点击退出登录按钮');

                // 显示加载指示器
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );

                try {
                  // 使用完全清理方法
                  await _clearAllCacheAndLogout();

                  if (!mounted) return;

                  // 关闭加载指示器
                  Navigator.pop(context);

                  // 跳转到登录页
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                } catch (e) {
                  print('退出登录过程中出错: $e');

                  if (!mounted) return;

                  // 关闭加载指示器
                  Navigator.pop(context);

                  // 仍然尝试跳转到登录页
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
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
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Theme.of(context).cardTheme.color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            '修改密码',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _oldPasswordController,
                decoration: InputDecoration(
                  labelText: '旧密码',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                obscureText: true,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: '新密码',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                obscureText: true,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: '确认新密码',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                obscureText: true,
                enabled: !_isLoading,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      Navigator.of(context).pop();
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
              onPressed: _isLoading
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
                        print('==== 密码修改操作开始 ====');
                        final prefs = await SharedPreferences.getInstance();
                        final token = prefs.getString('token');
                        final username = prefs.getString('username');

                        if (username == null) {
                          throw Exception('未找到登录用户信息，请重新登录后再修改密码');
                        }

                        print('修改密码用户: $username');
                        print('Token可用性: ${token != null ? '有效' : '无效'}');

                        // 保存新旧密码
                        final oldPasswordValue = _oldPasswordController.text;
                        final newPasswordValue = _newPasswordController.text;

                        final request = RequestModel(
                          token: token,
                          username: username,
                        );

                        // 第一步：修改密码API调用
                        print('步骤1: 调用修改密码API...');
                        final result = await _userService
                            .updatePassword(
                          oldPassword: oldPasswordValue,
                          newPassword: newPasswordValue,
                          request: request,
                        )
                            .timeout(
                          const Duration(seconds: 20),
                          onTimeout: () {
                            throw Exception('请求超时，请稍后再试');
                          },
                        );

                        if (!mounted) return;

                        print('密码修改API返回: $result');

                        // 第二步：执行双重验证，确保修改成功
                        // 添加延迟，确保服务器有时间处理密码更改
                        print('步骤2: 等待服务器处理...');
                        await Future.delayed(Duration(seconds: 2));

                        // 第三步：先直接调用服务器登出接口，强制重置会话状态
                        print('步骤3: 强制重置服务器会话状态...');

                        try {
                          // 获取当前Token和用户名
                          final token = prefs.getString('token');

                          // 直接调用服务器端登出API
                          final logoutResponse = await http.post(
                            Uri.parse(
                                '${ApiConstants.baseUrl}${ApiConstants.logout}'),
                            headers: {
                              'username': username,
                              'token': token ?? '',
                              'Content-Type': 'application/json',
                            },
                          );

                          print('服务器登出响应: ${logoutResponse.statusCode}');
                          if (logoutResponse.statusCode == 200) {
                            print('服务器会话重置成功');
                          } else {
                            print(
                                '服务器会话重置可能不成功，状态码: ${logoutResponse.statusCode}');
                          }

                          // 额外尝试：重新获取验证码，进一步强制刷新服务器会话
                          try {
                            print('尝试获取新验证码，强制刷新服务器会话...');
                            await _userService.captcha();
                            print('验证码获取成功，有助于刷新会话状态');
                          } catch (e) {
                            print('获取验证码失败，但不影响主流程: $e');
                          }
                        } catch (e) {
                          print('调用服务器登出API出错: $e');
                          // 继续流程，不中断
                        }

                        // 第四步：清除本地状态，准备验证
                        print('步骤4: 清除本地状态...');
                        Navigator.of(context).pop(); // 关闭对话框

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('密码修改成功，正在退出登录...')),
                        );

                        // 记录密码修改后的关键信息，以便在登录页面使用
                        await prefs.setString(
                            'last_modified_username', username);
                        await prefs.setString(
                            'last_modified_password', newPasswordValue);

                        print('执行完全清理和登出操作...');
                        // 使用更全面的清理方法
                        await _clearAllCacheAndLogout();

                        // 确保用户需要使用新密码登录
                        print('跳转到登录页面...');
                        if (!mounted) return;

                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
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
              child: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    )
                  : Text(
                      '确认',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
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
          crossFadeState: _isSecurityExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }

  // 彻底清除缓存并登出
  Future<void> _clearAllCacheAndLogout() async {
    try {
      print('==== 开始清除所有缓存并登出 ====');

      // 获取当前信息用于日志
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username');
      print('当前用户: $username');

      // 1. 清除所有SharedPreferences数据
      print('正在清除SharedPreferences...');
      await prefs.clear();

      // 2. 清除UserService静态缓存
      print('正在清除UserService缓存...');
      UserService.clearCache();

      // 3. 调用登出方法，确保所有状态被清除
      print('执行登出方法...');
      final _userService = UserService();
      await _userService.logout();

      print('所有缓存已清除，准备退出');
      print('==== 缓存清理完成 ====');
    } catch (e) {
      print('清除缓存过程中出错: $e');
      // 出错时进行基本清理
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        await prefs.remove('username');
      } catch (_) {}
    }
  }
}
