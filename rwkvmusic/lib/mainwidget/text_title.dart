import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rwkvmusic/style/color.dart';

class TextTitle extends StatelessWidget {
  TextTitle({super.key, required this.text, this.fontSize, this.fontWeight});
  final String text;
  double? fontSize;
  FontWeight? fontWeight;
  Color? color;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize ?? 60.sp,
        fontWeight: fontWeight ?? FontWeight.w700,
        color: color ?? AppColor.color_757575,
        shadows: [
          BoxShadow(
            color: Colors.white.withOpacity(.4),
            blurRadius: 0.5,
            spreadRadius: 0,
            offset: const Offset(
              0.0,
              -1,
            ),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(.5),
            blurRadius: 0.5,
            spreadRadius: 0,
            offset: const Offset(
              0.0,
              1,
            ),
          ),
        ],
      ),
    );
  }
}
