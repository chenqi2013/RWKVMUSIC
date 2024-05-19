import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

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
