import 'package:english_app/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import '../../data/auth_service.dart';
import 'package:english_app/core/widgets/my_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authService = AuthService();

  String _userName = '';
  String _userEmail = '';
  bool _isLoading = true;

  // Controllers cho form đổi tên
  final TextEditingController _nameController = TextEditingController();

  // Controllers cho form đổi mật khẩu
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _passwordFormKey = GlobalKey<FormState>();

  bool _isChangingName = false;
  bool _isChangingPassword = false;
  bool _isEditingName = false; // Thêm state để quản lý việc chỉnh sửa tên

  // Visibility states for password fields
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        setState(() {
          _userEmail = user['email'] ?? '';
          _userName = user['name'] ?? user['email'] ?? '';
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên')),
      );
      return;
    }

    setState(() {
      _isChangingName = true;
    });

    try {
      // Cập nhật tên người dùng cần được triển khai trên backend.
      // Hiện tại tạm thời cập nhật local state và hiển thị thông báo.
      setState(() {
        _userName = newName;
        _isEditingName = false;
      });
      _nameController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tên đã được cập nhật (local). Hãy cập nhật API backend để lưu thay đổi).')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
      }
    } finally {
      setState(() {
        _isChangingName = false;
      });
    }
  }

  void _toggleNameEditing() {
    if (_isEditingName) {
      // Nếu đang chỉnh sửa, lưu thay đổi
      _updateUserName();
    } else {
      // Nếu chưa chỉnh sửa, bắt đầu chỉnh sửa
      setState(() {
        _isEditingName = true;
        _nameController.text = _userName;
      });
    }
  }

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    setState(() {
      _isChangingPassword = true;
    });

    try {
      // Đổi mật khẩu cần endpoint backend riêng (vì hiện tại dùng JWT).
      // Hiện tại chưa có API, hiển thị thông báo.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đổi mật khẩu chưa được hỗ trợ trên client — cần API backend.')),
      );
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Mật khẩu cũ không chính xác';
        if (e.toString().contains('wrong-password')) {
          errorMessage = 'Mật khẩu cũ không đúng';
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } finally {
      setState(() {
        _isChangingPassword = false;
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        // Điều hướng đến LoginScreen và xóa tất cả các màn hình trước đó
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi đăng xuất: ${e.toString()}')),
        );
      }
    }
  }

  Widget _buildUserInfoSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20,vertical: 40),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin cá nhân',
              style: TextStyle(color: Colors.white,fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.person, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tên:',
                        style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500),
                      ),
                      _isEditingName 
                        ? TextField(
                            controller: _nameController,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                            decoration: const InputDecoration(
                              hintText: 'Nhập tên mới',
                              hintStyle: TextStyle(color: Colors.grey),
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.purple),
                              ),
                            ),
                          )
                        : Text(_userName, style: const TextStyle(color:Colors.white,fontSize: 16)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _isChangingName ? null : _toggleNameEditing,
                  icon: _isChangingName 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(
                        _isEditingName ? Icons.check : Icons.edit,
                        color: Colors.white,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.email,color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Email:',
                        style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500),
                      ),
                      Text(_userEmail, style: const TextStyle(color: Colors.white,fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: MyButton(
            data: 'Đổi mật khẩu',
            borderColor: Colors.transparent,
            backgroundColor: Colors.white24,
            textColor: Colors.white,
            onTap: () => _showChangePasswordDialog(),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: MyButton(
            data: 'Đăng xuất',
            backgroundColor: Colors.white24,
            borderColor: Colors.transparent,
            textColor: Colors.white,
            onTap: _signOut,
          ),
        ),
      ],
    );
  }


  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Đổi mật khẩu'),
          content: Form(
            key: _passwordFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              TextFormField(
                controller: _oldPasswordController,
                obscureText: !_isOldPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu cũ',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isOldPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                     onPressed: () {
                       setDialogState(() {
                         _isOldPasswordVisible = !_isOldPasswordVisible;
                       });
                     },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu cũ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu mới',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isNewPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                     onPressed: () {
                       setDialogState(() {
                         _isNewPasswordVisible = !_isNewPasswordVisible;
                       });
                     },
                  ),
                ),
                obscureText: !_isNewPasswordVisible,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu mới';
                  }
                  if (value.length < 6) {
                    return 'Mật khẩu phải có ít nhất 6 ký tự';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Xác nhận mật khẩu mới',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                     onPressed: () {
                       setDialogState(() {
                         _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                       });
                     },
                  ),
                ),
                obscureText: !_isConfirmPasswordVisible,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng xác nhận mật khẩu';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Mật khẩu xác nhận không khớp';
                  }
                  return null;
                },
              ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: _isChangingPassword ? null : _changePassword,
              child: _isChangingPassword
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Đổi mật khẩu'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF261543), Colors.black],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Cài đặt'),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildUserInfoSection(),
              _buildActionButtons(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
