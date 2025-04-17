import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rwkvmusic/style/color.dart';

class TextItem extends StatelessWidget {
  TextItem(
      {super.key,
      required this.text,
      this.fontSize,
      this.fontWeight,
      this.linearColor});
  final String text;
  double? fontSize;
  FontWeight? fontWeight;
  List<Color>? linearColor;
  @override
  Widget build(BuildContext context) {
    bool isWindowsOrMac = Platform.isWindows || Platform.isMacOS;
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize ?? (isWindowsOrMac ? 45.sp : 40.sp),
        fontWeight: fontWeight ?? FontWeight.w400,
        foreground: Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF999999), // #FFFFFF
              const Color(0xFF999999), // #999999
            ],
          ).createShader(Rect.zero), // 你可以根据文本宽高自行调节
        shadows: const [
          // Drop Shadow
          Shadow(
            offset: Offset(0, 2),
            blurRadius: 1,
            color: Color.fromRGBO(0, 0, 0, 0.25), // 黑色 25%
          ),
          // Inner shadow (simulated)
          Shadow(
            offset: Offset(0, 1),
            blurRadius: 0.5,
            color: Color.fromRGBO(255, 255, 255, 0.86), // 白色 86%
          ),
          Shadow(
            offset: Offset(0, -1),
            blurRadius: 0.5,
            color: Color.fromRGBO(0, 0, 0, 0.25), // 黑色 25%
          ),
        ],
      ),
    );
  }
}
