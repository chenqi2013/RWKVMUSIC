import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rwkvmusic/style/color.dart';

class TextBtn extends StatelessWidget {
  TextBtn(
      {super.key,
      required this.width,
      required this.height,
      required this.text,
      required this.onPressed,
      this.textColor});
  final double width;
  final double height;
  final String text;
  final VoidCallback onPressed;
  Color? textColor;
  @override
  Widget build(BuildContext context) {
    bool isWindowsOrMac = Platform.isWindows || Platform.isMacOS;
    return InkWell(
        onTap: () {
          // 按钮被点击时执行的操作
          onPressed();
        },
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColor.color_494949, AppColor.color_323232]),
            borderRadius: BorderRadius.circular(11.h),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(.2),
                blurRadius: 1.18,
                spreadRadius: 0,
                offset: const Offset(
                  0.0,
                  -2.36,
                ),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(.42),
                blurRadius: 1.18,
                spreadRadius: 0,
                offset: const Offset(
                  0.0,
                  2.36,
                ),
              ),
            ],
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontSize: isWindowsOrMac ? 39.sp : 33.sp,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ));
  }
}
