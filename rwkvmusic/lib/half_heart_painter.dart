import 'package:flutter/material.dart';
import 'package:rwkvmusic/style/color.dart';
import 'package:rwkvmusic/values/values.dart';

class HalfHeartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppColor.color_DE2424 // 设置边框颜色为红色
      ..style = PaintingStyle.stroke // 设置为空心（只绘制边框）
      ..strokeWidth = 4; // 设置边框宽度

    // 设置圆心坐标
    Offset center = Offset(size.width / 2, size.height / 2);

    // 绘制半径为78的空心圆
    canvas.drawCircle(center, 40, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
