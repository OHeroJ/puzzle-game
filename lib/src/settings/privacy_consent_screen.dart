import 'dart:io' show exit;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../style/palette.dart';
// Removed unused imports to keep analysis clean.
import '../utils/sp_util.dart';
import 'package:go_router/go_router.dart';

class PrivacyConsentScreen extends StatelessWidget {
  const PrivacyConsentScreen({super.key});

  static const String _spKey = 'privacyAccepted';

  Future<void> _openPolicy() async {
    final url = Uri.parse('https://oldbird.run/puzzle-sec-hw.html');
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Future<void> _accept(BuildContext context) async {
    await SpUtil().setBool(_spKey, true);
    if (context.mounted) {
      GoRouter.of(context).go('/');
    }
  }

  void _decline() {
    if (kIsWeb) {
      // Web 无法退出应用，退回空页面。
      // 可根据需要改为提示无法继续使用。
    } else {
      try {
        SystemNavigator.pop();
      } catch (_) {
        exit(0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return Scaffold(
      backgroundColor: palette.backgroundMain,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: palette.backgroundMain.withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: palette.textColor.withOpacity(0.2)),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '隐私政策',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: palette.textColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '为保障您的合法权益。请您详细阅读并同意后继续使用。您可点击下方“查看完整隐私政策”。',
                style: TextStyle(
                    fontSize: 16, color: palette.textColor.withOpacity(0.85)),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _openPolicy,
                child: const Text('查看完整隐私政策'),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _decline,
                    style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent),
                    child: const Text('不同意并退出'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => _accept(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: palette.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('同意并继续'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
