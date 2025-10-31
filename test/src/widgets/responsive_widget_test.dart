import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle/src/widgets/responsive_widget.dart';

void main() {
  group('ResponsiveWidget', () {
    testWidgets('should show mobileBody when screen width is <= 800',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveWidget(
            desktopBody: const Scaffold(body: Text('Desktop')),
            mobileBody: const Scaffold(body: Text('Mobile')),
          ),
        ),
      );

      // 验证默认情况下显示mobileBody（因为测试屏幕宽度小于800）
      expect(find.text('Mobile'), findsOneWidget);
      expect(find.text('Desktop'), findsNothing);
    });

    testWidgets('should show desktopBody when screen width is > 800',
        (tester) async {
      // 使用更大的屏幕尺寸测试
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveWidget(
            desktopBody: const Scaffold(body: Text('Desktop')),
            mobileBody: const Scaffold(body: Text('Mobile')),
          ),
        ),
      );

      // 验证在大屏幕上显示desktopBody
      expect(find.text('Desktop'), findsOneWidget);
      expect(find.text('Mobile'), findsNothing);
    });
  });
}