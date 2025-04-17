import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rwkvmusic/main.dart';
import 'package:rwkvmusic/style/color.dart';

class BorderBottomBtn extends StatelessWidget {
  BorderBottomBtn(
      {super.key,
      this.width,
      this.padding,
      required this.height,
      required this.text,
      required this.icon,
      required this.onPressed,
      this.textColor});
  double? width;
  double? padding;
  final double height;
  final String text;
  final Widget icon;
  final VoidCallback onPressed;
  Color? textColor;
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          // 按钮被点击时执行的操作
          onPressed();
        },
        child: Container(
          // width: width,
          padding: EdgeInsets.symmetric(horizontal: padding ?? 30.w),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (text.isNotEmpty)
                  Text(
                    text,
                    style: TextStyle(
                        color: textColor ?? Colors.white,
                        fontSize: isWindowsOrMac ? 39.sp : 33.sp,
                        fontWeight: FontWeight.w700),
                  ),
                if (text.isNotEmpty)
                  SizedBox(
                    width: isWindowsOrMac ? 35.w : 20.w,
                  ),
                icon,
              ],
            ),
          ),
        ));
  }
}

Widget creatBottomBtn(
    String text,
    VoidCallback onPressed,
    String bgName,
    double widthBG,
    double heightBG,
    String iconName,
    double widthIcon,
    double heightIcon) {
  return InkWell(
    onTap: () {
      // 按钮被点击时执行的操作
      onPressed();
    },
    child: Stack(
      children: [
        SvgPicture.asset(
          'assets/images/$bgName.svg',
          height: 153.h,
          fit: BoxFit.cover,
        ),
        Positioned(
          left: 40.w, // 将Text放置在左侧
          top: 0,
          bottom: 0, // 垂直居中的位置
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              text,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 39.sp,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ),
        Positioned(
          right: 40.w, // 将Text放置在左侧
          top: 0,
          bottom: 0, // 垂直居中的位置
          child: Align(
            alignment: Alignment.centerLeft,
            child: SvgPicture.asset(
              'assets/images/$iconName.svg',
              width: widthIcon,
              height: heightIcon,
            ),
          ),
        ),
      ],
    ),
  );
}
