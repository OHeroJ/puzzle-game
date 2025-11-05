import 'package:flutter/material.dart';

class JigsawGridPainter extends CustomPainter {
  final Color backgroundColor;
  final int gridSize;
  final Color lineColor;

  JigsawGridPainter({
    required this.backgroundColor,
    required this.gridSize,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = backgroundColor;
    canvas.drawRect(Offset.zero & size, bgPaint);

    if (gridSize <= 1) return;

    final linePaint = Paint()
      ..color = lineColor.withOpacity(0.2)
      ..strokeWidth = 1.0;

    final dx = size.width / gridSize;
    final dy = size.height / gridSize;

    // vertical lines
    for (int i = 1; i < gridSize; i++) {
      final x = dx * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }

    // horizontal lines
    for (int i = 1; i < gridSize; i++) {
      final y = dy * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant JigsawGridPainter oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.gridSize != gridSize ||
        oldDelegate.lineColor != lineColor;
  }
}