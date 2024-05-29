import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rwkvmusic/style/color.dart';

class TextTitle extends StatelessWidget {
  const TextTitle({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 60.sp,
        fontWeight: FontWeight.w700,
        color: AppColor.color_757575,
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
