import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../style/palette.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import 'user_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final audioController = context.read<AudioController>();
    final userManager = context.read<UserManager>();
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final success = await userManager.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success) {
        audioController.playSfx(SfxType.buttonTap);
        // 登录成功，返回主菜单
        if (context.mounted) {
          context.go('/');
        }
      } else {
        setState(() {
          _errorMessage = '登录失败，请检查邮箱和密码';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '登录过程中发生错误: $e';
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
                '用户登录',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: palette.textColor,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                '登录后可同步游戏数据和排行榜',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: palette.textColor.withValues(alpha: 0.8),
                ),
              ),
              SizedBox(height: 30.h),
              
              // 登录表单
              Expanded(
                child: Column(
                  children: [
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
                    
                    // 登录按钮
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
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
                                '登录',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: palette.backgroundMain,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    
                    // 注册提示
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '还没有账户？',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: palette.textColor,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.push('/register');
                          },
                          child: Text(
                            '立即注册',
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