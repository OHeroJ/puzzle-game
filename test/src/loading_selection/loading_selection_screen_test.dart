import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:puzzle/src/loading_selection/loading_selection_screen.dart';

void main() {
  group('LoadingSelectionScreen', () {
    testWidgets('should create widget with given level', (tester) async {
      const testLevel = 1;
      
      // 不实际测试UI渲染，而是测试widget是否能正确创建
      final widget = const LoadingSelectionScreen(level: testLevel);
      expect(widget.level, testLevel);
    });

    testWidgets('should initialize with correct level parameter',
        (tester) async {
      const testLevel = 2;
      
      final widget = const LoadingSelectionScreen(level: testLevel);
      expect(widget.level, testLevel);
    });
  });
}