import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rwkvmusic/style/color.dart';

class TextItem extends StatelessWidget {
  const TextItem({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 45.sp,
        fontWeight: FontWeight.w400,
        // color: Colors.white,
        foreground: Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColor.color_ffffff,
              AppColor.color_999999,
            ],
          ).createShader(Rect.zero),
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(.25),
            blurRadius: 1,
            spreadRadius: 0,
            offset: const Offset(
              0.0,
              2,
            ),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(.86),
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
