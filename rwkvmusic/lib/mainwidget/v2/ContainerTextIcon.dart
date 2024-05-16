import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rwkvmusic/style/color.dart';

class ContainerTextIcon extends StatelessWidget {
  const ContainerTextIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 253.w,
      height: 123.h,
      decoration: BoxDecoration(
        color: AppColor.color_2C2C2C,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColor.color_ffffff.withOpacity(0.25),
            offset: const Offset(-2.36, 2.36),
            blurRadius: 1.18,
            spreadRadius: 0,
          ),
          const BoxShadow(
            color: AppColor.color_000000,
            offset: Offset(2.36, 2.36),
            blurRadius: 1.18,
            spreadRadius: 0,
          ),
        ],
        // gradient: const LinearGradient(
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        //   colors: [AppColor.color_494949, AppColor.color_323232],
        // ),
      ),
      child: Center(
        child: Container(
          width: 243.w,
          height: 113.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            boxShadow: [
              BoxShadow(
                color: AppColor.color_ffffff.withOpacity(0.2),
                offset: const Offset(.0, 2.36),
                blurRadius: 1.18,
                spreadRadius: 0,
              ),
              BoxShadow(
                color: AppColor.color_000000.withOpacity(0.42),
                offset: const Offset(0, -2.36),
                blurRadius: 1.18,
                spreadRadius: 0,
              ),
            ],
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColor.color_494949, AppColor.color_323232],
            ),
          ),
          child: Center(
            child: Text(
              'Prompts',
              style: TextStyle(
                fontFamily: "Inter",
                fontSize: 39.sp,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w700,
                // height: 1.7, // Equivalent to line-height: 170% in CSS
                shadows: const [
                  Shadow(
                    offset: Offset(0, 2.365),
                    blurRadius: 1.182,
                    color: Color.fromRGBO(0, 0, 0, 0.25),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
