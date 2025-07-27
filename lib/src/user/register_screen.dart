import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../style/palette.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import 'user_manager.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final audioController = context.read<AudioController>();
    final userManager = context.read<UserManager>();
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // 验证输入
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = '两次输入的密码不一致';
        _isLoading = false;
      });
      return;
    }

    if (_passwordController.text.length < 6) {
      setState(() {
        _errorMessage = '密码长度至少为6位';
        _isLoading = false;
      });
      return;
    }

    try {
      final success = await userManager.register(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );

      if (success) {
        audioController.playSfx(SfxType.buttonTap);
        // 注册成功，返回主菜单
        if (context.mounted) {
          context.go('/');
        }
      } else {
        setState(() {
          _errorMessage = '注册失败，请稍后重试';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '注册过程中发生错误: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return Scaffold(
      backgroundColor: palette.backgroundMain,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 返回按钮
              IconButton(
                icon: Icon(Icons.arrow_back, color: palette.textColor),
                onPressed: () => context.pop(),
              ),
              SizedBox(height: 20.h),
              
              // 标题
              Text(
                '用户注册',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: palette.textColor,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                '注册后可同步游戏数据和排行榜',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: palette.textColor.withValues(alpha: 0.8),
                ),
              ),
              SizedBox(height: 30.h),
              
              // 注册表单
              Expanded(
                child: Column(
                  children: [
                    // 用户名输入
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: palette.backgroundMenu.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: TextField(
                        controller: _nameController,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: palette.textColor,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '用户名',
                          hintStyle: TextStyle(
                            fontSize: 16.sp,
                            color: palette.textColor.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    
                    // 邮箱输入
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: palette.backgroundMenu.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: TextField(
                        controller: _emailController,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: palette.textColor,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '邮箱',
                          hintStyle: TextStyle(
                            fontSize: 16.sp,
                            color: palette.textColor.withValues(alpha: 0.5),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    
                    // 密码输入
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: palette.backgroundMenu.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: TextField(
                        controller: _passwordController,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: palette.textColor,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '密码',
                          hintStyle: TextStyle(
                            fontSize: 16.sp,
                            color: palette.textColor.withValues(alpha: 0.5),
                          ),
                        ),
                        obscureText: true,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    
                    // 确认密码输入
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: palette.backgroundMenu.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: TextField(
                        controller: _confirmPasswordController,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: palette.textColor,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '确认密码',
                          hintStyle: TextStyle(
                            fontSize: 16.sp,
                            color: palette.textColor.withValues(alpha: 0.5),
                          ),
                        ),
                        obscureText: true,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    
                    // 错误信息显示
                    if (_errorMessage.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          _errorMessage,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    SizedBox(height: 20.h),
                    
                    // 注册按钮
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: palette.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(palette.backgroundMain),
                              )
                            : Text(
                                '注册',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: palette.backgroundMain,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    
                    // 登录提示
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '已有账户？',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: palette.textColor,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.push('/login');
                          },
                          child: Text(
                            '立即登录',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: palette.primaryColor,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}