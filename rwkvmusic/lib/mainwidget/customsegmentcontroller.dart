import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rwkvmusic/style/color.dart';

class CustomSegment extends StatelessWidget {
  const CustomSegment({super.key, required this.callBack});
  final Function(int) callBack;

  @override
  Widget build(BuildContext context) {
    return CustomSlidingSegmentedControl<int>(
      // height: 143.h,
      // isStretch: true,
      // innerPadding: const EdgeInsets.all(10),
      // fixedWidth: 300.w,
      initialValue: 1,
      // padding: 20.w,
      // height: 123.h,
      children: {
        1: Text(
          'Prompt Mode',
          style: TextStyle(
              color: AppColor.color_ffffff,
              fontSize: 39.sp,
              fontWeight: FontWeight.w700),
        ),
        2: Text(
          'Create Mode',
          style: TextStyle(
              color: AppColor.color_FF757575,
              fontSize: 39.sp,
              fontWeight: FontWeight.w700),
        ),
      },
      decoration: BoxDecoration(
        color: AppColor.color_2C2C2C,
        borderRadius: BorderRadius.circular(14.h),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(.25),
            blurRadius: 1.18,
            spreadRadius: 0,
            offset: const Offset(
              2.36,
              2.36,
            ),
          ),
          const BoxShadow(
            color: Colors.black,
            blurRadius: 1.18,
            spreadRadius: 0,
            offset: Offset(
              -2.36,
              -2.36,
            ),
          ),
        ],
      ),
      thumbDecoration: BoxDecoration(
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
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInToLinear,
      onValueChanged: (v) {
        print(v);
        callBack(v - 1);
      },
    );
  }
}
